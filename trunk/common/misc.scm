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
 misc
 (import
  (srfi-1 "srfi-1.scm")
  ;; for string-null?
  (string-lib "string-lib.scm")
  )
 
 (include "common.sch")
 (export
  CR
  LF
  CRLF
  SP
  HT
  WSL
  WS
  (false . args)
  (true . args)
  (split-if1 l selector::procedure)
  (split-if l . selectors)
  (reject-if proc list)
  (detect-if proc l)
  (transpose l)
  (map-delimited proc thunk . lists)
  (for-each-delimited proc thunk . lists)
  (repeat times thunk)
  (string-blank? s::bstring) ;; #t if string has only whitespaces
  (capitalize str::bstring)
  (proc-output::bstring proc::procedure . args)
  (list->path::bstring pathelems)
  path->list::procedure
  (print-list-delimited::bstring list #!optional
                                 (delim "")
                                 (display display))
  (alist-lookup ::obj name)
  (alist-set! ::obj name value)
  (alist-remove! ::obj name)
  (alist-put! ::obj key value)
  (flatten-list ::obj)
  (assoc-flatten ::obj)
  group::procedure
  (split-path path::bstring)
  (mkdir ::bstring #!optional mask)
  (inline quick-sort ::obj ::procedure)
  (quick-sort-by-weight ::obj ::procedure)
  (make-port-reader delim)

  (list-subtract l1 l2) ;; srfi-1 ?
;;  (with-current-directory dir::bstring thunk::procedure)
  (position-of x lst) ;; srfi-1 ?
  (map-append proc::procedure . lists) ;; srfi-1 ?
  (getenv-mandatory varname::bstring)

  (make-stack::procedure)
  (with-input-from-process cmdlist::pair proc::procedure)
  ;;(do-all-replacements-list str::bstring rexp-list)
  ;;(do-all-replacements str::bstring . rexp-list)

  (map-cdr proc::procedure l::pair-nil)
  (map-car proc::procedure l::pair-nil)
  (map-cdr! proc::procedure l::pair-nil)
  (map-car! proc::procedure l::pair-nil)

  (alist-flatten alist::pair-nil) ;; srfi-1 ?
  (alist-group alist::pair-nil) ;; srfi-1 ?

  (string-after s::bstring delim::char) ;; srfi-13 ?
  (string-before::bstring s::bstring delim::char) ;; srfi-13 ?
  (string-split-by::pair-nil s::bstring delim::char) ;; srfi-13 ?
  (string-split-by-string haystack::bstring needle::bstring) ;; srfi-13 ?

  (tree-lookup!::pair t::pair path::pair-nil)
  (tree-set!::pair t::pair path::pair o)
  (tree-lookup::pair-nil t::pair path::pair-nil)
  (tree-for-each proc::procedure t::pair-nil)

  (alist-for-each proc::procedure alist::pair-nil)
  (alist-map::pair-nil proc::procedure alist::pair-nil)

  (trace level . args)
  *trace-level*
  (car-eq? p1::pair p2::pair)
  (string->hex::bstring s::bstring)
  (sort-hierarchical! l::pair-nil
		      getkey::procedure
		      getparentkey::procedure)
  (ptr->0..255::int o)
  (list->carray::foreign lyst::pair-nil foreign-id::symbol)
  (coerce! type-name::symbol o)

  ;; This should be obsoleted by object-data-... functions
  ;;   (object-lookup o)
  ;;   (object-ref o . finalizers)
  ;;   (object-unref o)

;;   (pair->0..2^x-1::int o::obj p::int)
;;   (pair->0..255 o::obj)

  (scheme-read-string s::string)
;  (string*->string-list::pair-nil sp::string* #!optional len)
;  (string-list->string*::string* sl::pair-nil)

;;   (object-data-get o #!optional selector)
;;   (object-data-set! o data #!optional selector)
;;   (object-data-free! o)

  ;; *object-data-registry* ;; FIXME: do not export it when properly tested

  (grove-walk node-list::pair-nil transition::procedure #!optional
              (collected::pair-nil '()))
  ;;(add-printer isa?::procedure display::procedure)
  )
 (extern
  ;;(export object-unref "object_unref")
  )
 (extern(include "string.h")))
;*-------------------------------------------------------------------*;
;*  Convenience prims                                                *;
;*-------------------------------------------------------------------*;
(define CR               (string #\return))
(define LF               (string #\newline))
(define CRLF             (string-append CR LF))
(define SP               (string #\space))
(define HT               (string #\tab))
(define WSL		 (list #\space #\tab #\newline #\return))
(define WS		 (apply string WSL))

(define (false . args)#f)
(define (true . args)#t)
(define identity values)

;*-------------------------------------------------------------------*;
;*  Control flow                                                     *;
;*-------------------------------------------------------------------*;

(define (split-if1 l selector)
  (let loop((l l)(selected '())(rejected '()))
    (if(null? l)
       (list (reverse selected)(reverse rejected))
       (if(selector(car l))
	  (loop(cdr l)(cons(car l)selected)rejected)
	  (loop(cdr l)selected(cons(car l)rejected))))))

;;(split-if1 '("a" b 1 "c" "d" e 3) string?)

(define (split-if l . selectors)
  (let sloop((l l)(s selectors)(accu '()))
    (if(null? s)
       (reverse(cons l accu))
       (let((selector(car s)))
	 (let loop((l l)(selected '())(rejected '()))
	   (if(null? l)
	      (sloop(reverse rejected)(cdr s) (cons(reverse selected) accu))
	      (if(selector(car l))
		 (loop(cdr l)(cons(car l)selected)rejected)
		 (loop(cdr l)selected(cons(car l)rejected)))))))))

;;(split-if '("a" b 1 "c" "d" e 3) string? number?)

(define (reject-if proc list)
  (cadr(split-if list proc)))

;(reject-if string? '(1 2 3 "asd" 4 "zxc"))

(define (detect-if proc l)
  (let loop((l l))
    (cond((null? l)#f)
	 ((proc(car l))(car l))
	 (else(loop(cdr l))))))
;;(detect-if string? '(1 2 3 "a" "b"))

(define (transpose l)
  [assert(l)(list? l)]
  (let loop((l l)(accu '()))
    (if(null? (car l))
       (reverse accu)
       (loop (map cdr l)(cons(map car l)accu)))))
;;(transpose '((1 2 3)(4 5 6)))

(define (map-delimited proc thunk . lists)
  (let loop((l (transpose lists))
	    (accu '()))
    (if(null? l)
       (reverse accu)
       (let((value (cons(apply proc(car l))accu)))
	 (loop(cdr l)
	      (if(null?(cdr l))
		 value
		 (cons (thunk) value)))))))
;(map-delimited(lambda(a b)(+ a b))false '(1 2 3) '(4 5 6))

(define (for-each-delimited proc thunk . lists)
  (let loop((l (transpose lists)))
    (unless(null? l)
 	   (apply proc(car l))
 	   (unless(null?(cdr l))(thunk))
 	   (loop(cdr l)))))
;(for-each-delimited(lambda(a b)(display(+ a b)))(lambda()(display ", ")) '(1 2 3) '(4 5 6))

(define (repeat times thunk)
  (let loop((times times))
    (let((res(thunk)))
      (if(> times 1)
	 (loop(-fx times 1))
	 res))))
;(repeat 10 newline)

(define (string-blank? s)
  (read/rp (regular-grammar
    ()
    ((out blank)
     #f)
    (else
     (or(eof-object?(the-failure))
	(ignore))))
   (open-input-string s)))
;;(string-blank? "  s")

(define (capitalize str::bstring)
  (if (string-null? str)
      str
      (string-append (string-upcase (substring str 0 1))
		     (substring str 1(string-length str)))))
;;(capitalize "вовочка")
;;(capitalize "hello")

(define (string-after s::bstring delim::char)
  (let((found (pragma::string "strchr($1, $2)"
			      ($bstring->string s)
			      delim)))
    (and (pragma::bool "($1 != 0L)" found)
         ($string->bstring (pragma::string "$1 + 1" found)))))
;;(string-after "asdf.qwerty.zxcv" #\.)
;;(string-after "asdf.qwerty.zxcv" #\,)

(define (string-before::bstring s::bstring delim::char)
  (let((found(pragma::string "strchr($1, $2)"
			     ($bstring->string s)
			     delim)))
    (if(pragma::bool "($1 == 0L)" found)
       s
       (substring s 0 (pragma::int "$1 - $2" found
				   ($bstring->string s))))))
;;(string-before "asdf.qwerty.zxcv" #\.)
;;(string-before "asdf.qwerty.zxcv" #\,)

(define (string-split-by::pair-nil s::bstring delim::char)
  (let loop((p s)(accu '()))
    (let*((ps($bstring->string p))
	  (found(pragma::string "strchr($1, $2)" ps delim)))
      (if(pragma::bool "($1 == 0L)" found)
	 (reverse(cons p accu))
	 (loop
	  (pragma::string "$1+1"found)
	  (cons
	   (pragma::bstring "string_to_bstring_len($1,$2)"
			    ps (pragma::int "$1 - $2" found ps))
	   accu))))))
;;(pp(string-split-by "asdf.qwerty.zxcv" #\.))

(define (string-split-by-string haystack::bstring needle::bstring)
  (let*((needle-size(string-length needle))
	(needle-c($bstring->string needle)))
    (let loop((p haystack)(accu '()))
      (let*((ps($bstring->string p))
	    (found(pragma::string "strstr($1, $2)" ps needle-c)))
	(if(pragma::bool "($1 == 0L)" found)
	   (reverse(cons p accu))
	   (loop
	    (pragma::string "$1+$2"found needle-size)
	    (cons
	     (pragma::bstring "string_to_bstring_len($1,$2)"
			      ps (pragma::int "$1 - $2" found ps))
	     accu)))))))

(define (path->list s)
  (reverse(string-split-by s #\/)))
;(pp(path->list "q/a/b/c")) => (#"c" #"b" #"a" #"q")

(define (list->path::bstring pathelems)
  (print-list-delimited 
   (map
    (lambda(strorsym)
      (if(symbol? strorsym)
	 (symbol->string strorsym)
	 strorsym))
    (reverse pathelems))
   "/"))
;;;(list->path (path->list "/a/b/c"))
;;;(list->path '("a" "b" "c"))
;
(define (proc-output proc . args)
  (let((os(open-output-string)))
    (with-output-to-port
     os
     (lambda()(apply proc args)))
    (get-output-string os)))
;(proc-output printf "<~a>" 1)
;
(define (print-list-delimited
	lst
	#!optional
	(delim "")
	(display display))
  (proc-output
   (lambda(l)
     (for-each-delimited
      display
      (lambda()(display delim))
      l))
   lst))
;(print-list-delimited '(1 2 3) ", ")

;*-------------------------------------------------------------------*;
;*  assoc-list manipulation                                          *;
;*-------------------------------------------------------------------*;
(define (alist-lookup alist name)
  (cond ((assq name alist) => cdr)
	(else #f)))

(define (alist-set! alist name value)
  (let((bucket (assq name alist)))
    (if bucket
	(begin
	  (set-cdr! bucket value)
	  alist)
	(cons (cons name value)
	      alist))))

(define (alist-remove! alist name)
  (reject-if
   (lambda(bucket)
     (eq? (car bucket) name))
   alist))

;;append value to existing assoc or make new entry

(define (alist-put! l key value)
  (let((ass(assq key l)))
    (if ass
	(begin
	  (set-cdr! ass(cons value(cdr ass)))
	  l)
	(cons(list key value)l))))
;(alist-put! '((1 2)(3 4))6 3)
;(alist-put! '((1 2)(3 4))1 3)

(define (flatten-list l)
  (cond((not(list? l))
	(list l))
       ((null? l)
	'())
       (else(append(flatten-list(car l))(flatten-list(cdr l))))))

;(flatten-list '((1 2)(3 4)))

(define (assoc-flatten asslist)
  (apply append
	 (map
	  (lambda(ass)
	    (if(list? ass)
	       (map
		(lambda(value)(list (car ass)value))
		(cdr ass))
	       (list ass)))
	  asslist)))
;;(assoc-flatten '((a b c)d (e f)))

(define group 
  (case-lambda
   ((l)(group l identity))
   ((l proc)
    (let loop ((l l)(subseq '())(seq '()))
      (if (null? l)
	  (reverse (cons subseq seq))
	  (if (or (null? subseq) (equal? (proc (car l)) (proc (car subseq))))
	      (loop (cdr l) (cons (car l) subseq) seq)
	      (loop (cdr l) (list (car l)) (cons subseq seq))))))))
;(group '(1 1 2 3 1))

;*-------------------------------------------------------------------*; Filenames & Files
;*  Filesystem                                                       *;
;*-------------------------------------------------------------------*;
;; WARNING: not fully compliant with mzscheme
(define (split-path path::bstring)
  (cond((string-null? path)
	(error "split-path" "pathname is an empty string" path))
       ((string=? path "/")
	(values #f "/" #t))
       (else
	(let*((dir (dirname path))
	      (base (basename path)))
	  (values
	   (if(string-null? dir)
	      'relative
	      dir)
	   (basename path)
	   (eq? '/ (string-ref path (-fx(string-length path)1))))))))
;;(let-values(((a b c)(split-path "aaa/")))(printf "~s ~s ~s"a b c))

;*-------------------------------------------------------------------*;
;* Make directory recursive                                          *;
;*-------------------------------------------------------------------*;
(define (mkdir path #!optional mask)
  (let loop((path path))
    (unless (directory? path)
	    (let ((dn (dirname path)))
	      (loop dn)
	      (let((path::string path)
		   (mask::int (or mask #o0777))
		   (result::bool (pragma::bool "0")))
		(pragma
		 "
#if MKDIR_ACCEPTS_MODE
  $3 = mkdir($1, $2);
#else
  $3 = mkdir($1);
  chmod($1, $2);
#endif
"		 path mask result)
		
		(when result
		      (error "mkdir" "cannot make directory" path)))))))
;;(mkdir "/home/wowa/jet.projects/tmp/tmp/a/b/c")
;;(mkdir "a/b/c")

;*-------------------------------------------------------------------*;
;*  Sorting & Grouping                                               *;
;*-------------------------------------------------------------------*;
(define-inline(quick-sort l lessthan)
  (sort l lessthan))
;(quick-sort '(1 5 3 6) >)

(define (quick-sort-by-weight l getweight)
  (sort l(lambda(a b)(<(getweight a)(getweight b)))))
;;(quick-sort-by-weight '(1 5 3 6) values)

;*-------------------------------------------------------------------*;
;*  Accumulate characters while condition met                        *;
;*-------------------------------------------------------------------*;
;; delim may be a char, list of chars, string with all the chars or
;; procedure of one argument

(define (make-port-reader delim)
  (let((condition
	(cond((procedure? delim)delim)
	     ((char? delim)
  	      (lambda(ch)(eq? ch delim)))
	     ((list? delim)
  	      (lambda(ch)(memq ch delim)))
	     ((string? delim)
	      (make-port-reader(string->list delim))))))
    (letrec((proc
	     (case-lambda
	      (()(proc(current-input-port)))
	      ((port)
	       (let loop((accu '()))
		 (let((next(peek-char port)))
		   (if(and(not(eof-object? next))(condition next))
		      (loop(cons(read-char port)accu))
		      (list->string(reverse accu)))))))))
      proc)))

(define (list-subtract l1 l2)
  (let loop((l1 l1)(l2 l2)(accu '()))
    (if(or(null? l1)(null? l2)(not(equal?(car l1)(car l2))))
       (values l1 l2 (reverse accu))
       (loop(cdr l1)(cdr l2)(cons(car l1)accu)))))
;(list-subtract '(1 2 3) '(1 2 4))

;;(define (with-current-directory dir thunk)
;;  (parameterize((current-directory dir))
;;     (thunk)))

;(with-current-directory "/var/adm" directory-list)
(define (position-of x lst)
   (list-index (lambda(e)(eq? e x))lst))
;;(position-of 1 '(43 2 1 2 3 4))
;;(position-of 5 '(43 2 1 2 3 4))

(define (map-append proc . lists)
  (apply append (apply map (cons proc lists))))

;(define (every test . lists)
;  (let scan ((tails lists))
;    (if (member #t (map null? tails))             ;(any null? lists)
;	#t
;	(and (apply test (map car tails))
;	     (scan (map cdr tails))))))
;;(every string? '( "a" "s" 1))

(define (getenv-mandatory varname)
  (or (getenv varname)
      (error "getenv-mandatory" "Variable is not set" varname)))

(define (make-stack)
  (let((stack '()))
    (case-lambda
     (() stack)
     ((item)(set! stack(cons item stack))))))
;;(let((s(make-stack)))(s 1)(s 2)(s))

(define (with-input-from-process cmdlist proc)
  (let*((process(apply run-process (append cmdlist '(output: pipe:))))
	(input(process-output-port process)))
    (unwind-protect
     (with-input-from-port input proc)
     (close-input-port input))))

;; apply proc to cdr of each pair
(define (map-cdr proc::procedure l::pair-nil)
  (map
   (lambda(ass)
     (cons(car ass)(proc(cdr ass))))
   l))
;(pp(map-cdr symbol->string '((a . b)(c . d))))

;; apply proc to car of each pair
(define (map-car proc::procedure l::pair-nil)
  (map
   (lambda(ass)
     (cons(proc(car ass))(cdr ass)))
   l))
;(pp(map-car symbol->string '((a . b)(c . d))))

;; apply proc to cdr of each pair
(define (map-cdr! proc::procedure l::pair-nil)
  (for-each
   (lambda(ass)
     (set-cdr! ass(proc(cdr ass))))
   l)
  l)
;(pp(map-cdr! symbol->string '((a . b)(c . d))))

;; apply proc to car of each pair
(define (map-car! proc::procedure l::pair-nil)
  (for-each
   (lambda(ass)
     (set-car! ass(proc(car ass))))
   l)
  l)
;(pp(map-car! symbol->string '((a . b)(c . d))))

(define (alist-flatten alist::pair-nil)
  (map-append
   (lambda(chunk)
     (let((c(car chunk)))
       (map
	(lambda(v)(cons c v))
	(cdr chunk))))
   alist))

;;(alist-flatten '((a 1 2 3)(b 4 5 6)))

(define (alist-group alist::pair-nil)
  (let loop ((l alist)
	     (accu '()))
    (if(null? l)
       (map-cdr reverse (reverse accu))
       (loop
	(cdr l)
	(let*((ass(car l))
	      (key(car ass))
	      (val(cdr ass))
	      (found(assq key accu)))
	  (if found
	      (begin
		(set-cdr! found(cons val(cdr found)))
		accu)
	      (cons (list key val) accu)))))))

;;(alist-group(alist-flatten '((a 1 2 3)(b 4 5 6))))

;; возвращает пару, cdr которой является списком значений
;; его можно читать и писать
;; исходное дерево может быть модифицировано в процессе поиска

;; параметр t всегда должен быть парой, поиск ведется по его cdr

(define (tree-lookup! t path)
  (if(null? path)
     t
     (let*((rdn (car path))
	   (rest (cdr path))
	   (found (assoc rdn (cdr t))))
       (if found
	   (tree-lookup! found rest)
	   (let((ne(list rdn)))
	     (append! t(list ne))
	     (tree-lookup! ne rest))))))

(define (tree-set! t::pair path::pair o)
  (append!
   (tree-lookup! t path)
   (list o)))

;; read-only версия tree-lookup!
;; возвращает список значений или null

;; параметр t всегда должен быть парой, поиск ведется по его cdr

(define (tree-lookup t path)
  (cdr
   (let loop((t t)
	     (path path))
     (if(pair? path)
	(let*((rdn (car path))
	      (rest(cdr path))
	      (found (assoc rdn (cdr t))))
	  (if found
	      (loop found rest)
	      '(dummy)
	      ))
	t))))

(define (tree-for-each proc::procedure t::pair-nil)
  (let loop((t t)(prefix '()))
    (for-each
     (lambda(t)
       (if(pair? t)
	  (loop t(cons(car t)prefix))
	  (proc t(reverse prefix))))
     (cdr t))))

;;(tree-for-each(lambda(t p)(print "t: "t" p: "p)) '(unused (a b)(c (d e))))
;; => B(A)E(C D)

(define (alist-for-each proc alist)
  (for-each
   (lambda(ass)
     (proc(car ass)(cdr ass)))
   alist))

(define (alist-map proc alist)
  (map
   (lambda(ass)
     (proc(car ass)(cdr ass)))
   alist))

(define *trace-level* 0)

(define (trace level . args)
  (when (<=fx level *trace-level*)
	(with-output-to-port
	    (current-error-port)
	  (lambda()
	    (apply print args)))))

;; to use lset prims (srfi-1) with alists
(define (car-eq? p1::pair p2::pair)
  (eq?(car p1)(car p2)))


(define (string->hex s)
  (let*((len(string-length s))
	(result(make-string (*fx len 2))))
    (pragma "
{
  static char mask[]=\"0123456789abcdef\";
  while( $1 --) {
    char c = * $2 ++;
    * $3 ++ = mask[(c >> 4) & 15];
    * $3 ++ = mask[c & 15];
  }
}"
  len
  ($bstring->string s)
  ($bstring->string result))
    result))

(define (sort-hierarchical! l::pair-nil
			   getkey::procedure
			   getparentkeys::procedure)
  (let loop((sorted l))
    (if(null? sorted)
       l
       (let*((this(car sorted))
	     (rest(cdr sorted))
	     (thiskey(getkey this))
	     (parentkeys(getparentkeys this))
	     (outoforder
	      (find-tail
	       (lambda(e)(memq(getkey e)parentkeys))
	       rest
	       )))
	 ;;(print "this " this " rest " rest " outoforder "outoforder)
	 (loop
	  (if outoforder
	      ;; swap entries and try again
	      (let((super(car outoforder)))
		(set-car! outoforder this)
		(set-car! sorted super)
		sorted)
	      rest))))))
;;(sort-hierarchical! '((a b)(b c)(c d)(d e)(e f)(f g))car cdr)

(define (ptr->0..255 o)
  (pragma::long "get_hash_number_from_int($1)" o))

(define (list->carray lyst::pair-nil foreign-id::symbol)
  (let*((len(length lyst))
	(result(pragma::foreign "cobj_to_foreign(GC_malloc(sizeof(void*) * ($1 + 1)), $2)"
				len foreign-id)))
    (pragma "((void**)FOREIGN_TO_COBJ($1))[$2] = NULL"result len)
    (let loop((i 0)
	      (lyst lyst))
      (if(< i len)
	 (let((o(car lyst)))
	   (cond((string? o)
		 (pragma "((char**)FOREIGN_TO_COBJ($1))[$2] = $3"
			 result i($bstring->string o)))
		((integer? o)
		 (pragma "((int*)FOREIGN_TO_COBJ($1))[$2] = $3"
			 result i($bint->int o)))
		((boolean? o)
		 (pragma "((int*)FOREIGN_TO_COBJ($1))[$2] = ($3 != BFALSE)"
			 result i o))
		((foreign? o)
		 (pragma "((void**)FOREIGN_TO_COBJ($1))[$2] = FOREIGN_TO_COBJ($3)"
			 result i o)))
	   (loop(+fx i 1)(cdr lyst)))
	 result))))

(define (coerce! type-name::symbol o)
  (and o
       (begin
	 (check-type
	  (unless(foreign? o)
		 (error "coerce!" "Type error"
			(format "`FOREIGN' expected, `~a' provided"o))))
	 (case type-name
	   ((string)
	    (pragma::string "(char*)FOREIGN_TO_COBJ($1)" o))
	   
	   ((int)
	    (pragma::int "(int)FOREIGN_TO_COBJ($1)" o))

	   ((uint)
	    (pragma::uint "(unsigned)FOREIGN_TO_COBJ($1)" o))

	   (else
	    (pragma "FOREIGN_ID($1) = $2" o type-name)
	    o)))))

;*-------------------------------------------------------------------*;
;*  Object referencing/unreferencing                                 *;
;*-------------------------------------------------------------------*;
#|
(define *scheme-object-registry*
  (make-hash-table 256 ptr->0..255 car eq?))

(define (object-lookup o)
  (get-hash o *scheme-object-registry*))

(define (object-ref o . finalizers)
  (when (pointer? o)
	(let((tuple
	      (or (object-lookup o)
		  (let((tuple(list o 0)))
		    (put-hash! tuple *scheme-object-registry*)
		    tuple))))
	  (let((rest (cdr tuple)))
	    (set-car! rest(+fx 1(car rest))))
	  (append! tuple (filter procedure? finalizers))
	  ;;(trace (format "object-ref: ~a ~a"o tuple))
	  )))

;; return #f if object was not registered, return the object otherwise
(define (object-unref o)
  (and (pointer? o)
       (let((tuple(object-lookup o)))
	 (and tuple
	      (let*((rest(cdr tuple))
		    (new-count(-fx (car rest)1)))
		;;(trace (format "object-unref: ~a ~a"o new-count))
		(if(=fx 0 new-count)
		   (begin
		     (rem-key-hash! o *scheme-object-registry*)
		     (for-each
		      (lambda(func)(func o))
		      (cddr tuple)))
		   (set-car! rest new-count))
		o)))))

(define (pair->0..2^x-1 o::obj p::int)
  (if(pair? o)
     (bit-xor (pair->0..2^x-1 (car o)p)
	      (pair->0..2^x-1 (cdr o)p))
     (obj->0..2^x-1 o p)))
;;(pair->0..2^x-1 (list "qwerty" "asd")10)

(define (pair->0..255 o::obj)
  (pair->0..2^x-1 o 8))

|#

;; read an object from a string
(define (scheme-read-string s::string)
  (read (open-input-string s)))
;;(scheme-read-string "AsDf")

;; TODO: use mutex to access this global
#|
(define *object-data-registry* (make-hash-table 256 obj->0..255 car equal?))

(define (object-data-get o #!optional selector)
  (let((data(cond ((get-hash o *object-data-registry*) => cdr))))
    (and data
	 (if selector
	     (alist-lookup data selector)
	     data))))

(define (object-data-set! o data #!optional selector)
  (let((entry (or (get-hash o *object-data-registry*)
		  (put-hash! (list o) *object-data-registry*))))
    (set-cdr! entry
	      (if selector
		  (alist-set! (cdr entry) selector data)
		  data))))

(define (object-data-free! o)
  (rem-key-hash! o *object-data-registry*))
|#

;; this should go to common usage place
(define (grove-walk node-list::pair-nil
		    transition::procedure
		    #!optional (collected::pair-nil '()))
  (let loop((node-list node-list)
	    (collected collected))
    (if(null? node-list)
       collected
       (let((candidate(car node-list)))
	 (loop(cdr node-list)
	      (if(memq candidate collected)
		 collected
		 (loop(transition candidate)(cons candidate collected))))))))

#|
setting printer is no more supported!

(define *printer-table* '())

(define (add-printer isa?::procedure display::procedure)
  (when (null? *printer-table*)
	(let ((old-printer (current-printer)))
	  (set-printer!
	   (lambda (o #!optional port)
	     (let((tuple
		   (find
		    (lambda(tuple)
		      ((car tuple) o))
		    *printer-table*)))
	       (if tuple
		   ((cdr tuple) old-printer o port)
		   (old-printer o port)))))))
  (set!
   *printer-table*
   (cons
    (cons isa? display)
    (remove!
     (lambda(tuple)
       (eq? (car tuple)
	    isa?))
     *printer-table*))))
|#