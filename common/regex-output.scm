; -*-Scheme-*-

;************************************************************************/
;*                                                                      */
;* Copyright (c) 2003 Marcin Tustin <mt500@ecs.soton.ac.uk>             */
;*                                                                      */
;* This file is part of bigloo-lib (http://bigloo-lib.sourceforge.net)  */
;*                                                                      */
;* This program is free software; you can redistribute it and/or modify */
;* it under the terms of the GNU General Public License as published    */
;* the Free Software Foundation; either version 2, or (at your option   */
;* any later version.                                                   */
;*                                                                      */
;* This program is distributed in the hope that it will be useful,      */
;* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        */
;* GNU General Public License for more details.                         */
;*                                                                      */
;* You should have received a copy of the GNU General Public License    */
;* along with this program; see the file COPYING.  If not, write to     */
;* the Free Software Foundation, 59 Temple Place - Suite 330,           */
;* Boston, MA 02111-1307, USA.                                          */
;*                                                                      */
;************************************************************************/

;;I would appreciate it if anyone using this would email me, if you
;;receive this before october 2003. Thanks for your co-operation

 
;;;regex-output outputs a string that is a member of the regular
;;;language defined by the input parameter. That parameter should be a
;;;string describing a regex using posix syntax, as described in the
;;;gawk infopage. Certain escapes which bigloo's regex facilities do
;;;not recognise are similarly unrecognised here

;; Examples:

;(regex-output "sdh") => sdh

;(regex-output "sd[ah]") => sda

;(regex-output "sd{3,5}[ah]") => sddda

;(regex-output "s*d{3,5}[ah]?") => sddda

;(regex-output "s*d{3,5}[^ah]?") => sddd!

;(regex-output "s*d|b?") => sd

;egrep, given the regex passed to regex-output, would match a line
;containing the string returned by regex-output; this is equivalent to to
;saying that regex-output returns a string which is a member of the
;language described by the parameter.

;The function returns only one matching string, as anything featuring a +
;or a * would have an infinite number of possible matches.

;In the case of a malformed regex, eg "d|{3}", the result is undefined,
;although in fact, the malformed part of the regex will be ignored.

;        The rule for the various constructs are:
;a simple character is output as is.

;<regex>{a, b} or  <regex>{a} outputs a instances of the match for regex.
;If a is not a number, then an error will be signalled, and the unspedified
;value returned.
  
;[<char>...] outputs the first character

;[^<char>] outputs character #a033 ('!') by preference; if that is in the
;set of <char>s, it tries #a034, and so on, unitl it finds a character  
;which isn't. (The value to start from is controlled by
;*default-exclusion-start*)

;<regex>* <regex>+ <regex>? all return one match for regex.

;<regexA>|<regexB> always returns a match for regexA
        
;$ and ^ are ignored (rather than the other option of forcing output of
;newlines).
;. is replaced with '!', to be compatible with the [^...] behaviour. (This
;is controlled by *default-dot-replacement*

;Backslshes may be used to escape the special characters: \*
;(If testing yourself, be aware of the fact that there is an extra level of
;escaping needed, certainly at the commandline)

;regex-output recognises the following escapes as special: \t \n \a \f \r
;\v
;as specified in the gawk infopage. They are processed after the comment
;"ESCAPES HERE" if anyone needs to disable them.

(module
 regex-output
 (export
  (regex-output::string regex::string)
  ))

(define *default-dot-replacement* #\!)
(define *default-exclusion-start* 33)

(define (regex-output::string regex::string) 
  (read/lalrp 
   (lalr-grammar 
    (NOT-SQUARE SQUARE L-PAREN R-PAREN CURLIES BAR CHAR)
    (s
     ((statement quantifier s) (string-append (let loop ((count quantifier)) 
						(if (eq? count 0) (string)
						(string-append statement 
							       (loop (- count 1))))) s))
     (() (string)))
    (quantifier 
     ((CURLIES) CURLIES)
     (() 1))
    (not-square
     ((NOT-SQUARE) NOT-SQUARE))
    (square
     ((SQUARE) SQUARE))
    (group
     ((L-PAREN s R-PAREN) s))
    (altern
     ((s@first BAR s) first))
    (statement 
     ((CHAR) CHAR)
     ((not-square) not-square)
     ((square) square)
     ((group) group)
     ((altern) altern)))
  (regular-grammar ((sq-char (or (out #\]) (:#\\ #\]))))
			   ((: #\\ #\*) (cons 'CHAR "*"))
			   ((: #\\ "?") (cons 'CHAR "?"))
			   ((: #\\ "+") (cons 'CHAR "+"))
			   ((: #\\ "$") (cons 'CHAR "$"))
			   ((: #\\ "^") (cons 'CHAR "^"))
			   ((: #\\ "(") (cons 'CHAR "("))
			   ((: #\\ ")") (cons 'CHAR ")"))
			   ((: #\\ "|") (cons 'CHAR "|"))
			   ((: #\\ "[") (cons 'CHAR "["))
			   ((: #\\ ".") (cons 'CHAR "."))
			   ((: #\\ "]") (cons 'CHAR "]"))
			   ((: #\\ "}") (cons 'CHAR "}"))
			   ((: #\\ "{") (cons 'CHAR "{"))
			   ((: #\\ "\\") (cons 'CHAR "\\"))
			   ("*" (ignore))
			   ("?" (ignore))
			   ("+" (ignore))
			   ("$" (ignore))
			   ("^" (ignore))
			   (#\( 'L-PAREN)
			   (#\) 'R-PAREN)
			   (#\| 'BAR)
			   (#\. (cons 'CHAR (string *default-dot-replacement*)))
;;;;;ESCAPES HERE;;;;;;;;;;;;;
			   ((: "\\"#\t) (cons 'CHAR (string #\Tab)))
			   ((: "\\"#\n) (cons 'CHAR (string #\Newline)))
			   (" " (cons 'CHAR " "))
			   ((: #\\#\a) (cons 'CHAR (string #a007)))
			   ((: #\\#\f) (cons 'CHAR (string #a012)))
			   ((: #\\#\r) (cons 'CHAR (string #a013)))
			   ((: #\\#\v) (cons 'CHAR (string #a011)))
			   ((: #\\ all)(cons 'CHAR (the-substring 1 2)))
			   ((: "[^" (+ sq-char) #\]) 
			    (cons 'NOT-SQUARE 
				  (let loop ((num *default-exclusion-start*))
				    (if 
				     (eval 
				      `(string-case ,(string (integer->char num))
						    ((posix 
						      ,(string-append "[" (the-substring 2 (the-length) ))) #t)
						    (else #f)))
					  (loop (+ num 1))
					  (string (integer->char num))))))
			   ((: #\[ (+ sq-char) #\]) 
			    (cons 'SQUARE (let ((first (the-substring 1 2)))
					    (if (equal? #\\ first) 
						(regex-output (the-substring 1 3))
						first))))
									  
			   ((:  #\{ (+ digit) (? #\,) (* digit) #\} ) 
				   (let loop ((num (string->number (the-substring 1 2))) (len 2)) 
					 (if num 
						 (loop (string->number (the-substring 1 (+ len 1))) (+ len 1))
						 (cons 'CURLIES (string->integer (the-substring 1 (- len 1)))))))
			   ((out "?*.[]()\|+\\{}^$") (cons 'CHAR (the-string)))
			   (else
				(let ((c (the-failure)))
				  (if (eof-object? c)
					  c
					  (error 'rgc "Illegal character" c)))))
  (open-input-string regex)))
