;; -*-Scheme-*-
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

;*-------------------------------------------------------------------*;
;*  MzScheme compatibility                                           *;
;*-------------------------------------------------------------------*;
(define-macro (list* first . rest)
  `(cons* ,first ,@rest))

(define-macro (void)
  (unspecified))
;;(void)

(define-macro (void? o)
  (eq? o #unspecified))

(define-macro begin0
  (lambda (first . rest)
	  `(let((%% ,first))
	     ,@rest
	     %%)))

(define-macro case-lambda
  (lambda patterns
    (let((make-cond
	  (lambda(lst)
	    (let loop((l 0)(lst lst))
	      (cond((pair? lst)
		    (loop(+fx l 1)(cdr lst)))
		   ((null? lst)
		    `(=fx nargs ,l))
		   (else
		    `(>=fx nargs ,l)))))))
      `(lambda args
	 (let*((nargs(length args))
	       (proc
		(cond
		 ,@(map
		    (lambda(pattern)
		      (list
		       (make-cond(car pattern))
		       `(lambda ,(car pattern)
			  ,@(cdr pattern))))
		    patterns)
		 (else(error "case-lambda" "no pattern for n of args:" nargs)))))
	   (apply proc args))))))

(define-macro (let-values bindings . body)
  (if(null? bindings)
     `(begin ,@body)
     (let*((first-binding(car bindings))
	   (rest(cdr bindings))
	   (vars(car first-binding))
	   (producer(cadr first-binding)))
       `(call-with-values
	 (lambda () ,producer)
	 (lambda ,vars (let-values ,rest ,@body))))))
;;(expand '(let-values(((a b)(split-typed-value 'parser-parse:void)))(list a b)))

(define-macro (parameterize bindings . body)
  (let*((parameter-names(map car bindings))
	(var-names(map(lambda(n)(symbol-append n '-tmp))parameter-names)))

    `(let ,(map(lambda(p v)(list v(list p)))parameter-names var-names)
       (unwind-protect
	(begin
	  ,@(map(lambda(p v)(list p v))parameter-names(map cadr bindings))
	  ,@body)
	(begin
	  ,@(map(lambda(p v)(list p v))parameter-names var-names))))))

;;(parameterize ((a 1)) (a 4)(display (a))2)

;; FIXME: no struct inheritance implemented
(define-macro (define-struct-mz name-parent slots)
  [assert(name-parent)(or(symbol? name-parent)
			 (list? name-parent))]
  (let*((name  (if(list? name-parent)(car name-parent)name-parent))
	(parent(and(list? name-parent)(cadr name-parent)))
	(predicate-procname(symbol-append name '?))
	(constructor-procname(symbol-append 'make- name))
	(make-setter-procname
	 (lambda(slot)
	   (symbol-append 'set- name '- slot '!)))
	)
    [when parent
	  (error "define-struct" "No struct inheritance implemented. Sorry" name)]
    `(begin
       ;; struct?
       (define-inline(,predicate-procname o)
	 (and
	  (struct? o)
	  (eq?(struct-key o)',name)))

       ;; make-struct
       (define-inline(,constructor-procname ,@slots)
	 ,(cond((null? slots)
		`(make-struct ',name 0 '()))
	       ((null?(cdr slots))
		`(make-struct ',name 1 ,(car slots)))
	       (else
		`(let((s(make-struct ',name ,(length slots) ,(car slots))))
		   ,@(map
		      (lambda(slot)
			`(,(make-setter-procname slot) s ,slot))
		      (cdr slots))
		   s))))

       ;; set-struct-field!
       ,@(let loop((slots slots)(idx 0)(accu '()))
	   (if(null? slots)
	      accu
	      (loop(cdr slots)
		   (+fx 1 idx)
		   (cons
		    `(define-inline(,(make-setter-procname(car slots))o val)
		       [assert(o)(,predicate-procname o)]
		       (struct-set! o ,idx val))
		    accu))))
       
       ;; struct-field
       ,@(let loop((slots slots)(idx 0)(accu '()))
	   (if(null? slots)
	      accu
	      (loop(cdr slots)
		   (+fx 1 idx)
		   (cons
		    `(define-inline(,(symbol-append name '- (car slots)) o)
		       [assert(o)(,predicate-procname o)]
		       (struct-ref o ,idx))
		    accu)))))))

;;(define-parameter name #!optional init-value filter)
(define-macro (define-parameter name . margs)
  (let((container-name(symbol-append name (gensym '-)))
       (init(and(pair? margs)(car margs)))
       (filter(and(>fx(length margs)1)(cadr margs))))
    `(begin
       (define ,container-name ,init)
       (define(,name . args)
	 (if(null? args)
	    ,container-name
	    (set! ,container-name
		  ,(if filter
		       `(,filter (car args))
		       '(car args))))))))
;;(pp(expand-once '(define-parameter current-http-query )))
;;(pp(expand-once '(define-parameter ququ #f (lambda(val)(+ val val)))))

;;(make-parameter #!optional init-value filter)
(define-macro (make-parameter . margs)
  (let loop((margs margs))
    (match-case margs
		(()
		 (loop '(#unspecified)))
		((?init)
		 `(let((value ,init))
		    (lambda args
		      (if(null? args)
			 value
			 (set! value(car args))))))
		((?init ?filter)
		 `(let((value ,init))
		    (lambda args
		      (if(null? args)
			 value
			 (set! value (,filter(car args))))))))))
;;(pp(expand-once '(make-parameter #f (lambda(val)(+ val val)))))
;;(pp(expand-once '(make-parameter)))

;*-------------------------------------------------------------------*;
;*  Make C global variable wrapper                                   *;
;*-------------------------------------------------------------------*;
(define-macro (define-C-global sname type)
  (let((cname(symbol->string sname)))
    `(define (,(symbol-append sname ':: type) #!optional value)
       (let((old(,(symbol-append 'pragma:: type) ,cname)))
	 (when value
	       (let((,(symbol-append 'value:: type) value))
		 (pragma ,(string-append cname " = $1") value)))
	 old))))
;;(pp(expand-once '(define-C-global errno int)))

;*-------------------------------------------------------------------*;
;*  Misc                                                             *;
;*-------------------------------------------------------------------*;
(define-macro (push! stack o)
  `(let((_obj ,o))
     (set! ,stack(cons _obj ,stack))
     _obj))

(define-macro (pop! stack)
  `(begin0
    (car ,stack)
    (set! ,stack(cdr ,stack))))

(define-macro (string*-set! s::string* i::int v::string)
  `(pragma "$1[$2] = $3" ,s ,i ,v))

(define-macro (string*-ref s::string* i::int)
  `(pragma::string "$1[$2]" ,s ,i))

(define-macro (make-string* size::int)
  `(pragma::string* "(char**)(GC_malloc($1 * sizeof(char**)))" ,size))

(define-macro (string*-null? s::string*)
  `(pragma::bool "$1 == (char**)0" ,s))

(define-macro (list->cpointers type::symbol)
  (let*((type* (symbol-append type '*))
	(set* (symbol-append type* '-set!))
	(pragma (symbol-append 'pragma:: type))
	(pragma* (symbol-append 'pragma:: type*))
	(make* (symbol-append 'make- type*)))

    `(lambda (constructor::procedure attvals::pair-nil)
       (let((valsp (,make* (+fx 1 (length attvals)))))
	 (let loop((i 0)(attvals attvals))
	   (if(null? attvals)
	      (begin
		(,set* valsp i(,pragma "NULL"))
		valsp)
	      (begin
		(,set* valsp i
		       (constructor(car attvals)))
		(loop(+fx i 1)(cdr attvals)))))))))

;;(pp(expand-once '(list->cpointers string)))

;; C-pointer must be valid here -- no NULL? check here
;;     (if(,(symbol-append type '*-null?) p*)
;;	'()

(define-macro (cpointer->list type::symbol . proc)
  `(lambda(,(symbol-append 'p*:: type '*) #!optional len)
     (let loop((accu '())(i 0))
       (let((,(symbol-append 'p:: type)
	     (,(symbol-append 'pragma:: type) "$1[$2]" p* i)))
	 (if(or (and len (=fx i len))
		(pragma::bool "$1 == NULL" p))
	    (reverse accu)
	    (loop
	     (cons ,(if(null? proc) 'p (list(car proc) 'p)) accu)
	     (+fx i 1)))))))
;;(pp(expand-once '(cpointer->list string)))

;*-------------------------------------------------------------------*;
;*  assertions                                                       *;
;*-------------------------------------------------------------------*;
(define-macro (check-type . body)
  (if *unsafe-type*
      `'()
      `(begin ,@body)))
(define-macro (check-range . body)
  (if *unsafe-range*
      `'()
      `(begin ,@body)))

(define-macro (check-arity . body)
  (if *unsafe-arity*
      `'()
      `(begin ,@body)))

(define-macro (check-struct . body)
  (if *unsafe-struct*
      `'()
      `(begin ,@body)))

(define-macro (check-version . body)
  (if *unsafe-version*
      `'()
      `(begin ,@body)))

(define-macro (check-library . body)
  (if *unsafe-library*
      `'()
      `(begin ,@body)))

;; Execute macro body `body' on string `s'. The `start' and `end'
;; arguments are defaulted to 0 and (string-length s). Additionally
;; the `s-len' variable defined which is set to (string-length s)
(define-macro (with-optional-range procname s start end . body)
  (let((len-name (symbol-append s '-len)))
    `(let*((,len-name(string-length ,s)))
       (if ,start
	   (check-range
	    (unless(and (>=fx ,start 0)
			(<=fx ,start ,len-name))
		   (error ,procname "start string offset out of range" ,start)))
	   (set! ,start 0))
       (if ,end
	   (check-range
	    (unless(and(>=fx ,end 0)(<=fx ,end ,len-name))
		   (error ,procname "end string offset out of range" ,end)))
	   (set! ,end ,len-name))
       ,@body)))

;; This macro declares a class constructor procedure which takes slot
;; values as keyword arguments. It differs from the Bigloo
;; `instantiate' syntax in that it is not a syntax but a procedure.

(define-macro (define-instantiate classname . slots)
  (define (opt-spec key args)
    (if (pair? args)
	(cons
	 (eval key)
	 (map (lambda(s)(if (pair? s)(car s)s)) (reverse args)))
	'()))

  (let((mode 'required)
       (required '())
       (optional '())
       (key  '()))
    (let loop ((s slots))
      (match-case
       s
       (()
       `(define (,(symbol-append classname '-instantiate) 
		 ,@(reverse required)
		 ,@(opt-spec '#!optional optional)
		 ,@(opt-spec '#!key key)
		 )
	  (,(symbol-append 'instantiate:: classname)
	   ,@(map
	      (lambda(s)
		(match-case
		 s
		 ((?n ?d)
		  `(,n (or ,n ,d)))
		 
		 (?n
		  `(,n (or ,n #unspecified)))))
	      (append required optional key)))))
       
       ((#!optional . ?rest)
	(set! mode 'optional)
	(loop rest))
       
       ((#!key . ?rest)
	(set! mode 'key)
	(loop rest))
       
       ((?arg . ?rest)
	(case mode
	  ((key)
	   (push! key arg))
	  ((optional)
	   (push! optional arg))
	  (else
	   (push! required arg)))
	(loop rest))))))
	
;;(pp (expand-once '(define-instantiate event id title)))
;;(pp (expand-once '(define-instantiate event id #!optional title)))
;;(pp (expand-once '(define-instantiate event id #!optional (title "Default title"))))
;;(pp (expand-once '(define-instantiate event id #!optional (title "Default title") #!key (t 1))))
