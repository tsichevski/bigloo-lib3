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
 cgen
; (library common)
 (import
  (misc       "misc.scm")
  (srfi-1     "srfi-1.scm")
  (string-lib "string-lib.scm")
  )

 (include "common.sch")
 (export
  *module*
  *body*
  *cgen-version*
  (define-enum names . enum)
  (define-enum-extended names . enum)
  (define-flags names . enum)

  (define-object names #!optional (cparents '()) #!rest directives)
  (define-boxed names #!rest directives)
  (define-accessors name #!rest directives)
  (define-func cname return-spec proto-spec . options)
  (define-errcode cname . exprs)
  (import filename::bstring)

  (cpp->scheme::symbol cpp-name)
  (cpp->macro::bstring cpp-name)
  (lookup-function fname::symbol)
  )
 (eval(export-all))
 (main main)
 )

(define *cgen-version* "1.1")

(define-macro (make-symbol-normalizer)
  (if(eq? 'a 'A)
     '(define(normalize-symbols expr)
	(let loop((expr expr))
	  (cond((symbol? expr)
		(scheme-read-string(symbol->string expr)))
	       ((pair? expr)
		(cons(loop(car expr))(loop(cdr expr))))
	       ((vector? expr)
		(apply vector(loop(vector->list expr))))
	       (else expr))))
     '(define-inline(normalize-symbols expr)
	expr)))

;; Address the case sensitivity issue: when compiled by bigloo
;; revision < 2.4 => uppercase all symbols in expression. Return an
;; unmodified expression otherwise

(make-symbol-normalizer)
;;(normalize-symbols (string->symbol "asdf"))


(define(as-string n)
  (if(symbol? n)
     (symbol->string n)
     n))

(define (namedef-cname namedef)
  (if (pair? namedef)
      (cadr namedef)
      namedef))

;; We keep the list of name translations which we define explicitly,
;; to assure we always use them later
(define *cpp->scheme-alist* '())

;; TODO: need better mechanism to handle name associations. Probably
;; we need to register them explicitly
(define (namedef-sname namedef)
   (if (pair? namedef)
       (let((sname (car namedef))
	    (cname (as-string (cadr namedef))))
	 (unless(member cname '("int"))
		(push! *cpp->scheme-alist* (cons cname sname)))
	 sname)
       (cpp->scheme namedef)))

;; Register all name conversions to print it with the --dump-renamings
(define *cpp->scheme* '())

(define (cpp->scheme cpp-namedef)
  (if (pair? cpp-namedef)
      (car cpp-namedef)
      (let((cpp-name(as-string cpp-namedef)))
	(cond ((assoc cpp-name *cpp->scheme*)
	       => cdr)
	      (else
	       (let((new-name
		     (cond((assoc cpp-name *cpp->scheme-alist*)
			   => cdr)
			  (else
			   (let*((os(open-output-string))
				 (print(lambda args
					 (for-each
					  (lambda(arg)(display arg os))
					  args))))
			     (read/rp (regular-grammar
				       ()
				       ((: (submatch upper)(submatch (: (+ upper) lower)))
					(print(the-submatch 1)"-"(the-submatch 2))(ignore))
				       
				       ((: (submatch lower)(submatch upper))
					(print(the-submatch 1)"-"(the-submatch 2))(ignore))
				       
				       ;;("2"(print "->")(ignore))
				       
				       ("_"(print "-")(ignore))
				       ("."(print "-")(ignore))
				       (else
					(unless(eof-object?(the-failure))
					       (print(the-string))(ignore))))
				      (open-input-string cpp-name))
			     (string->symbol
			      (string-downcase (get-output-string os))))))))
		 (push! *cpp->scheme* (cons cpp-name new-name))
		 new-name))))))

;;(cpp->scheme "StartLpdEvent")
;;(cpp->scheme "GSList")
;;(cpp->scheme "ext2_flag")

(define (cpp->macro cpp-name)
  (let*((os(open-output-string))
	(print(lambda args
		(for-each(lambda(arg)(display arg os))args))))
    (read/rp (regular-grammar
      ()
      ((: (submatch lower)(submatch upper))
       (print(the-submatch 1)"_"(the-submatch 2))(ignore))

      ((or alnum)(print(the-string))(ignore)))
     (open-input-string (as-string cpp-name)))
    (string-upcase(get-output-string os))))
;;(cpp->macro (string->symbol "RadioButton"))

(define *module* '())

(define(add-module-dirs! dirs::pair-nil)
  (set! *module*(append! (reverse dirs) *module*)))
;;(add-module-dirs! `((foreign(macro sname cobj->sname (cobj) cname))))

(define *body* '())

;; Lookup a collected so far function definition
(define (lookup-function fname::symbol)
  (find 
   (match-lambda
    ((define (?name . ?-) . ?-)
     (eq? name fname)))
   *body*))

(define (add-body-dirs! dirs::pair)
  (for-each
   (lambda (dir)
     (if (match-case
	  dir
	  ((define (?name . ?-) . ?-)
	   (lookup-function name)))
	 [trace 1 "redefinition of " (cadr dir)]
	 (push! *body* dir)))
   dirs))

;*-------------------------------------------------------------------*;
;*  C enumeration                                                    *;
;*-------------------------------------------------------------------*;
(define-macro (define-name names dereference? . expr)
  `(let*((names ,names)
	 (cname
	  (if(pair? names)
	     (as-string(cadr names))
	     ,(if dereference?
		  `(string-append(as-string names)"*")
		  `(as-string names))
	     ))
	 (sname(namedef-sname names)))
      ,@expr))

(define-macro (define-names names dereference? . expr)
  `(define-name ,names ,dereference?
     (let*((sname?              (symbol-append sname '?))
	   (bsname              (symbol-append 'b sname))
	   (sname->bsname       (symbol-append sname '->b sname))
	   (bsname->sname       (symbol-append bsname '-> sname))
	   (cobj->sname         (symbol-append 'cobj-> sname))
	   (pragma-sname        (symbol-append 'pragma:: sname))
	   (pragma-bsname        (symbol-append 'pragma::b sname))
	   (sname?-proto        `(,(symbol-append sname? '::bool) o::obj))
	   (sname->bsname-proto  `(,(symbol-append sname->bsname ':: bsname)
				   ,(symbol-append 'o:: sname)))
	   (bsname->sname-proto  `(,(symbol-append bsname->sname ':: sname) o::obj)))
       ,@expr)))

(define (define-enum names . enum)
  (x-define-enum names #f enum))

;; any integer values may be used along with symbolic names
(define (define-enum-extended names . enum)
  (x-define-enum names #t enum))

(define (x-define-enum names extended? enum)
  (define-names names #f
    (let((enumvals(map car enum)))
      
      (add-module-dirs!
     
       `((type
	  (subtype ,sname ,cname (cobj))
	  (coerce cobj ,sname () (,cobj->sname))
	  (coerce long ,sname () (,cobj->sname))
	  (coerce short ,sname () (,cobj->sname))

	  (coerce ,sname cobj () ())

	  (subtype ,bsname "obj_t" (obj))
	  (coerce obj ,bsname (,sname?) ())
	  (coerce ,bsname obj () ())
	  (coerce ,bsname bool ()((lambda (x)#t)))

	  (coerce ,bsname ,sname()(,bsname->sname))

	  (coerce ,sname ,bsname
		  ()
		  (,sname->bsname)
		  )

	  (coerce symbol ,sname ()(,bsname->sname))
	  (coerce ,sname symbol()(,sname->bsname))
	  )
	 (foreign (macro ,sname ,cobj->sname (cobj) ,(format "(~a)" cname)))
	 (export ,sname?-proto ,sname->bsname-proto ,bsname->sname-proto)
	 ))

      (add-body-dirs!
       `(
	 (define ,bsname->sname-proto
	   ,(let((symbol->sname
		  `(case o
		     ,@(map
			(lambda(ass)
			  `((,(car ass))
			    (,pragma-sname ,(format "~a" (cadr ass)))))
			enum)
		     (else
		      (error
		       ,(symbol->string bsname->sname)
		       ,(if(pair? enumvals)
			   (format "invalid argument, must be integer or one of ~a: "enumvals)
			   "invalid argument, must be integer")
		       o)))))
	      (if extended?
		  `(if(integer? o)
		      (,pragma-sname "CINT($1)" o)
		      ,symbol->sname)
		  symbol->sname))
	   )
       
	 (define ,sname->bsname-proto
	   ;; initialize the `res' variable with `pragma' to suppress
	   ;; bigloo optimization
	   
	   (let((res(pragma "BUNSPEC")))
	     (pragma ,(string-append
		       "switch($1) { "
		       (let loop((enum enum)
				 (i 3)
				 (accu '()))
			 (if(null? enum)
			    (apply string-append accu)
			    (loop
			     (cdr enum)
			     (+fx i 1)
			     (cons
			      (format
			       "case ~a: $2 = $~a; break;\n"
			       (cadar enum)
			       i)
			      accu))))
		       (format "default: $2 = BINT($1);}"))
		     o
		     res
		     ,@(map (lambda(ass) `',(car ass)) enum)
		     )
	     (,pragma-bsname "$1"res)))
       
	 (define ,sname?-proto
	   ,(if extended?
		`(or(integer? o)(memq o ',enumvals))
		`(memq o ',enumvals)
		))
	 )))))

;*-------------------------------------------------------------------*;
;*  C flags (named bits)                                             *;
;*-------------------------------------------------------------------*;
(define (define-flags names . enum)
  (define-names names #f
    (let((allenumvals(map car enum)))

      (add-module-dirs!

       `((type
	  (subtype ,sname ,cname (cobj))
	  (coerce cobj ,sname () (,cobj->sname))

	  (coerce ,sname cobj () ())

	  (subtype ,bsname "obj_t" (obj))
	  (coerce obj ,bsname (,sname?) ())
	  (coerce ,bsname obj () ())
	  (coerce ,bsname bool ()((lambda (x)#t)))

	  (coerce ,bsname ,sname()(,bsname->sname))
	  (coerce ,sname ,bsname()
		  (,sname->bsname)
		  )

	  (coerce pair ,sname ()(,bsname->sname))
	  (coerce ,sname pair ()(,sname->bsname))

	  (coerce pair-nil ,sname ()(,bsname->sname))

	  ;; any boolean means no flags
	  (coerce bool ,sname ()((lambda(x)0)))
	  (coerce ,sname pair-nil ()(,sname->bsname))
	  )
	 (foreign (macro ,sname ,cobj->sname (cobj) ,(format "(~a)" cname)))
	 (export ,sname?-proto ,bsname->sname-proto ,sname->bsname-proto)
	 ))

      (add-body-dirs!

       `((define ,bsname->sname-proto
	   (let((res::int 0))
	     (for-each
	      (lambda(o)
		(case o
		  ,@(map
		     (lambda(ass)
		       `((,(car ass))
			 (set! res (bit-or res(pragma::int ,(format "~a"(cadr ass)))))))
		     enum)
		  (else
		   (error ,(symbol->string bsname->sname)
			  ,(format "invalid argument, must be one of ~a: "
				   allenumvals)
			  o))))
	      o)
	     (let((res::int res))
	       (,pragma-sname "$1"res))))
	 
	 (define ,sname->bsname-proto
	   (let((res '()))
	     ,@(map
		(lambda(ass)
		  `(when(pragma::bool ,(format "($1 & ~a) == ~a"(cadr ass)(cadr ass))
				      o)
		       (set! res (cons ',(car ass) res))))
		enum)
	     res))

	 (define ,sname?-proto
	   ;; FIXME: function body should be outlined
	   ;; lset-difference usage eliminated
	   (and (list? o)
		(null?
		 (lset-difference eq? o ',allenumvals))))
	 )))))

;*-------------------------------------------------------------------*;
;*  C error code                                                     *;
;*-------------------------------------------------------------------*;
;; Registry of object types, those declaration includes `errorcode'
;; directive. Unlike the `postprocess' clause, functions declared
;; returning object of such types will not return any value.

(define *check-handlers* (make-hashtable))

(define (define-errcode name . exprs)
  (define-name name #f
    (hashtable-put! *check-handlers* sname exprs)))
;;(define-errcode errorType handler ...)
;*-------------------------------------------------------------------*;
;*  C structure pointer                                              *;
;*-------------------------------------------------------------------*;
(define (make-default-predicate sname)
  `(and (foreign? o)
	(eq? (foreign-id o) ',sname)))

(define *predicate-list* `((default . ,make-default-predicate)))
(define *current-predicate* make-default-predicate)

(define (convert-to-false false-values)
  ;; values to be treated as scheme #f
  (if (pair? false-values)
      `(and
	,@(map
	   (lambda(val)
	     `(pragma::bool ,(string-append "$1 != " val)
			    result))
	   false-values)
	result)
      'result))

(define (define-accessors name #!rest directives)
  (define-name name #t
    (let loop ((slotdefs directives))
      (unless (null? slotdefs)
	      (let*
		  ((def (car slotdefs))
		   
		   (typedef (car def))
		   (type (namedef-cname typedef))
		   (stype (namedef-sname typedef))
		   
		   (namedef (cadr def))
		   (cargname (namedef-cname namedef))
		   (sargname (namedef-sname namedef))
		   (ctype #f)
		   
		   (getter-name(symbol-append sname '- sargname))
		   (false-values '())
		   (error-values '())
		   (setter-name #f)
		   )
	       (for-each
		(lambda (dir)
		  (match-case
		   dir
		   ((? string?)
		    (set! ctype dir))

		   ;; treat all these values as scheme #f value
		   ((false . ?vals)
		    (set! false-values
			  (if(null? vals)
			     '("NULL")
			     vals)))

		   ;; treat all these values as an error
		   ((error . ?vals)
		    (set! error-values
			  (if(null? vals)
			     '("NULL")
			     vals)))
		   ((setter . ?names)
		    (set! setter-name
			  (if (null? names)
			      (symbol-append 'set- sname '- sargname '!)
			      (car names))))

		   
		   ((getter . ?names)
		    (set! getter-name
			  (if (null? names)
			      (symbol-append sname '- sargname)
			      (car names))))
		   (else
		    [warning "define-accessors"
			     "Unsupported namedef modifier"
			     dir])
		   ))
		(normalize-symbols (cddr def)))
	       (when getter-name
		     (let((proto
			   `( ,(if (pair? false-values)
				   getter-name
				   (symbol-append getter-name ':: stype))
			      ,(symbol-append 'o:: sname))))
		       
		       (add-module-dirs! `((export ,proto)))
		       (add-body-dirs!
			`((define ,proto
			    (let((result( ,(symbol-append 'pragma:: stype)
					  ,(if ctype
					       (format "(~a)$1->~a" ctype cargname)
					       (format "$1->~a" cargname))
					  o)))
			      ;; values to be treated as errors
			      ,@(map
				 (lambda(val)
				   `(when(pragma::bool ,(string-append "$1 == " val)
						       result)
					 `(error
					   ,(symbol->string getter-name)
					   ,(string-append(val " value returned"))
					   o)))
				 error-values)
			      ,(convert-to-false false-values)))))))
	       
	       (when setter-name
		  (let((proto
			`( ,setter-name
			   ,(symbol-append 'o:: sname)
			   ,(if (pair? false-values)
				'v
				(symbol-append 'v:: stype))
			   )))
		     
		     (add-module-dirs! `((export ,proto)))
		     (add-body-dirs!
		      `((define ,proto
			  (let ((,(symbol-append 'v:: stype) v))
			    (pragma ,(format "$1->~a = $2" cargname) o v)
			    #unspecified))))
		     ))

	       (loop(cdr slotdefs))
	       )))))

;; If object spec includes a `postprocess' clause, values of that type
;; returned by all functions declared thru define-func, will be
;; filtered thru the postprocess procedure those name is declared in
;; the `postprocess' clause.

;;(define *post-handlers* (make-hashtable))

(define(x-define-object names
			parents::pair-nil
			directives::pair-nil
			#!optional boxed?)
  (define-names names #t
    (let*((parent
	   (if(null? parents)
	      'cobj
	      (namedef-sname(car parents))))
	  (parent->sname      (symbol-append parent '-> sname))
	  (sname->parent      (symbol-append sname '-> parent))
	  (false-values '())
	  (predicate #f)
	  )

      (for-each
       (lambda(dir)
	 (let((rest (cdr dir)))
	   (case (normalize-symbols (car dir))
	     
	     ((copy free size conversion)
	      ;; FIXME: support needed
	      #unspecified)
	     
	     ((fields)
	      (apply define-accessors (cons names rest)))
	     
	     ((predicate)
	      (set! predicate (car rest)))

	     ((false)
	      (set! false-values
		    (if (pair? rest)
			rest
			'("NULL"))))
	     (else
	      (error "x-define-object" "unsupported directive"dir)))))
       directives)

      (add-module-dirs!

       `((type
	  (subtype ,sname ,cname (,parent))
	  (coerce ,parent ,sname () (,parent->sname))
	  (coerce ,sname ,parent () (,sname->parent))
	  (coerce
	   ,sname
	   bool
	   ()
	   ((lambda (x)(pragma::bool "$1 != NULL" x))))


	  (subtype ,bsname "obj_t" (obj))
	  (coerce obj ,bsname
		  ()
		  ;; NOTE: bigloo compiler seemes to do it automatically?
		  ;;(,sname?)
		  ())
	  (coerce ,bsname obj () ())
	  (coerce ,bsname ,sname (,sname?)
		  (,bsname->sname))

	  (coerce
	   ,sname
	   ;;,bsname
	   obj
	   ()
	   ((lambda(result)
	      ;; values to be treated as scheme #f

	      ,(if (pair? false-values)
		   ;; NOTE:: bigloo compiler does not know of any of
		   ;; ordinary expansions here, like `and' or `cond' so
		   ;; we should call `expand' explicitly
		   (expand
		    `(cond
		      ,@(map
			 (lambda(val)
			   `((pragma::bool ,(string-append "$1 == " val)
					   result)
			     ;; NOTE:: if we simply put `#f' here, then
			     ;; bigloo compiler creates code returning
			     ;; C false value, i.e. `(bool_t)0' instead
			     ;; of scheme false
			     (pragma::obj "BFALSE")))
			 false-values)
		      (else
		       (,pragma-bsname "cobj_to_foreign($1, (void*)$2)"
				       ',sname result))))
		   `(,pragma-bsname "cobj_to_foreign($1, (void*)$2)"
				    ',sname result))))))
	 
	 (foreign (macro ,sname ,parent->sname (,parent)
			 ,(format"(~a)"cname))
		  (macro
		      ,parent
		    ,sname->parent
		    (,sname)
		    ,(if (null? parents)
			 "(long)"
			 (let((parent-def(car parents)))
			   (if (pair? parent-def)
			       (format "(~a)" (cadr parent-def))
			       (format "(~a*)" parent-def)
			       ))))
		  
		  (macro ,sname ,bsname->sname (foreign)
			 ,(format"(~a)FOREIGN_TO_COBJ"cname)))
	 
	 (export ,sname?-proto
		 ;;,sname->bsname
		 ;;,bsname->sname
		 )))
      
      (add-body-dirs!
       `((define ,sname?-proto
	   ,(or predicate (*current-predicate* sname)))))    
      )))

(define (define-object names #!optional (cparents '()) #!rest directives)
  (x-define-object names cparents directives))

(define(define-boxed names #!rest directives)
  (x-define-object names '() directives #t))

(define (make-pragma::pair fname::bstring return-type args)
   (let loop ((args args)
	      (i 1)
	      (placeholders '())
	      (real-args '()))
     (match-case
      args
      (((?name ?cast) . ?rest)
       (loop (cdr args)
	     (+ i 1)
	     (cons (format "(~a)$~a" cast i)placeholders)
	     (cons name real-args)))
	   
      ((?name . ?rest)
       (loop (cdr args)
	     (+ i 1)
	     (cons (format "$~a" i)placeholders)
	     (cons name real-args)))
      (else
       (cons*
	(if return-type
	    (symbol-append 'pragma:: return-type)
	    'pragma)
	(format "~a(~a)"
		fname
		(print-list-delimited (reverse placeholders)", "))
	(reverse real-args))))))
;;(pp (make-pragma 'printf 'int '(a b c d e)))
;;(pp (make-pragma 'printf 'int '((a "const char*") b c d e)))

;*-------------------------------------------------------------------*;
;*  C function wrapper                                               *;
;*-------------------------------------------------------------------*;
(define *comment-code* #f)

(define (define-func names return-spec proto-spec . options)
  (define-name names #f
    (define declared-return-type
      (if(memq(normalize-symbols return-spec) '(none void))
	 #f
	 (namedef-sname return-spec)))
    
    (define check-handlers
      (or (hashtable-get *check-handlers* declared-return-type) '()))

    (define has-optional? #f)

    (let loop((proto '())
	      (casts '())
	      (argnames '())
	      (proto-spec proto-spec))
      (if (pair? proto-spec)
	  (let*((def (car proto-spec))
		(argtype (cpp->scheme (car def)))
		(argname
		 (match-case
		  def
		  ((?- ?argname . ??)
		   (cpp->scheme argname))
		  (else (gensym 'arg))))
		
		(argcast #f)
		
		(compose-argname+cast
		 (lambda()
		   (cons
		    (if argcast
			(list argname argcast)
			argname)
		    argnames)))
		(argproto (symbol-append argname ':: argtype))
		(rest (if (pair? (cdr def))
			  (cddr def)
			  '()))
		(cdefault #f)
		(keyword-arg #f))
	    (for-each
	     (lambda (dir)
	       (match-case
		dir
		((? string?)
		 (set! argcast dir))
		
		((null-ok)
		 (set! cdefault '("NULL")))		  
		
		((= . ?cdef)
		 (unless has-optional? (set! keyword-arg #!optional))
		 (set! cdefault cdef)
		 (set! has-optional? #t))
		
		(else
		 (error "define-func" "unsupported argument option" dir))))
	     rest)
	    (when(and (not cdefault)
		      has-optional?)
		 (error "define-func" "no default value given"def))
	    (case argtype
	      ;; FIXME: this is a case of general composite type
	      ((sized-string)
	       (loop
		;; proto
		(cons
		 (symbol-append argname '::bstring)
		 proto)
		(cons* `(string-length ,argname)
		       argname casts)
		(compose-argname+cast)
		(cdr proto-spec)))
	      (else
	       (loop
		(cons
		 (if cdefault argname argproto)
		 (if keyword-arg (cons keyword-arg proto)proto))
		(cons
		 (if cdefault
		     (list
		      argproto
		      (list 'or
			    argname
			    (cons (symbol-append 'pragma:: argtype)
				  cdefault)))
		     (list argproto argname))
		 casts)
		(compose-argname+cast)
		(cdr proto-spec)))))
	  (let((proto
		`(,(if (and declared-return-type (null? check-handlers))
		       (symbol-append sname ':: declared-return-type)
		       sname)
		  ,@(reverse proto)))
	       (argnames (reverse argnames))
	       (casts(reverse casts)))
	    
	    
	    (add-module-dirs!
	     `((export ,proto)))
	    
	    (add-body-dirs!
	     `((define ,proto
		 ,@(if *comment-code* (list cname) '())
		 ,(cond
		   ((pair? check-handlers)
		    `(let*( ,@casts
			    (retval ,(make-pragma cname 'int argnames)))
		       ,@(map
			  (lambda(h)
			    `(,h ,(symbol->string sname) retval))
			  check-handlers)))
		   
		   (declared-return-type
		    `(let ,casts
		       ,(make-pragma cname declared-return-type argnames)))
		   
		   (else
		    `(let ,casts
		       ,(make-pragma cname #f argnames)
		       #unspecified))))))
	    )))))

;*-------------------------------------------------------------------*;
;*  C global variable wrapper                                        *;
;*-------------------------------------------------------------------*;

;; FIXME: this is much like define-func, so both should be merged
;; sometimes

(define (define-global names return-spec . options)
  (define-name names #f
    ;; FIXME: return options (like converting NULL to #f) should be
    ;; treated here
    (define return-type
      (if(memq(normalize-symbols return-spec) '(none void))
	 #f
	 (namedef-sname return-spec)))
    
    (define proto
      (if return-type
	  `(,(symbol-append sname ':: return-type)
	     #!optional value)
	  sname))
    
    (add-module-dirs!
     `((export ,proto))
     )
   
    (add-body-dirs!
     `((define ,proto
	 (let((old(,(symbol-append 'pragma:: return-type) ,cname)))
	   (when value
		 (let((,(symbol-append 'value:: return-type) value))
		   (pragma ,(string-append cname " = $1") value)))
	   old))))))

;*-------------------------------------------------------------------*;
;*  import definitions from file                                     *;
;*-------------------------------------------------------------------*;

(define(import filename::bstring)

  (define *type-dirs* '())
  (define *other-dirs* '())
  (define path
    (or
     (find-file/path
      filename
      (if(null? *search-path*)
	 (list (dirname filename))
	 (reverse *search-path*)))
     (error "cgen import"
	    (format "Can't find file ~a in path" filename)
	    *search-path*)))

  (define exprs-raw
    ;; just read the file
    (with-input-from-file
	path
      (lambda()
	(let loop ((accu '()))
	  (let((expr(read)))
	     (if(eof-object? expr)
	       (reverse! accu)
	       (loop(cons expr accu))))))))
  (define exprs-filtered
    ;; process instructions like @if/@else/@endif
    (let process((lyst exprs-raw))
      (let loop((lyst lyst)
		(condition? #t)
		(inside? #f))
	(match-case
	 lyst
;	 ((@ ?s-expr . ?rest)
;	  (loop (cons (cpp->scheme s-expr) rest) condition? inside?))

	 ((@if ?cond-expr . ?rest)
	  (when inside?
		(error
		 "cgen"
		 "@if without a matching @endif encountered" ""))
	  (loop rest (eval cond-expr) #t))
	 ((@else . ?rest)
	  (unless inside?
		  (error
		   "cgen"
		   "@else without an @if encountered" ""))
	  (loop rest (not condition?) #t))
	 
	 ((@endif . ?rest)
	  (unless inside?
		  (error
		   "cgen"
		   "@else without an @if encountered" ""))
	  (loop rest #t #f))
	 ((?expr . ?rest)
	  (let((rest(loop rest condition? inside?)))
	    (if condition?
		(cons(process expr) rest)
		rest)))
	 (else
	  (when inside?
		(error
		 "cgen"
		 "@if without a matching @endif encountered" ""))
	  lyst)))))
  
  (for-each
   (lambda(expr)
     (match-case
      expr
      ((?directive . ?args)
       (let((directive(normalize-symbols directive)))
	  (case directive
	   ((module)
	    (if(pair? *module*)
	       ;; append to an existing module definition,
	       ;; ignore the new module name
	       (when(pair? args)
		    (add-module-dirs!(cdr args)))
	       ;; effectively set the module definition
	       (add-module-dirs! expr)))
	   
	   ((register-predicate!)
	    (let((name (normalize-symbols(car args)))
		 (proc::procedure
		  (eval(normalize-symbols (cadr args)))))
	      (when(assq name *predicate-list*)
		   (error "import" "predicate already defined"name))
	      (push! *predicate-list* (cons name proc))
	      (cgen-trace 1 "=> predicate" *predicate-list*)
	      ))
	   
	   ((set-current-predicate!)
	    (let((name(if(null? args)
			 'default
			 (normalize-symbols(car args)))))
	      (set! *current-predicate*
		    (cond((assq name *predicate-list*) => cdr)
			 (else
			  (error "set-predicate!"
				 "no such predicate was registered"
				 name))))
	      (cgen-trace 1 "= predicate" *current-predicate*)
	      ))
	   
	   ((define-enum define-enum-extended define-flags
	      define-func define-boxed define-object
	      define-accessors define-global
	      define-errcode
	      import
	      )
	    (cgen-trace 1 "== " directive args)
	    (apply (eval directive) args))
	   
	   ((define-static)
	    ;; define non-exported value
	    (add-body-dirs! `((define ,@args)))
	    (add-module-dirs!
	     `((static ,(car args)))))
	   
	   ((define-export)
	    ;; define exported value

	    ;; TODO: if necessary change the proto so it can be
	    ;; compiled by Bigloo (remove values after #!optional and
	    ;; #!key keywords)
	    (add-body-dirs! `((define ,@args)))
	    (add-module-dirs!
	     `((export ,(car args)))))
	   
	   (else
	    ;; other stuff goes to output directly
	    (add-body-dirs! (list expr))
	    ))))
      
      (else
       ;; other stuff goes to output directly
       (add-body-dirs! (list expr)))
      ))
   exprs-filtered)
  
  (sort-hierarchical! *type-dirs* third fourth)
  ;; (pp *type-dirs*)
  (for-each
   (lambda(expr)
     (try
      (apply (eval(car expr))(cdr expr))
      (lambda (escape proc mes obj)
	(with-output-to-port
	    (current-error-port)
	  (lambda()
	    (print "***ERROR:" proc ":" mes " -- " obj)
	    (print "while parsing: "expr)
	    (print "in file: "filename)))
	)))
   (append! *type-dirs* *other-dirs*)))

;*-------------------------------------------------------------------*;
;*  cgen main()                                                      *;
;*-------------------------------------------------------------------*;
(define *in* '())
(define *out* *out*)
(define *search-path* '())
;;(define *trace-level* 0)
(define *dump-renamings* #f)

(define(cgen-trace level . args)
  (when(>=fx *trace-level* level)
       (with-output-to-port
	   (current-error-port)
	 (lambda()
	   (for-each(lambda(o)(display* o #\space))args)
	   (newline)))))

;; should we prefix strings with the # (sharp) sign?
(define *bigloo-strings* #t)

(define(main argv)
  (args-parse
   (cdr argv)
   (section "Help")
   (("--version" (synopsis "Print version info and exit"))
    (display *cgen-version*)
    (exit 0))

   ((("-h" "--help")
     (help "Print this help message and exit"))
    (args-parse-usage #f)
    (exit 0))

   (section "Files")
   (("-o" ?name (synopsis "The name of the output file"))
    (set! *out* name))

   (("-I" ?dir (synopsis "Add  to file search path"))
    (push! *search-path* dir))

   (section "Options")

   (("-e" ?expr (synopsis "Eval a Scheme expression"))
    (eval (scheme-read-string expr)))

   (("-v" ?level (synopsis "Set trace level (default 0)"))
    (set! *trace-level*(string->number level)))

   (("--comment" (synopsis "Output original names of C functions"))
    (set! *comment-code* #t))

   (("--dump-renamings" ?file
     (synopsis "Print name translations to the file"))
    (set! *dump-renamings* file))

   (("--standard-strings"
     (synopsis "Do NOT prefix output strings with a sharp sign"))
    (set! *bigloo-strings* #f))

   (else
    (push! *in* else)))
  
  (if (null? *in*)
      (repl)
      
      (let((sp(open-output-string))
	   (in(reverse *in*)))
	
	(for-each import in)
	(fprintf sp ";; Created by cgen from ~a. Do not edit!~%" in)
	(with-output-to-port
	    sp
	  (lambda()
	    (set! *module* (reverse! *module*))
	    (match-case *module*
			((module ?- . ?-)
			 (pp(normalize-symbols *module*)))
			(else
			 (error "cgen" "no module definition in sources" in)))
	    (for-each (lambda(expr)
			(newline)
			(pp(normalize-symbols expr)))
		      (reverse *body*))))
	(let((contents (get-output-string sp)))
          (if (string? *out*)
              (with-output-to-file
                  *out*
                (lambda()(display contents)))
              (display contents)))
        
	(when *dump-renamings*
	      (with-output-to-file
		  *dump-renamings*
		(lambda()
		  (print "#!/bin/sh\n\nsed \\")
		  (for-each
		   (match-lambda
		    ((?from . ?to)
		     (unless (string=? (as-string from)
				       (as-string to))
			     (print "   -e 's|" from "|" to "|g' \\"))))
		   *cpp->scheme*))))
	)))

