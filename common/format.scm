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
 format
 (export
  (fprintf::unspecified port #!optional #!rest)
  (printf::unspecified  #!optional #!rest)
  (format::bstring  #!optional #!rest)
  ))

(define(xprintf procname input output rest)
  (let((next-char(lambda()(read-char input))))
    (let loop((ch(next-char))(args rest))
      (unless(eof-object? ch)
	     (if(eq? ch #\~)
		(let((next(next-char)))
		  (let*((next-arg
			 (lambda()
			   (if(null? args)
			      (error procname "insufficient number of arguments"rest)
			      (car args))))
			(print-radix
			 (lambda(radix)
			   (let((s(number->string(next-arg)radix)))
			     (display
			      (if(char=?(string-ref s 0)#\#)
				 (substring s 2(string-length s))
				 s)
			      output)
			     (loop(next-char)(cdr args))))))
		    (case next
		      ((#\newline)(loop(next-char)args))
		      ((#\a #\A)(display(next-arg)output)
				(loop(next-char)(cdr args)))
		      ((#\s #\S)(write(next-arg)output)
				(loop(next-char)(cdr args)))
		      ((#\v #\V)(print(next-arg)output)
				(loop(next-char)(cdr args)))
		      ((#\c #\C)(write-char(next-arg)output)
				(loop(next-char)(cdr args)))
		      ((#\% #\n)(newline output)
				(loop(next-char)args))

		      ((#\r)(write-char #\return output)
		       (loop(next-char)args))
		      
		      ((#\x #\X)(print-radix 16))
		      ((#\o #\O)(print-radix 8))
		      ((#\b #\B)(print-radix 2))
		      
		      ((#\~)(display #\~ output)
			    (loop(next-char)args))
		      (else(error "fprintf" "tag not allowed" next))
		      )))
		(begin
		  (write-char ch output)
		  (loop(next-char)args)))))))

(define(fprintf port #!optional (template::bstring "") #!rest args)
  (xprintf "fprintf"(open-input-string template)port args))

(define(printf #!optional (template::bstring "") #!rest args)
  (xprintf"printf"(open-input-string template)(current-output-port)args))

(define(format #!optional (template::bstring "") #!rest args)
  (let((os(open-output-string)))
    (xprintf"format"(open-input-string template)os args)
    (get-output-string os)))
;;(format "~a is ~a" 1 2)

