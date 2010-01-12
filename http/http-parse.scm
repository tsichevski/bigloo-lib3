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
 http-parse
 (library common)
 (include "common.sch")
 (export
  (http-request-read-status-line::pair #!optional port)
  (http-request-read::pair-nil #!optional port)
  (http-url-decode::bstring str::bstring)
  (http-url-encode::bstring str::bstring #!optional (escape "%"))
  (inline http-url-encode-double::bstring s::bstring)
  (http-decode-x-www-form-urlencoded::pair str::bstring)
  (http-print-query ::pair)
  (http-parse-cookie::pair-nil s::bstring)
  (http-process-message-header::pair-nil alist::pair-nil)
  ))

(define (http-request-read-status-line #!optional port)
  (let ((port (or port (current-input-port))))
  (read/rp (regular-grammar
    ((crlf (: (? #\return) #\newline ))
     (word(+(out #\space #\tab #\newline #\return))))
    
    ((: (submatch word) #\space
	(submatch word) #\space
	(submatch word)
	crlf)
     (list(the-submatch 1)(the-submatch 2)(the-submatch 3)))
    (else
     (error "http-request-read-status-line" "Unexpected EOF"(the-failure))))
   port)))
;;(pp(http-request-read-status-line (open-input-string #"HTTP/1.1 200 Ok\r\n")))

(define (http-request-read #!optional port)
  (let ((port (or port (current-input-port))))
  (let((attributes '()))
    (read/rp (regular-grammar
      ((crlf (: #\return #\newline)))

      ((: (or #\tab #\space) (submatch(+ (out #\newline #\return)))crlf)
       (set-cdr!(car attributes)
		(string-append(cdar attributes)(string #\newline)(the-submatch 1)))
       (ignore))

      ((: (submatch(+(out #\return #\:)))": "(submatch(* (out #\return)))crlf)
       (push! attributes(cons(string->symbol-ci(the-submatch 1))(the-submatch 2)))
       (ignore))

      (crlf(reverse attributes))
      (else
       (error "http-request-read" "Unexpected EOF"(the-failure))))
     port))))

;;(pp(http-request-read(open-input-string #"Date: Tue, 21 Sep 1999 11:02:47 GMT\r\nServer: Apache/1.2.4 rus/PL20.7\r\nexpires: Wed Sep 22 15:02:52 1999\r\nConnection: close\r\nContent-Type: text/html\r\nVary: accept-charset\r\n\r\nbody")))

;*-------------------------------------------------------------------*;
;*  Decode + % and hexadecimal char notations                        *;
;*-------------------------------------------------------------------*;
(define(http-url-decode str)
  (string-grammar-apply
   str
   (lambda(port)
     (read/rp
      (regular-grammar
       ()
       ((: (in "%^") xdigit xdigit)
	(integer->char(string->number(the-substring 1 3)16)))
       (#\+ #\space))
      port))))
;;(http-url-decode "%dd%dd")
;;(http-url-decode "something")

;*-------------------------------------------------------------------*;
;*  Encode url string, encode all but alphanumerics                  *;
;*-------------------------------------------------------------------*;
(define (http-url-encode str #!optional (escape "%"))
  (string-grammar-apply
   str
   (lambda(port)
     (read/rp
      (regular-grammar
       ()
       ((or
	 alpha
	 digit
	 #\_
	 #\-
	 #\!
	 #\<
	 #\>
	 #\.
	 )
	;;((or alpha digit #\_ #\- #\! #\< #\> #\/ #\.)
	(the-string))
       
       ;; Warning! Never encode spaces as plus signs. According to
       ;; HTTP1.1, plus signs are valid characters in PATH_INFO part of
       ;; URL
       
       ;;(#\space "+")
       (else
	(if(eof-object?(the-failure))
	   (the-failure)
	   (string-append escape(char->hex(the-failure))))))
      port))))

;(http-url-encode "Вовка Морковка")
;(http-url-encode "english")

(define-inline(http-url-encode-double::bstring s::bstring)
  (http-url-encode s "^"))
;(http-url-encode-double "Вовка Морковка")

;*-------------------------------------------------------------------*;
;*  Parse form name=value pair, urldecode value part                 *;
;*-------------------------------------------------------------------*;
(define(http-decode-x-www-form-urlencoded s)
  (define(name->path n)
    (map string->symbol-ci(string-split-by n #\.)))

  (let((params '())
       (query  (list 'dummy)))

    (try
     (read/lalrp
      (lalr-grammar
       (assign token delim)
       (asslist
	(()#unspecified)
	((asslist delim)#unspecified)
	((asslist expr)#unspecified))

       (expr
	((token@left assign token@right)
	 (tree-set! query(name->path left)right))
	
	;; shift/reduce conflict here
	((token assign)
	 (tree-set! query(name->path token) ""))
	
	((token)
	 (push! params token))
	))
     
      (regular-grammar
       ()
       ((:(in "&;")(* blank))
	'delim)
       (#\= 'assign)
       ((: #\"(submatch(*(out #\")))#\")
	(cons 'token (http-url-decode(the-submatch 1))))
       ((+(out "=&;"))
	(cons 'token (http-url-decode(the-string))))
       )
     
      (open-input-string s))
     (lambda (escape proc mes obj)
       (error
	(format
	 "http-decode-x-www-form-urlencoded: ~a ~a"
	 s proc)
	mes obj)))
    
    (cons (reverse params)(cdr query))))

;(pp(http-decode-x-www-form-urlencoded "da;  b;cc&v=something&value.a=another&value.b=rrrr"))

(define(http-print-query vals::pair)
  (let((need-delim? #f))
    (tree-for-each
     (lambda(val path)
       (display*
	(if need-delim?
	    #\&
	    (begin(set! need-delim? #t)""))
	(print-list-delimited path #\.)
	"="
	(http-url-encode val)))
     vals)))

;;(http-print-query '((value  "something")(v (a "aaa")(b "bbb"))(ok "Послать")))

;*-------------------------------------------------------------------*;
;*  Parse value of Set-Cookie attribute (see RFC2109 for details)    *;
;*-------------------------------------------------------------------*;
;; Limitation: cookie attributes are throwed away
(define(http-parse-cookie s::bstring)
  (alist-group
   (let((xcons
	 (lambda(name value)
	   (cons(string->symbol-ci name)value))))
     (try
      (reverse
       (read/lalrp
	(lalr-grammar
	 (assign string token)
	 (asslist
	  (() '())
	  ((asslist expr)
	   (cons expr asslist))

	  ((assign)
	   (error "http-parse-cookie" "unexpected ASSIGN" s))
	  ((string)
	   (error "http-parse-cookie" "unexpected STRING" (cons string s)))
	  )
       
	 (expr
	  ((token@left assign token@right)
	   (xcons left right))
       
	  ((token assign string)
	   (xcons token string))
       
	  ((token assign)
	   (xcons token ""))

	  ((token)
	   (xcons token ""))
	  ))
     
	(regular-grammar
	 ()
	 (blank(ignore))
	 ((in ",;")(ignore))
	 (#\= 'assign)
	 ((: "\"" (submatch(* (or (out #\\ #\") (: #\\ all)))) "\"")
	  (cons 'string
		(escape-scheme-string(the-submatch 1))))
	 ((+(out #\tab #"\t =,;"))
	  (cons 'token (the-string))))
     
	(open-input-string s)))
      (lambda (escape proc mes obj)
	(error
	 (format
	  "http-parse-cookie: ~a ~a"
	  s proc)
	 mes obj))))))

;(pp(http-parse-cookie "a=\"qwe\\\"rty\"; Comment=\"the comment\",  eee; rrr=tt;qqq"))
;(http-parse-cookie " $Version=1;aaa=\"uid%3dwowa%2cuid\\\"ddd\"; $Path=aaa,  eee=e; rrr=tt;qqq=2")
;(http-parse-cookie " ")

;*-------------------------------------------------------------------*;
;*  Parse general headers                                            *;
;*-------------------------------------------------------------------*;
(define(http-process-message-header::pair-nil alist::pair-nil)
  (alist-map
   (lambda(field-name::symbol field-value::bstring)
     (cons field-name
	   (case field-name
	     ((content-type content-disposition)
	      ;  media-type     = type "/" subtype *( ";" parameter )
	      ;  Content-Type: text/html; charset=ISO-8859-4
	      (http-decode-x-www-form-urlencoded field-value))
	     
	     ((content-length)
	      ;  Content-Length    = "Content-Length" ":" 1*DIGIT
	      (string->integer field-value))
	     (else field-value))))
   alist))
;;(pp(http-process-message-header '((content-length . "123")(content-type . "text/html; charset=ISO-8859-4"))))
