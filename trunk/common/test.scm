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

(module test
	(include "../test.sch")
	(library common)
)

*common-version*

;; object-data-... test
(begin
  (object-data-set! "the-key" 1 'first)
  (object-data-set! (string-copy "the-key") 2 'second)
  (test(object-data-get "the-key" 'second) 2 "object-data-get")
  (test(object-data-get "the-key" 'first) 1 "object-data-get")
  (object-data-free! "the-key")
  )

;*-------------------------------------------------------------------*;
;*  srfi-1                                                           *;
;*-------------------------------------------------------------------*;
(test(pair-fold-right cons '() '(a b c)) '((a b c) (b c) (c)) "pair-fold-right")
(test(lset-xor string=? '("a") '("a")) '() "bug in referrence implementation of lset-xor")

;*-------------------------------------------------------------------*;
;*  srfi-13                                                          *;
;*-------------------------------------------------------------------*;
(define  (string-lib-test)
  (msg-checking "string-lib (srfi-13)")
  (test(and(string-null? "")
	   (not(string-null? "qwerty")))
       #t "string-null?")
  (test(string-every values "qwerty")
       #\y "string-every")
  (test(string-any values "qwerty")
       #\q "string-any")
  (test(string-tabulate (lambda(n)(string-ref(number->string n)0)) 9)
       "012345678" "string-tabulate")

;;  (test(string->list "asdf" 1 2)
;;       '(#\s) "string-list")
  (test(reverse-list->string '(#\a #\B #\c))
       "cBa" "reverse-list->string")

  (test(string-join '("foo" "bar" "baz") ":") "foo:bar:baz"
       "string-join infix")
  (test(string-join '("foo" "bar" "baz") ":" 'suffix) "foo:bar:baz:"
       "string-join suffix")
  (test(string-join '()   ":") ""
       "string-join empty list")
  (test(string-join '("")   ":") ""
       "string-join empty string")
  (test(string-join '()   ":" 'suffix) ""
       "string-join empty list suffix grammar")
  (test(string-join '("") ":" 'suffix) ":"
       "string-join empty string suffix grammar")

  (test(string-copy "Beta substitution")
       "Beta substitution"
       "string-copy the whole string")
  (test(string-copy "Beta substitution" 1 10)
       "eta subst"
       "string-copy the range")
  (test(string-copy "Beta substitution" 5)
       "substitution"
       "string-copy from")

  (test(let((s "Beta substitution"))
	 (eq?(substring/shared s 0)s))
       #t
       "substring/shared the whole string")

  
  (test(string-copy! (string-copy "qwerty") 2 "asdf")
       "qwasdf"
       "string-copy!")
  (test(string-take "Pete Szilagyi" 6) "Pete S" "string-take")
  (test(string-drop "Pete Szilagyi" 6) "zilagyi" "string-drop")
  (test(string-take-right "Beta rules" 5) "rules" "string-take-right")
  (test(string-drop-right "Beta rules" 5) "Beta " "string-drop-right")
  (test(string-pad     "325" 5) "  325" "string-pad")
  (test(string-pad   "71325" 5) "71325" "string-pad")
  (test(string-pad "8871325" 5) "71325" "string-pad")
  (test(string-pad-right     "325" 5) "325  " "string-pad-right")
  (test(string-pad-right   "71325" 5) "71325" "string-pad-right")

  (test(string-trim " \r\n\tassdf \r\n\t") "assdf \r\n\t" "string-trim")
  (test(string-trim " \r\n\t") "" "string-trim blank string")
  (test(string-trim-right " \r\n\tassdf \r\n\t") " \r\n\tassdf" "string-trim-right")
  (test(string-trim-right " \r\n\t") "" "string-trim-right blank string")
  (test(string-trim-both " \r\n\tassdf \r\n\t") "assdf" "string-trim-both")
  (test(string-trim-both " \r\n\t") "" "string-trim-both blank string")

  (test(string-filter "asadaf" #\a) "aaa" "string-filter by char")
  (test(string-filter "asdf1234" (lambda(ch)(char>? ch #\a))) "sdf"
       "string-filter by predicate")
  (test(string-delete "asadaf" #\a) "sdf" "string-delete by char")
  (test(string-delete "asdf1234" (lambda(ch)(char>? ch #\a))) "a1234"
       "string-delete by predicate")

  (test(string-contains "a" "") 0 "string-contains")
  (test(string-contains "a" "a") 0 "string-contains")
  (test(string-contains "asdf" "asdf") 0 "string-contains")
  (test(string-contains "" "a") #f "string-contains")
  (test(string-contains "asdfqwerty" "asdf") 0 "string-contains")
  (test(string-contains "qwertyasdf" "asdf") 6 "string-contains")
  (test(string-contains "qwertyasdfqwerty" "asdf") 6 "string-contains")
  (test(string-contains "asdqweasdrtyasdfqwerty" "asdf") 12 "string-contains")

  (test(string-titlecase "hello, world") "Hello, World" "string-contains")
  )

(string-lib-test)

;*-------------------------------------------------------------------*;
;*  REGEXPS                                                          *;
;*-------------------------------------------------------------------*;
(define  (regexp-test)
  (msg-checking "regular expressions")
  (test(regexp?(regexp "q")) #t "regexp")

  ;;case insensitive match

  (test(regexp-match(regexp "qwerty" 'icase) "QWERTY")
       '("QWERTY")
       "case insensitive match")
  
  ;;Basic regexp match
  (test
   (regexp-match(regexp "a|b" 'basic) "a|b")
   '("a|b")
   "basic regexps")
  
  ;;Extended regexp match
  (test
   (regexp-match(regexp "a|b") "a|b")
   '("a")
   "basic regexps")

  (test
   (regexp-replace* "a|b" "asdfb" "X")
   "XsdfX"
   "replace regexps")
  )

(regexp-test)

;;Using of @code{nosub} flag example:
;;
;;@example
;;(define rexp(regexp "qwerty" '(nosub)))
;;(regexp-match rexp "qwerty")
;;@result{} ()

;;(regexp-match "q" "asdf")
;;@result{} #f
;;(regexp-match "q" "qwerty")
;;@result{} (q)
;;(regexp-match "([a-z]+)([0-9]+)" "qwerty1234")
;;@result{} (qwerty1234 qwerty 1234)
;;@end example
;;
;;The optional argument @var{offset} allows to skip first @var{offset} characters from the beginning of matched string, for example:
;;
;;@example
;;(regexp-match "[a-z]+" "qwerty")  ;; offset=0
;;@result{} (qwerty)
;;(regexp-match "[a-z]+" "qwerty" 2)
;;@result{} (erty)
;;@end example
;;
;;@end deffn
;;
;;The optional @code{eflag} argument must be a list with any of the
;;following symbols :
;;
;;@table @r
;;@item notbol
;;The match-beginning-of-line operator always fails to match (but see the
;;compilation flag @code{newline} above). This flag may be used when
;;different portions of a string are passed to regexec and the beginning
;;of the string should not be interpreted as the beginning of the line.
;;
;;@item noteol
;;The match-end-of-line operator always fails to match (but see the
;;compilation flag @code{newline} above)
;;@end table
;;
;;@example
;;(define rexp(regexp "^qwerty"))
;;(regexp-match rexp "qwerty")  ;; BOL matches as usual
;;@result{} ("qwerty")
;;
;;(regexp-match-positions rexp "qwerty" 0 '(notbol))
;;@result{} #f                  ;; BOL match suppressed
;;@end example
;;
;;@c ==================================================================
;;@deffn {procedure} regexp-match-positions pattern rexp-or-string str::bstring #!optional offset::int @result{} #f or pair
;;
;;Same as @code{regexp-match}, but returns the matched substrings position
;;inside the source string instead of substrings itself, for example:
;;
;;@example
;;(regexp-match-positions "q" "asdf")
;;@result{} #f
;;(regexp-match-positions "q" "qwerty")
;;@result{} ((0 . 1))
;;(regexp-match-positions "([a-z]+)([0-9]+)" "qwerty1234")
;;@result{} ((0 . 10) (0 . 6) (6 . 10))
;;@end example
;;

;*-------------------------------------------------------------------*;
;*  TIME                                                             *;
;*-------------------------------------------------------------------*;
(define  (time-test)
  (msg-checking "time-related procedures")
  (test(tm?(make-tm))             #t "make-tm")
  (test
   (let((tm (gmtime #e100000000)))
     (and(=(tm-sec tm)40)
	 (=(tm-min tm)46)
	 (=(tm-hour tm)9)
	 (=(tm-mday tm)3)
	 (=(tm-mon tm)2)
	 (=(tm-year tm)73)))
   #t
   "gmtime")

#|
  This doesn't work with cygwin the timezone-related variables are set to tzname=GMT, timezone=5353840

  (test
   (let*((dummy (localtime 0))
	 (tm (localtime (+ #e100000000 (timezone)))))
     (and(= (tm-sec tm)40)
	 (= (tm-min tm)46)
	 (= (tm-hour tm)9)
	 (= (tm-mday tm)3)
	 (= (tm-mon tm)2)
	 (= (tm-year tm)73)))
   #t
   "localtime and timezone")
|#

  (test
   (let((name (tzname)))
     (and (string? name)
	  (= (string-length name)3)))
   #t
   "tzname")

  (test
   (strftime (gmtime #e100000000)"%d/%m/%Y %H:%M:%S")
   "03/03/1973 09:46:40"
   "strftime")

  (test (> (current-seconds) 956000118) #t "current-seconds")

;; The test must by rewritten without using the (timezone) call which
;; doesn't work on cygwin

;;  (test (ctime (+ #e100000000.0 (timezone))) "Sat Mar  3 09:46:40 1973" "ctime")
  (test (strftime (mktime 2000 10 20 23 20 20)"%d/%m/%Y %H:%M:%S")
       "20/10/2000 23:20:20"
       "mktime")
  (test(strftime(read-date
		 "%Y%m%d%H%M%S"
		 (open-input-string "20000416233814"))
		"%d/%m/%Y %H:%M:%S")
       "16/04/2000 23:38:14"
       "read-date")
  (test(strftime(read-date"%y"(open-input-string "12"))
		"%Y")
       "2012"
       "read-date %y spec")
  )

(time-test)

(define(dl-test)
;; FIXME: I do not know how to test dlopen in a portable way
;;  (test(dl?(dlopen "")) #t "dlopen")
  #unspecified
  )

(cond-expand (dl (dl-test))
	     (else (print "dl functions are disabled by configure")))

(define (iconv-test)
  (msg-checking "charset conversion procedures")
  (test
   ((make-iconv-encoder "KOI8-R" "UTF-8")
    "АОЗТ Инфосистемы Джет")
   "\320\220\320\236\320\227\320\242 \320\230\320\275\321\204\320\276\321\201\320\270\321\201\321\202\320\265\320\274\321\213 \320\224\320\266\320\265\321\202"
   "KOI8-R to UTF-8")
  (test
   ((make-iconv-encoder "UTF-8" "KOI8-R")
    "\320\220\320\236\320\227\320\242 \320\230\320\275\321\204\320\276\321\201\320\270\321\201\321\202\320\265\320\274\321\213 \320\224\320\266\320\265\321\202")
   "АОЗТ Инфосистемы Джет"
   "UTF-8 to KOI8-R")
;  (test
;    ((make-iconv-encoder "KOI8-R" "UTF-8")
;     "АОЗТ Инфосистемы Джет"
;     from: 4)
;    " \320\230\320\275\321\204\320\276\321\201\320\270\321\201\321\202\320\265\320\274\321\213 \320\224\320\266\320\265\321\202"
;    "iconv with non-default from: argument")
;   (test
;    ((make-iconv-encoder "KOI8-R" "UTF-8")
;     "АОЗТ Инфосистемы Джет"
;     to: 4)
;    "\320\220\320\236\320\227\320\242"
;    "iconv with non-default to: argument")
;  (test
;   ((make-iconv-encoder "KOI8-R" "UTF-8")
;    "The quoted char '\232' will be replaced by dot"
;    onerror:
;    (lambda(str offset port)
;      (display "." port)
;      1))
;   "The quoted char '.' will be replaced by dot"
;   "handle invalid multibyte sequence using onerror:")
  )

(cond-expand (iconv (iconv-test))
	     (else (print "iconv functions are disabled by configure")))

(define (curl-test)
  (let*((os(open-output-string))
	(curl
	 (curl-easy-init
	  url: "file://Makefile"
	  writefunction:
	  (lambda(s::bstring)
	    (display s os)
	    (string-length s)))))
    (curl-easy-perform curl)
    (test
     (get-output-string os)
     (file-contents "Makefile")
     "curl file reading")
    (curl-easy-cleanup curl)
    (curl-global-cleanup)
    ))

(msg-checking "CURL interface")
(cond-expand (curl (curl-test))
	     (else (print "CURL support is disabled by configure")))

;;(test(regexp-match-positions  "/tmp/etl??????" (mktemp "/tmp/etlXXXXXX")) '((0 . 8)) "mktemp")

(define (environ-test)
  (setenv "qwerty" "asdf")
  (test (getenv "qwerty") "asdf"
	"setenv/getenv")
  (test-true
   (member  (cons "qwerty" "asdf")
	    (environ))
   "environ")
  )

(msg-checking "environment procedures")
(environ-test)

;; md5
(test (string->hex (md5 "qwerty"))
      "d8578edf8458ce06fbc5bb76a58c5ca4"
      "md5")
(test (string->hex (md5 "asdfqwertyasdf" 4 10))
      "d8578edf8458ce06fbc5bb76a58c5ca4"
      "md5 with offsets")
