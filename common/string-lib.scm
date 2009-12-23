; -*-Scheme-*-

;************************************************************************/
;*                                                                      */
;* Copyright (c) 2003-2009 Vladimir Tsichevski <tsichevski@gmail.com>   */
;* based on SRFI-13 reference implementation                            */
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
 string-lib
 (include "common.sch")
 (export
  (string-null?::bool s::bstring)
  (string-every pred::procedure s::string #!optional start end)
  (string-any pred::procedure s::string #!optional start end)
  (string-tabulate::bstring proc::procedure len::int)
  (string->list::pair-nil s::bstring #!optional start end)
  (reverse-list->string::bstring char-list::pair-nil)
  (string-join::bstring string-list::pair-nil #!optional
                        (delimiter " ") (grammar 'infix))
  (string-contains s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-copy::bstring s::bstring #!optional start end)
  (substring/shared::bstring s::bstring  #!optional start end)
  (string-copy!::bstring target::bstring tstart s #!optional start end)
  (string-take::bstring s::bstring nchars::int)
  (inline string-drop::bstring s::bstring nchars::int)
  (string-take-right::bstring s::bstring nchars::int)
  (string-drop-right::bstring s::bstring nchars::int)
  (string-pad::bstring s::bstring len::int #!optional (char #\space) start end)
  (string-pad-right::bstring s::bstring len::int #!optional (char #\space) start end)
  (string-trim::bstring s::bstring #!optional
                        char/char-set/pred start end)
  (string-trim-right::bstring s::bstring #!optional
                              char/char-set/pred start end)
  (string-trim-both::bstring s::bstring #!optional
                             char/char-set/pred start end)

  (string-index s::bstring char/char-set/pred #!optional start end)
  (string-index-right s::bstring char/char-set/pred #!optional start end)
  (string-skip s::bstring char/char-set/pred #!optional start end)
  (string-skip-right s::bstring char/char-set/pred #!optional start end)
  (string-fill! s::bstring char::char #!optional start end)

  (string=::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string<>::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string<::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string>::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string<=::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string>=::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-ci=::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-ci<>::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-ci<::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-ci>::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-ci<=::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-ci>=::bool s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  
  
  
  (string-hash::int s::bstring #!optional bound start end)
  (string-hash-ci::int s::bstring #!optional bound start end)
  (string-prefix-length::int s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-suffix-length::int s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-prefix-length-ci::int s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-suffix-length-ci::int s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-prefix?::bool prefix:bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-suffix?::bool suffix::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-prefix-ci?::bool prefix::bstring s2::bstring #!optional start1 end1 start2 end2)
  (string-suffix-ci?::bool suffix::bstring s2::bstring #!optional start1 end1 start2 end2)

  (string-count s char/char-set/pred #!optional start end)
  
  (string-contains-ci s1 s2 #!optional start1 end1 start2 end2)
  (string-titlecase::bstring  s #!optional start end)
  (string-titlecase! s #!optional start end)
  (string-upcase::bstring s #!optional start end)
  (string-upcase! s #!optional start end)
  (string-downcase::bstring s #!optional start end)
  (string-downcase! s #!optional start end)
  (string-reverse::bstring s #!optional start end)
  (string-reverse! s #!optional start end)
  (string-concatenate::bstring string-list::pair-nil)
  (string-concatenate/shared::bstring string-list::pair-nil)
  (string-append/shared::bstring . string-list)
  (reverse-string-concatenate::bstring string-list #!optional final-string end)
  (reverse-string-concatenate/shared::bstring string-list #!optional final-string end)
  (string-map::bstring proc s #!optional start end)
  (string-map! proc s #!optional start end)
  (string-fold kons knil s #!optional start end)
  (string-fold-right kons knil s #!optional start end)
  (string-unfold::bstring p f g seed #!optional base make-final)
  (string-unfold-right::bstring p f g seed #!optional base make-final)
  (string-for-each  proc s #!optional start end)
  (xsubstring::bstring s from #!optional to start end)
  (string-xcopy! target tstart s sfrom #!optional sto start end)
  (string-replace::bstring s1 s2 start1 end1 #!optional start2 end2)
  (string-tokenize::pair-nil s #!optional token-set start end)
  (string-filter::bstring s char/char-set/pred #!optional start end)
  (string-delete::bstring s char/char-set/pred #!optional start end)
  (string-parse-start+end proc s args)
  (string-parse-final-start+end proc s args)
  (check-substring-spec proc s start end)
  (substring-spec-ok?::bool s start end)
  (make-kmp-restart-vector::vector c= s #!optional start end)
  (kmp-step pat rv c= c i)
  (string-search-kmp::int pat rv c= i s #!optional start end)
  )

 (static
  (%string-suffix-length s1 start1::int end1::int s2 start2::int end2::int)
  (%string-suffix? s1 start1::int end1::int s2 start2::int end2::int)
  )

 (extern
  (include "string.h")
  (string_contains::int (string int string int) "string_contains")
  )
 (static (char-set:whitespace ch))
 )

(register-eval-srfi! 'string-lib)

(define-macro (unimplemented name)
  `(error ,name "procedure is not implemented" ""))

;;(loadq "common.sch") when in interpreter

(define (string-null? s::bstring)
  (=fx(string-length s)0))
;;(string-null? "") -> #t

(define (string-every pred s #!optional start end)
  (with-optional-range
   "string-every" s start end
   (let loop((start start)
	     (value #t))
     (if(=fx start end)
	value
	(let((value(pred(string-ref s start))))
	  (and value
	       (loop(+fx 1 start)value)))))))
;;(string-every values "qwerty")

(define (string-any pred s #!optional start end)
  (with-optional-range
   "string-any" s start end
   (let loop((start start))
     (or(=fx start end)
	(or(pred(string-ref s start))
	   (loop(+fx 1 start)))))))
;;(string-any values "qwerty")

(define (string-tabulate proc len)
  (let((result(make-string len)))
    (let loop((i 0))
      (if(=fx i len)
	 result
	 (begin
	   (string-set! result i (proc i))
	   (loop(+fx i 1)))))))
;;(string-tabulate (lambda(n)(string-ref(number->string n)0)) 9)

(define (string->list s #!optional start end)
  (with-optional-range
   "string->list" s start end
   (let loop((accu '())(start start))
     (if(=fx start end)
	(reverse accu)
	(loop(cons (string-ref s start) accu)
	     (+fx start 1))))))
;;(string->list "asdf" 1 2)

(define (reverse-list->string char-list)
  (let*((len(length char-list))
	(result(make-string len)))
    (let loop((char-list char-list)
	      (i (-fx len 1)))
      (if(null? char-list)
	 result
	 (begin
	   (string-set! result i (car char-list))
	   (loop (cdr char-list)
		 (-fx i 1)))))))
;;(reverse-list->string '(#\a #\B #\c)) -> "cBa"

(define (string-join string-list #!optional (delimiter " ") (grammar 'infix))
  (apply
   string-append
   (let loop((string-list string-list)
	     (accu '()))
     (if(null? string-list)
	(if(null? accu)
	   (if(eq? grammar 'strict-infix)
	      (error "string-join"
		     "string-list should be non-empty list for strict-infix grammar" "")
	      '())
	   (case grammar
	     ((infix strict-infix)
	      (reverse (cdr accu)))
	     ((suffix)
	      (reverse accu))
	     ((prefix)
	      (cons delimiter(reverse(cdr accu))))
	     (else
	      (error "string-join"
		     "invalid grammar, must be one of: infix, strict-infix, suffix or prefix"
		     grammar))))
	(loop
	 (cdr string-list)
	 (cons* delimiter(car string-list)accu))))))

;;(string-join '("foo" "bar" "baz") ":")         => "foo:bar:baz"
;;(string-join '("foo" "bar" "baz") ":" 'suffix) => "foo:bar:baz:"

;; Infix grammar is ambiguous wrt empty list vs. empty string,
;;(string-join '()   ":") => ""
;;(string-join '("") ":") => ""

;; but suffix & prefix grammars are not.
;;(string-join '()   ":" 'suffix) => ""
;;(string-join '("") ":" 'suffix) => ":"

(define (string-copy s #!optional start end)
  (with-optional-range
   "string-copy" s start end
   (substring s start end)))

;; Note: start arguments made optional in this implementation
(define (substring/shared s #!optional start end)
  (with-optional-range
   "substring/shared"
   s start end
   (if(and(=fx start 0)(=fx end (string-length s)))
      s
      ;; Bigloo does not support shared strings
      (substring s start end))))

(define (string-copy! target tstart s #!optional start end)
  (with-optional-range
   "string-copy!" s start end
   (let((nchars(-fx end start)))
     (when(>fx (+fx tstart nchars)(string-length target))
	  (error "string-copy!" "index out of range"
		 (list target tstart s start end)))
     (pragma "memcpy((void*)($1 + $2), (void*)($3 + $4), $5)"
	   ($bstring->string target)
	   ($bint->int tstart)
	   ($bstring->string s)
	   ($bint->int start)
	   ($bint->int nchars))))
  target)
;;(string-copy! "qwerty" 2 "asdf")

(define (string-take s nchars)
  (substring/shared s 0 nchars))
;;(string-take "Pete Szilagyi" 6) => "Pete S"

(define-inline(string-drop s nchars)
  (substring/shared s nchars))
;;(string-drop "Pete Szilagyi" 6) => "zilagyi"

(define (string-take-right s nchars)
  (substring/shared s (-fx(string-length s)nchars)))
;;(string-take-right "Beta rules" 5) => "rules"

(define (string-drop-right s nchars)
  (substring/shared s 0 (-fx(string-length s)nchars)))
;;(string-drop-right "Beta rules" 5) => "Beta "

(define (string-pad s len #!optional (char #\space) start end)
  (with-optional-range
   "string-pad" s start end
   (string-copy! (make-string len char)
		 (max 0 (-fx len (-fx end start)))
		 s
		 (max start(-fx end len))
		 end)))
;;(pp(string-pad     "325" 5)) => "  325"
;;(pp(string-pad   "71325" 5)) => "71325"
;;(pp(string-pad "8871325" 5)) => "71325"

(define (string-pad-right s len #!optional (char #\space) start end)
  (with-optional-range
   "string-pad-right" s start end
   (string-copy! (make-string len char)
		 0
		 s
		 start
		 (min len (-fx end start)))))
;;(pp(string-pad-right     "325" 5)) => "325  "
;;(pp(string-pad-right   "71325" 5)) => "71325"
;;(pp(string-pad-right "8871325" 5)) => "88713"


;; FIXME: this probably is the SRFI-14 stuff???
(define (in char/char-set/pred)
  (cond((procedure? char/char-set/pred)
	char/char-set/pred)
       ((char? char/char-set/pred)
	(lambda(o::char)
	  (char=? o char/char-set/pred)))
       (else(error "in" "argument must be char or predicate procedure"
		   char/char-set/pred))))
	
(define (out char/char-set/pred)
  (cond((procedure? char/char-set/pred)
	(lambda(o::char)
	  (not(char/char-set/pred o))))
       ((char? char/char-set/pred)
	(lambda(o::char)
	  (not(char=? o char/char-set/pred))))
       (else(error "out" "argument must be char or predicate procedure"
		   char/char-set/pred))))
	
(define (char-set:whitespace ch)
  (memq ch '(#\space #\tab #\newline #\return #a011 #a012 #a160)))

(define (string-trim s #!optional char/char-set/pred start end)
  (let((non-space(string-index s (out (or char/char-set/pred char-set:whitespace)) start end)))
    (if non-space
	(substring/shared s non-space end)
	"")))
;;(pp(string-trim "   asdf   "))

(define (string-trim-right s #!optional char/char-set/pred start end)
  (let((right(string-index-right s (out (or char/char-set/pred  char-set:whitespace)) start end)))
    (if right
	(substring/shared s start(+fx right 1))
	"")))
;;(pp(string-trim-right "   asdf   "))

(define (string-trim-both s #!optional char/char-set/pred start end)
  (let((char/char-set/pred (or char/char-set/pred char-set:whitespace)))
    (string-trim-right
     (string-trim s char/char-set/pred start end)
     char/char-set/pred)))
;;(pp(string-trim-both "   asdf   "))

(define (string-contains s1 s2 #!optional start1 end1 start2 end2)
  ;; assure valid offset values
  (with-optional-range
   "string-contains"
   s1
   start1
   end1
   (with-optional-range
    "string-contains"
    s2
    start2
    end2
    
    (cond((=fx s2-len 0)
	  0)
	 ((< s1-len s2-len)
	  #f)
	 (else
	  (let*((s1::string s1)
		(start1::int start1)
		(s1::string(pragma::string "$1 + $2" s1 start1))
		(s2::string s2)
		(start2::int start2)
		(s2::string(pragma::string "$1 + $2" s2 start2)))
	    (let((result(string_contains
			 s1
			 (-fx s1-len start1)
			 s2
			 (-fx s2-len start2))))
	      (and(>=fx result 0)
		  (+fx result start1)))))))))

(define (string-fill! s char #!optional start end)
  (with-optional-range
   "string-fill!" s start end
   (let loop((start start))
     (when(<fx start end)
	  (string-set! s start char)
	  (loop(+fx start 1))))))
;;(pp(let((s "12345678"))(string-fill! s #\space)s))

(define (string-compare s1 s2 proc< proc= proc> #!optional start1 end1 start2 end2)
  (with-optional-range
   "string-compare" s1 start1 end1
   (with-optional-range
    "string-compare" s2 start2 end2
    (unimplemented "string-compare")
    )))

(define (strncmp::int s1::bstring s2::bstring start1 end1 start2 end2)
  (with-optional-range
   "strncmp" s1 start1 end1
   (with-optional-range
    "strncmp" s2 start2 end2
    (let((byte-comp
	  (let((s1::string s1)
	       (s2::string s2)
	       (len::int(min(-fx end1 start1)(-fx end2 start2)))
	       (start1::int start1)
	       (start2::int start2))
	    (pragma::int
	     "strncmp((const char *)$1 + $4, (const char *)$2 + $5, $3)"
	     s1 s2 len start1 start2))))
      (if(zero? byte-comp)
	 (-fx s1-len s2-len)
	 byte-comp)))))
;;(strncmp "asdf1" "asdf" #f #f #f #f)

(define (string= s1 s2 #!optional start1 end1 start2 end2)
  (zero?(strncmp s1 s2 start1 end1 start2 end2)))
;;(string= "asdf" "asdf")
;;(string= "asdf" "asd1")
;;(string= "qweasdfqwe" "asdasdfasd" 3 7 3 7)

(define (string<> s1 s2 #!optional start1 end1 start2 end2)
  (not(string= s1 s2 start1 end1 start2 end2)))

(define (string< s1 s2 #!optional start1 end1 start2 end2)
  (negative?(strncmp s1 s2 start1 end1 start2 end2)))

(define (string> s1 s2 #!optional start1 end1 start2 end2)
  (positive?(strncmp s1 s2 start1 end1 start2 end2)))

(define (string<= s1 s2 #!optional start1 end1 start2 end2)
  (<=fx(strncmp s1 s2 start1 end1 start2 end2)0))

(define (string>= s1 s2 #!optional start1 end1 start2 end2)
  (>=fx (strncmp s1 s2 start1 end1 start2 end2)0))

(define (strncasecmp::int s1::bstring s2::bstring start1 end1 start2 end2)

;   @if have-strncasecmp

;   (with-optional-range
;    "strncasecmp" s1 start1 end1
;    (with-optional-range
;     "strncasecmp" s2 start2 end2
;     (let((len-diff (-fx s1-len s2-len)))
;       (if(zero? len-diff)
; 	 (pragma::int
; 	  "strncasecmp((const char *)$1 + $4, (const char *)$2 + $5, $3)"
; 	  ($bstring->string s1)
; 	  ($bstring->string s2)
; 	  ($bint->int (-fx end1 start1))
; 	  ($bint->int start1)
; 	  ($bint->int start2))
; 	 len-diff))))
  
;   @else
  
  (strncmp (string-upcase s1 start1 end1)
	   (string-upcase s2 start2 end2)
	   start1 end1 start2 end2)
;  @endif
  )
;;(strncasecmp "asdf1" "asdf" #f #f #f #f)

(define (string-ci= s1 s2 #!optional start1 end1 start2 end2)
  (zero? (strncasecmp s1 s2 start1 end1 start2 end2)))

;;(string-ci= "asdf" "asDF")
;;(string-ci= "×Ï×Á" "÷ï÷á")
;;(string-ci= "asdf" "asd1")
;;(string-ci= "qweasdfqwe" "asdasdfasd" 3 7 3 7)

(define (string-ci<> s1 s2 #!optional start1 end1 start2 end2)
  (not(string-ci= s1 s2 start1 end1 start2 end2)))

(define (string-ci< s1 s2 #!optional start1 end1 start2 end2)
  (negative?(strncasecmp s1 s2 start1 end1 start2 end2)))

(define (string-ci> s1 s2 #!optional start1 end1 start2 end2)
  (positive?(strncasecmp s1 s2 start1 end1 start2 end2)))

(define (string-ci<= s1 s2 #!optional start1 end1 start2 end2)
  (<=fx(strncasecmp s1 s2 start1 end1 start2 end2)0))

(define (string-ci>= s1 s2 #!optional start1 end1 start2 end2)
  (>=fx(strncasecmp s1 s2 start1 end1 start2 end2)0))

(define (string-hash::int s::bstring #!optional bound start end)
  (with-optional-range
   "string-hash" s start end
   (let*((start (or start 0))
         (len (if end (-fx end start)(string-length s)))
         (bigval (string-hash s start len)))
     (if(integer? bound)
	(remainder bigval bound)
	bigval))))
;;(string-hash "qwerty" 100)

(define (string-hash-ci::int s::bstring #!optional bound start end)
  (with-optional-range
   "string-hash-ci" s start end
   (string-hash (string-upcase s) bound start end)))

(define (string-prefix-length::int s1::bstring
				   s2::bstring
				   #!optional
				   start1 end1
				   start2 end2)
  (with-optional-range
   "string-prefix-length"
   s1
   start1
   end1
   (with-optional-range
    "string-prefix-length"
    s2
    start2
    end2
    (let loop ((i1 start1)(i2 start2))
      (if (or (=fx i1 end1)
	      (=fx i2 end2)
	      (not (char=?(string-ref s1 i1)
			  (string-ref s2 i2))))
	  (-fx i1 start1)
	  (loop (+fx 1 i1)
		(+fx 1 i2)))))))
;;(string-prefix-length "asdf " "asdf s")

(define (%string-suffix-length s1 start1::int end1::int s2 start2::int end2::int)
  (let* ((delta (min (-fx end1 start1) (-fx end2 start2)))
	 (start1 (-fx end1 delta)))

    (if (and (eq? s1 s2)
	     (=fx end1 end2))		; EQ fast path
	delta
	
	(let lp ((i (-fx end1 1)) (j (-fx end2 1)))	; Regular path
	  (if (or (< i start1)
		  (not (char=? (string-ref s1 i)
			       (string-ref s2 j))))
	      (-fx (-fx end1 i) 1)
	      (lp (-fx i 1) (-fx j 1)))))))

(define (string-suffix-length::int s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (with-optional-range
   "string-suffix-length"
   s1
   start1
   end1
   (with-optional-range
    "string-suffix-length"
    s2
    start2
    end2
    (%string-suffix-length s1 start1 end1 s2 start2 end2))))

(define (%string-suffix? s1 start1::int end1::int s2 start2::int end2::int)
  (let ((len1 (-fx end1 start1)))
    (and (<=fx len1 (-fx end2 start2))	; Quick check
	 (=fx len1 (%string-suffix-length s1 start1 end1
					  s2 start2 end2)))))

(define (string-prefix-length-ci::int s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (with-optional-range
   "string-prefix-length-ci"
   s1
   start1
   end1
   (with-optional-range
    "string-prefix-length-ci"
    s2
    start2
    end2
    (unimplemented "string-prefix-length-ci"))))

(define (string-suffix-length-ci::int s1::bstring s2::bstring #!optional start1 end1 start2 end2)
  (with-optional-range
   "string-suffix-length-ci"
   s1
   start1
   end1
   (with-optional-range
    "string-suffix-length-ci"
    s2
    start2
    end2
    (unimplemented "string-suffix-length-ci"))))

(define (string-prefix? prefix s2 #!optional start1 end1 start2 end2)
  (=fx (string-prefix-length prefix s2 start1 end1 start2 end2)
       (string-length prefix)))

(define (string-suffix? suffix s2 #!optional start1 end1 start2 end2)
  (with-optional-range
   "string-suffix?"
   suffix
   start1
   end1
   (with-optional-range
    "string-suffix?"
    s2
    start2
    end2
    (%string-suffix? suffix start1 end1 s2 start2 end2))))

(define (string-prefix-ci? prefix s2 #!optional start1 end1 start2 end2)
  (=fx(string-prefix-length-ci prefix s2 start1 end1 start2 end2)
      (string-length prefix)))

(define (string-suffix-ci? suffix s2 #!optional start1 end1 start2 end2)
  (=fx(string-suffix-length-ci suffix s2 start1 end1 start2 end2)
      (string-length suffix)))

(define (string-index s char/char-set/pred #!optional start end)
  (with-optional-range
   "string-index" s start end
   (let((pred(in char/char-set/pred)))
     (let loop((start start))
       (and(<fx start end)
	   (if(pred(string-ref s start))
	      start
	      (loop(+fx start 1))))))))
;;(string-index "qwerty" #\e)

(define (string-index-right s char/char-set/pred #!optional start end)
  (with-optional-range
   "string-index-right" s start end
   (let((pred(in char/char-set/pred)))
     (let loop((end (-fx end 1)))
       (and(<=fx start end)
	   (if(pred(string-ref s end))
	      end
	      (loop(-fx end 1))))))))
;;(string-index-right "qwertey" #\e 0 4)

(define (string-skip s char/char-set/pred #!optional start end)
  (with-optional-range
   "string-skip" s start end
   (let((pred(out char/char-set/pred)))
     (let loop((start start))
       (and(<fx start end)
	   (if(pred(string-ref s start))
	      start
	      (loop(+fx start 1))))))))
;;(string-skip "qwerty" #\q)

(define (string-skip-right s char/char-set/pred #!optional start end)
  (with-optional-range
   "string-skip-right" s start end
   (let((pred(out char/char-set/pred)))
     (let loop((end (-fx end 1)))
       (and(<=fx start end)
	   (if(pred(string-ref s end))
	      end
	      (loop(-fx end 1))))))))
;;(string-skip-right "qwerty" #\y)

(define (string-count s char/char-set/pred #!optional start end)
  (with-optional-range
   "string-count" s start end
   (unimplemented "string-count")))

(define (string-contains-ci s1 s2 #!optional start1 end1 start2 end2)
  (with-optional-range
   "string-contains-ci" s1 start1 end1
   (with-optional-range
    "string-contains-ci" s2 start2 end2
    (unimplemented "string-contains-ci"))))
;; -> integer or false

(define (string-titlecase::bstring s #!optional start end)
  (with-optional-range
   "string-titlecase" s start end
   (let((s(substring s start end)))
     (string-titlecase! s)
     s)))

(define (string-titlecase! s #!optional start end)
  (with-optional-range
   "string-titlecase!" s start end
   (define (char-cased? ch)(not (char=? (char-upcase ch)(char-downcase ch))))
   (let loop ((i start))
     (cond ((string-index s char-cased? i end) =>
	    (lambda (i)
	      (string-set! s i (char-upcase (string-ref s i)))
	      (let ((i1 (+ i 1)))
		(cond ((string-skip s char-cased? i1 end) =>
		       (lambda (j)
			 (string-downcase! s i1 j)
			 (loop (+ j 1))))
		      (else (string-downcase! s i1 end))))))))))

(define (string-upcase::bstring s #!optional start end)
  (list->string
   (map char-upcase
	(string->list
	 (substring/shared s start end)))))
;;(string-upcase "asdf" 0)

(define (string-upcase! s #!optional start end)
  (with-optional-range
   "string-upcase!" s start end
   (let loop((start start))
     (when (<fx start end)
	   (string-set! s start
			(char-upcase(string-ref s start)))
	   (loop(+fx start 1))))))

(define (string-downcase::bstring s #!optional start end)
  (list->string
   (map char-downcase
	(string->list
	 (substring/shared s start end)))))

(define (string-downcase! s #!optional start end)
  (with-optional-range
   "string-downcase!" s start end
   (let loop((start start))
     (when (<fx start end)
	   (string-set! s start
			(char-downcase(string-ref s start)))
	   (loop(+fx start 1))))))

(define (string-reverse::bstring s #!optional start end)
  (with-optional-range
   "string-reverse" s start end
   (unimplemented "string-reverse")))

(define (string-reverse! s #!optional start end)
  (with-optional-range
   "string-reverse!" s start end
   (unimplemented "string-reverse!")))

(define (string-concatenate::bstring string-list::pair-nil)
  (apply string-append string-list))

(define (string-concatenate/shared::bstring string-list::pair-nil)
  (cond((null? string-list)
	"")
       ((null?(cdr string-list))
	(car string-list))
       (else
	(string-concatenate string-list))))

(define (string-append/shared::bstring . string-list)
  (apply string-concatenate/shared string-list))

(define (reverse-string-concatenate::bstring string-list #!optional final-string end)
  (unimplemented "reverse-string-concatenate"))

(define (reverse-string-concatenate/shared::bstring string-list #!optional final-string end)
  (unimplemented "reverse-string-concatenate/shared"))

(define (string-map::bstring proc s #!optional start end)
  (string-map! proc (string-copy s start end)))

(define (string-map! proc s #!optional start end)
  (with-optional-range
   "string-map!" s start end
   (let loop((start start))
     (when(<fx start end)
	  (string-set! s start
		       (proc(string-ref s start)))
	  (loop(+fx start 1)))
     s)))

(define (string-fold kons knil s #!optional start end)
  (with-optional-range
   "string-fold" s start end
   (unimplemented "string-fold")))

(define (string-fold-right kons knil s #!optional start end)
  (with-optional-range
   "string-fold-right" s start end
   (unimplemented "string-fold-right")))

(define (string-unfold::bstring p f g seed #!optional base make-final)
  (unimplemented "string-unfold"))

(define (string-unfold-right::bstring p f g seed #!optional base make-final)
  (unimplemented "string-unfold-right"))

(define (string-for-each proc s #!optional start end)
  (with-optional-range
   "string-for-each" s start end
   (unimplemented "string-for-each")))

(define (xsubstring::bstring s from #!optional to start end)
  (with-optional-range
   "xsubstring" s start end
   (unimplemented "xsubstring")))

(define (string-xcopy! target tstart s sfrom #!optional sto start end)
  (with-optional-range
   "string-xcopy!" s start end
   (unimplemented "string-xcopy!")))

(define (string-replace::bstring s1 s2 start1 end1 #!optional start2 end2)
  (with-optional-range
   "string-replace" s2 start2 end2
   (string-append (substring/shared s1 0 start1)
		  (substring/shared s2 start2 end2)
		  (substring/shared s1 end1 (string-length s1)))))

(define (string-tokenize s #!optional token-set start end)
  (with-optional-range
   "string-tokenize" s start end
   (let((reversed-token-set (out token-set)))
     (reverse
      (let loop ((index start)
		 (accu '()))
	(let((next-token-start(string-index s token-set index end)))
	  (if next-token-start
	      (let((next-token-end
		    (string-index s reversed-token-set next-token-start end)))
		(if next-token-end
		    (loop 
		     next-token-end
		     (cons (substring/shared s next-token-start next-token-end)
			   accu))
		    (cons (substring/shared s next-token-start)accu)))
	      accu)))))))

;;(string-tokenize "asdfasdfaaaasdfa" (lambda(c)(char=? c #\a)))

(define (string-filter::bstring s char/char-set/pred #!optional start end)
  (with-optional-range
   "string-filter" s start end
   (let((buffer(make-string (-fx end start)))
	(proc(in char/char-set/pred)))
     (let loop((start start)
	       (i 0))
       (if(<fx start end)
	  (let((ch(string-ref s start)))
	    (if(proc ch)
	       (begin
		 (string-set! buffer i ch)
		 (loop(+fx start 1)(+fx i 1)))
	       (loop(+fx start 1)i)))
	  (substring/shared buffer 0 i))))))

(define (string-delete::bstring s char/char-set/pred #!optional start end)
  (string-filter s (out char/char-set/pred) start end))

(define (string-parse-start+end proc s args)
  (unimplemented "string-parse-final-start+end"))

(define (string-parse-final-start+end proc s args)
  (unimplemented "string-parse-final-start+end"))

(define (check-substring-spec proc s start end)
  (unimplemented "check-substring-spec"))

(define (substring-spec-ok?::bool s start end)
  (unimplemented "substring-spec-ok?"))

(define (make-kmp-restart-vector::vector c= s #!optional start end)
  (with-optional-range
   "make-kmp-restart-vector" s start end
   (unimplemented "make-kmp-restart-vector")))

(define (kmp-step pat rv c= c i)
  ;; -> bool or integer
  (unimplemented "kmp-step"))

(define (string-search-kmp::int pat rv c= i s #!optional start end)
  (with-optional-range
   "string-search-kmp" s start end
   (unimplemented "string-search-kmp")))

