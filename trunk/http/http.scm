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
 http
 (library common)
 (include "common.sch")
 (option (loadq "http.init"))
 (export
  *current-http-context*
  (current-http-query #!optional value)
  (current-http-params #!optional value)
  (current-http-cookies #!optional value)
  (current-http-path #!optional value)

  (current-http-method #!optional value)
  (current-userid #!optional value)
  (current-document-base #!optional value)
  (current-http-url #!optional value)
  (current-http-cookies-attributes #!optional value)
  (current-http-request-uri #!optional value)
  (current-http-script-name #!optional value)

  (current-http-body . args)
  (cgi-mode? . args)

  (current-content-type . args)
  (current-content-length . args)
  (current-content-disposition . args)
  (current-query-disposition #!optional value)
  (current-query-content-type #!optional value)
  )
 )

(define *current-http-context* '(current-http-context))
(define-http-context-adapter current-http-query)

(define-http-context-adapter current-http-params)
(define-http-context-adapter current-http-cookies)
(define-http-context-adapter current-query-disposition)
(define-http-context-adapter current-query-content-type)
(define-http-context-adapter current-http-path)


(define-http-context-adapter current-http-method)
(define-http-context-adapter current-userid)
(define-http-context-adapter current-document-base)
(define-http-context-adapter current-http-url)
(define-http-context-adapter current-http-request-uri)
(define-http-context-adapter current-http-script-name)

(define-parameter current-http-body)

(define-http-context-adapter current-http-cookies-attributes)

(define-parameter current-content-type)
(define-parameter current-content-length)
(define-parameter current-content-disposition)

(define-parameter cgi-mode?)

(current-http-query '())
(current-http-cookies '())
(current-http-cookies-attributes '())
(current-content-type "text/plain")
(current-http-body "")

(cgi-mode? #f)

