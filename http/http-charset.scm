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

;; The module assumed to do same job as Apache mod_charset.c 
(module
 http-charset
 (import http-response)
 (library common)
 (export
  ))

(define *server-charset-default* "")
(define *client-charset* "")

(define *known-agents* '())
;; Agents that can't understand MIME
(define *bad-agents* '())

(let((user-agent(getenv "HTTP_USER_AGENT")))
  (when user-agent
	(set! *client-charset*
	      (cond((find
		     (lambda(p)(string-contains user-agent(car p)))
		     *known-agents*)	 
		    => cdr)))))
;;(setenv "HTTP_USER_AGENT" "Mozilla/4.06 [en] (X11; I; SunOS 5.7 sun4u)")

;; encode outgoing message
(define http-encode
  (let((encode
	(delay
	  (if(and (not(string-null? *server-charset-default*))
		  (not(string-null? *client-charset*))
		  (string-null?
		   (car(string-split-by-string(current-http-content-type)"text/"))))
	     (make-iconv-encoder *client-charset* *server-charset-default*)))))
    (lambda(data::bstring)((force encode)data))))

;; encode incoming message
(define http-decode values)

;; CharsetDecl windows-1251 ru
;; CharsetDecl koi8-r ru
;; CharsetAlias windows-1251 win x-cp1251 cp1251 cp-1251
;; CharsetAlias koi8-r koi-8-r koi8 koi-8 koi
;; CharsetPriority koi8-r windows-1251
;; CharsetDefault koi8-r
(define *charset-source-enc* #f)

