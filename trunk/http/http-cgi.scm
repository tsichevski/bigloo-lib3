; -*-Scheme-*-

;************************************************************************/
;*                                                                      */
;* Copyright (c) 2003-2009 Vladimir Tsichevski <tsichevski@gmail.com>   */
;*                                                                      */
;* This file is part of bigloo-lib (http://bigloo-lib.sourceforge.net)  */
;*                                                                      */
;* This library is free software; you can redistribute it and/or        */
;* modify it under the terms of the GNU Lesser General Public           */
;* License as published by the Free Software Foundation; either         */
;* version 2 of the License, or (at your option) any later version.     */
;*                                                                      */
;* This library is distributed in the hope that it will be useful,      */
;* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    */
;* Lesser General Public License for more details.                      */
;*                                                                      */
;* You should have received a copy of the GNU Lesser General Public     */
;* License along with this library; if not, write to the Free Software  */
;* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 */
;* USA                                                                  */
;*                                                                      */
;************************************************************************/

(module
 http-cgi
 (library common)
 (import
  http
  http-parse
  http-response
  )
 (export
  init-cgi::procedure
  )
 (eval(export-all)))

(define(adapter-set-from-env adapter::procedure envname::string #!optional defval)
  (let((val(getenv envname)))
    (adapter
     (list
      (or val defval)))))

(define init-cgi
  (delay
    (let((query-string(or(getenv "QUERY_STRING")"")))
      (adapter-set-from-env current-http-method "REQUEST_METHOD" "GET")
    
      (let((pi(getenv "PATH_INFO")))
	(when pi
	      (current-http-path
	       (let*((splitted(string-split-by pi #\?))
		     (qs(cdr splitted)))
		 (when (pair? qs)
		       (set! query-string (car qs)))
		 (list(car splitted))))))

      (current-http-request-uri
       (let((ru(getenv "REQUEST_URI")))
	 (if ru (list ru) '())))

      (current-http-script-name
       (let((ru(getenv "SCRIPT_NAME")))
	 (if ru (list ru) '())))

      (current-userid(getenv "REMOTE_USER"))
      (current-document-base(getenv "DOCUMENT_ROOT"))
      (current-http-url
       (string-append "http://"
		      (or(getenv "HTTP_HOST")"localhost")
		      (or(getenv "SCRIPT_NAME")
			 "/unknown-program")))
      (current-http-cookies
       (let((cookie-string(getenv "HTTP_COOKIE")))
	 (if cookie-string
	     (let*((raw(http-parse-cookie cookie-string))
		   (clean(delete-duplicates raw car-eq?)))
	       ; Netscape duplicates
	       ; the cookie string !!!
	       (unless(equal? raw clean)
		      (warning "init-cgi"
			       "duplicates in cookies"
			       (cons cookie-string
				     raw)))
	       clean)
	     '())))
    
      (current-http-cookies-attributes '())

      (let((content-length-string(getenv "CONTENT_LENGTH")))
	(when content-length-string
	      (current-content-length(string->integer content-length-string))))

      ;; start of content-type-connected part
      (when(integer?(current-content-length))
	   (current-http-body
	    ;; FIXME: if large input use mmap to allocate buffer
	    (let*((len::int(current-content-length))
		  (buffer::bstring(make-string len))
		  (read(pragma::int "fread($1, 1, $2, stdin)"
				    ($bstring->string buffer)
				    len)))
	      (when(<fx read len)
		   (error "init-cgi"
			  "read too little"(cons len read)))
	      buffer)))

      (let((content-type-string(getenv "CONTENT_TYPE")))
	(when content-type-string
	      (let((decoded(http-decode-x-www-form-urlencoded content-type-string)))
		(current-content-type(caar decoded))
		(current-content-disposition(cdr decoded)))))
      
      (let((query(http-decode-x-www-form-urlencoded query-string)))
	
	;; Warning: MSIE sets the content-type from the previous message
	;; so we can see here "multipart/form-data" even in GET message
	;; this is the reason we explicitly check for message is of POST type
	(if(and(pair?(current-http-method))
	       (string-ci=?(car(current-http-method)) "POST")
	       (string-ci=?(current-content-type)
			   "multipart/form-data"))

	   (let*((boundary(string-append
			   "--"
			   (cadr(assq 'boundary(current-content-disposition)))))
		 (boundary-length(string-length boundary))
		 (body(current-http-body)))
	   
	       (let((query-disposition
		     (tree-lookup! *current-http-context*
				   '(current-query-disposition)))
		    (query-content-type
		     (tree-lookup! *current-http-context*
				   '(current-query-content-type))))

		 (let loop ((offset (+fx 2 boundary-length)))
		   (let((found(string-contains(current-http-body)boundary offset)))
		     (unless found
			     (error "multipart-decode" "corrupted message"body))
		     ;;(print "offset: " offset "found: "found)
		     (let*((res(substring body offset (-fx found 2)));; eat trailing crlf
			   (ip(open-input-string res))
			   (header(http-process-message-header(http-request-read ip)))
			   (disposition-ass(assq 'content-disposition header))
			   (content-type-ass(assq 'content-type header))
			   (content-type(and content-type-ass(caadr content-type-ass)))
			   (disposition(caadr disposition-ass));; must be 'FORM-DATA
			   (disposition-atts(cddr disposition-ass));; ((FILENAME . XXI.html) (NAME . file))
			   (name(cadr(assq 'name disposition-atts)))

			   (disposition-atts(alist-delete 'name disposition-atts))

			   ;; HACK!!! HACK!!! input-port-position report wrong position!!!
			   ;; adding 1 to position need to be removed as soon the bug will be fixed

			   (chunk-body(substring res(+fx 1(input-port-position ip))
						 (string-length res)))

			   (bound-end(+fx found boundary-length))
			   (next(+fx bound-end 2))
			   (delim(substring body bound-end next)))
		     
		       (let((path
			     (map string->symbol-ci(string-split-by name #\.))))
			 (tree-set! query path chunk-body)
		     
			 (when(pair? disposition-atts)
			      (append!
			       (tree-lookup! query-disposition path)
			       disposition-atts))
		     
			 (when content-type
			       (tree-set! query-content-type
					  path
					  content-type))
		     
			 (if(string=? delim "--")
			    (begin
			      ;;(current-query-disposition query-disposition)
			      ;;(current-query-content-type query-content-type)
			      )
			    (loop next)))
		       )))))
	   
	   ;; merge urlencoded body 
	   (tree-for-each
	    (lambda(o p)
	      (tree-set! query p o))
	    (http-decode-x-www-form-urlencoded (current-http-body))))
	
	(current-http-params(car query))
	(current-http-query(cdr query))))))
