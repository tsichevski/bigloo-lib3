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
 apropos
 ;; (extern (symtab::obj "c_symtab"))
 (import regex srfi-1)
 (export
  (apropos::pair-nil rexp-string)
  )
 )

(define (apropos rexp-string)
   ;; Force initialization of eval module
   (eval "")
   (let*((rexp(regexp rexp-string))
	 (ht (pragma::obj "(obj_t)bgl_get_symtab()"))
	 (len(vector-length ht)))
      (let loop ((i 0)
		 (accu '()))
	 (if(>=fx i len)
	    (apply append accu)
	    (loop (+fx i 1)
		  (cons
		   (filter
		    (lambda(s)
		       (and
			(getprop s '_0000)
			(regexp-match-positions rexp (symbol->string s))))
		    (vector-ref ht i))
		   accu))))))

;(define (main argv)
;   (for-each print(apropos (cadr argv))))
