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

(define (msg-checking s)
  (print "====================================")
  (print "checking " s)
  (print "====================================")
  )

(define-macro (test expr b message)
  `(begin
     (fprintf(current-error-port)"checking: ~a: " ,message)
     (let((res  ,expr))
       (if(equal? res ,b)
	  (fprintf(current-error-port)"Ok~%")
	  (error ,message (format "check failed must be ~s, got ~s" ,b
				  res)
		 "")))))

;; Check whether result is not equal to scheme false
(define-macro (test-true expr message)
  `(begin
     (fprintf(current-error-port)"checking: ~a: " ,message)
     (let((res  ,expr))
       (if ,expr
	  (fprintf(current-error-port)"Ok~%")
	  (error ,message "failed" "")))))

;; Check whether an expression was executed without any exception
;; signalled. Expression return value is not checked.
(define-macro(test-execute expr message)
  `(begin
     (fprintf(current-error-port)"checking: ~a: " ,message)
     (let((res ,expr))
       (fprintf(current-error-port)"Ok~%")
       res)))

(define-macro(test-error expr b message)
  `(begin
     (fprintf(current-error-port)"checking exception for ~a: " ,message)
     (try
      ,expr
      (lambda (escape proc msg obj)
	(if(string=? msg ,b)
	   (fprintf(current-error-port)"Ok~%")
	   (fprintf(current-error-port)
		   "~a: wrong error message, must be: ~s, got ~s~%" ,message ,b msg))
	(escape #t)))))
