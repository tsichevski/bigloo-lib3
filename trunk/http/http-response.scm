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
 http-response
 (library common)
 (include "common.sch")
 (import
  http
  http-parse
  )
 (export
  (http-emit-header code::int message::bstring attributes::pair-nil)
  (http-ok #!optional)
  (http-redirect url::bstring)
  (http-redirect-relative uri::bstring)
  (http-authorization-required-answer #!optional)
  (current-http-content-type . args)
  (client-charset . args)
  (current-expiration-seconds . args)
  *already-emitted*
  )
 (eval(export-all))
 )

;*-------------------------------------------------------------------*;
;*  HTTP responce generation & simple answers                        *;
;*-------------------------------------------------------------------*;
;*-------------------------------------------------------------------*;
;*  Print the http header part of answer                             *;
;* header-list must be list of lists name - value                    *;
;*-------------------------------------------------------------------*;
(define *already-emitted* #f)

(define-parameter current-http-content-type)
(current-http-content-type "text/html")

;; set if the result charset was changed
(define-parameter client-charset)

;; one day expiration time
(define-parameter current-expiration-seconds)
;(current-expiration-seconds 86400)

(define (http-emit-header code message attributes)
  (unless *already-emitted*
	  (set! *already-emitted* #t)
	  ;; check if we are in CGI-script
	  (display
	   (if(cgi-mode?)
	      "Status: "
	      "HTTP/1.0 "))
	  (print code " " message)
	  
	  [unless(=(length(current-http-cookies))
		   (length(alist-group(current-http-cookies))))
		 (error "http-emit-header" "duplicate cookies values"
			(current-http-cookies))]
	  
	  (tree-for-each
	   (lambda(val path)
	     ;;(display* "Set-Cookie: "(car cookie)";Max-Age=\"0\""#\newline)
	     (display*"Set-Cookie: "(print-list-delimited path #\.))
	     (unless
	      (string-null? val)
	      ;; NOTE: I always normalize strings here
	      (display*
	       "=\""
	       (string-grammar-apply
		val
		(lambda(port)
		  (read/rp
		   (regular-grammar
		    ()
		    ((in "\\\",;")
		     (string-append"\\"(the-string))))
		   port)))
	       "\""))
	     (newline))
	   (tree-lookup! *current-http-context* '(current-http-cookies)))
	  (for-each
	   (lambda(h)(print (car h)": "(cdr h)))
	   `((content-type
	      .
	      ,(string-append
		(current-http-content-type)
		(if(string?(client-charset))
		   (format "; charset=\"~a\""(client-charset))
		   ""))
	      )
	     ,@attributes
	     ,@(if(number?(current-expiration-seconds))
		  `((expires
		     . ,(ctime(+ (current-seconds)(current-expiration-seconds)))))
		  '())))
	  
	  (newline)
	  ))
;;(http-emit-header 100 "Ok" '())

(define (http-ok #!optional (attributes '()))
  (http-emit-header 200 "Ok" attributes))
;;(http-ok)

(define (http-redirect url)
  (http-emit-header 302 "Moved Temporarily" `((location . ,url)))
  (if(cgi-mode?)(exit 0)))
;;(http-redirect "index.html")

(define (http-redirect-relative uri)
  (http-redirect
   (string-append
    (apply string-append(current-http-script-name))
    uri)))
;;(http-redirect-relative "index.html")

(define (http-authorization-required-answer #!optional (realm "default"))
  (http-emit-header
   401
   "Authorization required"
   `((www-authenticate . ,(string-append "Basic realm=\"" realm "\""))))
  (if(cgi-mode?)(exit 0)))
;;(http-authorization-required-answer "my realm")
