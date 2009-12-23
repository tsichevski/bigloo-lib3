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
 ldap-schema
 ;;(use ldap-node)
 (library common node)
 (include "common.sch")
 (export
  ;*-------------------------------------------------------------------*;
  ;*  schema                                                           *;
  ;*-------------------------------------------------------------------*;
  (class ldap-schema::node
	 (syntaxes::pair-nil (default '()))
	 (attribute-types::pair-nil (default '()))
	 (objectclasses::pair-nil (default '()))
	 (matchingrules::pair-nil (default '()))
	 (matchingruleuse::pair-nil (default '()))
	 )

  (ldap-schema-read-subschema #!key port schema include-path)
  (ldap-schema-lookup-attribute name::bstring #!optional schema)
  (ldap-schema-lookup-objectclass name::bstring #!optional schema)
  (ldap-schema-lookup-syntax name::bstring #!optional schema)
  (ldap-schema-lookup-matchingrule name::bstring #!optional schema)

  (make-default-schema::ldap-schema)
  (ldap-schema-bind! ::ldap-schema)

  ;*-------------------------------------------------------------------*;
  ;*  abstract schema object                                           *;
  ;*-------------------------------------------------------------------*;
  ;; unnamed objects
  (class ldap-schema-object::node
	 (schema::ldap-schema read-only)
	 (oid::bstring read-only)
	 (desc read-only) ;; string or #f
	 (extra::pair-nil read-only)) ;; attributes with name `x-...'

  ldap-object-register!::procedure

  ;*-------------------------------------------------------------------*;
  ;*  syntax                                                           *;
  ;*-------------------------------------------------------------------*;
  (final-class ldap-syntax::ldap-schema-object
	 ;;(human-readable::bool read-only)
	 )

  (generic encode::bstring ::ldap-syntax o)
  (generic decode          ::ldap-syntax ::bstring)
  (generic check           ::ldap-syntax ::bstring)
  (current-ldap-schema . args)

  ;*-------------------------------------------------------------------*;
  ;*  named object                                                     *;
  ;*-------------------------------------------------------------------*;
  ;; objects which have name
  (class ldap-schema-named-object::ldap-schema-object
	 (name::bstring read-only)) ;; string or #f

  ;*-------------------------------------------------------------------*;
  ;*  attribute type                                                   *;
  ;*-------------------------------------------------------------------*;
  (final-class ldap-attribute-type::ldap-schema-named-object
	 (obsolete::bool read-only)
	 (sup read-only) ;; ldap-attribute-type or #f
	 (equality read-only) ;; ldap-matching-rule or #f
	 (ordering read-only) ;; ldap-matching-rule or #f
	 (substr read-only) ;; ldap-matching-rule or #f
	 (syntax::ldap-syntax read-only) ;; ldap-syntax
	 (length read-only)
	 (single-value::bool read-only)
	 (collective::bool read-only)
	 (no-user-modification::bool read-only)
	 (usage::symbol read-only)
	 )

  ;*-------------------------------------------------------------------*;
  ;*  objectclass                                                      *;
  ;*-------------------------------------------------------------------*;
  (final-class ldap-objectclass::ldap-schema-named-object
	 (obsolete::bool read-only)
	 (sup read-only (default '())) ;; list of ldap-objectclass
	 ;; abstract structural auxiliary
	 (type::symbol read-only(default 'structural))
	 (must::pair-nil read-only (default '()))
	 (may::pair-nil read-only (default '()))
	 (allowsoc::pair-nil (default '()))

	 ;; This used (introduced?) by Novell
	 (named-by read-only (default #f))
	 )

  (generic genid::bstring ::ldap-objectclass ::node)

  ;*-------------------------------------------------------------------*;
  ;*  matchingrule                                                     *;
  ;*-------------------------------------------------------------------*;
  (final-class ldap-matchingrule::ldap-schema-named-object
	 (obsolete::bool read-only)
	 (syntax::ldap-syntax read-only)
	 )
  ;*-------------------------------------------------------------------*;
  ;*  matchingruleuse                                                  *;
  ;*-------------------------------------------------------------------*;
  (final-class ldap-matchingruleuse::ldap-schema-named-object
	 (obsolete::bool read-only)
	 (applies::pair-nil read-only) ;; list of ldap-attribute-type
	 )
  ;;(ldap-schema-grammar ::input-port)

  ;*-------------------------------------------------------------------*;
  ;*  misc                                                             *;
  ;*-------------------------------------------------------------------*;
  (escape-ldap-schema-string::bstring str::bstring)
  (unescape-ldap-schema-string::bstring str::bstring)

  )
 ;;(eval(export-all))
 )

(define-parameter current-ldap-schema)
(current-ldap-schema(make-default-schema))

;*-------------------------------------------------------------------*;
;*  ldap-schema-object methods                                       *;
;*-------------------------------------------------------------------*;
(define(escape-ldap-schema-string str)
  (string-append
   "'"
   (string-grammar-apply
    str
    (lambda(port)
      (read/rp
       (regular-grammar
	()
	((in "'$#\\" #\newline #\return)
	 (string-append "\\"(char->hex(the-failure)))))
       port)))
   "'"))

;;(pp(escape-ldap-schema-string "as'df"))

(define(unescape-ldap-schema-string str)
  (string-grammar-apply
   str
   (lambda(port)
     (read/rp
      (regular-grammar
       ()
       ((: #\\ xdigit xdigit)
	(integer->char(string->number(the-substring 1 3)16))))
      port))))

(define-method (node-display self::ldap-schema-object port::output-port)
  (with-access::ldap-schema-object
   self
   (oid desc extra)
   (with-output-to-port
       port
     (lambda()
       (display oid)
       (when desc
	     (display* " DESC " (escape-ldap-schema-string desc)))
       (for-each
	(lambda(ass)
	  (display* " X-"(car ass)" "(escape-ldap-schema-string(cdr ass))))
	extra)))))
       
;; FIXME: this is ordinary make-cache proc
(define ldap-object-register!
  (let((*ldap-object-registry* '()))
    (lambda (oid::bstring #!optional proc)
      (if proc
	  (push! *ldap-object-registry*(cons oid proc))
	  (let((found(assoc oid *ldap-object-registry*)))
	    (and found(cdr found)))))))

(define(ldap-schema-object-bind o::ldap-schema-object)
  (let((proc(ldap-object-register!
	     (ldap-schema-object-oid o))))
    (if proc(proc o)o)))

(define(ldap-schema-bind! schema::ldap-schema)
  (with-access::ldap-schema
   schema
   (syntaxes attribute-types objectclasses matchingrules matchingruleuse)
   
   (for-each
    (lambda(lst)(for-each ldap-schema-object-bind lst))
    (list syntaxes attribute-types objectclasses
	  matchingrules matchingruleuse)))
  schema)

;*-------------------------------------------------------------------*;
;*  ldap-schema-named-object methods                                 *;
;*-------------------------------------------------------------------*;
(define-method (node-display self::ldap-schema-named-object port::output-port)
  (call-next-method)
  (with-access::ldap-schema-named-object
   self
   (name)
   (with-output-to-port
       port
     (lambda()
       (display* " NAME " name)))))

;*-------------------------------------------------------------------*;
;*  ldap attribute definition methods                                *;
;*-------------------------------------------------------------------*;

(define-method (node-display self::ldap-attribute-type port::output-port)
  (with-access::ldap-attribute-type
   self
   (obsolete sup equality ordering substr syntax
	     length single-value collective no-user-modification usage)
   (with-output-to-port
       port
     (lambda()
       (call-next-method)
       (and obsolete(display " OBSOLETE"))
       (and sup(display* " SUP "(ldap-schema-object-oid sup)))
       ;; FIXME: ... other slots need to be printed here
       ))))
;*-------------------------------------------------------------------*;
;*  ldap syntax methods                                              *;
;*-------------------------------------------------------------------*;
(define-generic(encode::bstring syntax::ldap-syntax o)
  o)

(define-generic(decode syntax::ldap-syntax s::bstring)
  s)

(define-generic(check syntax::ldap-syntax s::bstring)
  s)

;*-------------------------------------------------------------------*;
;*  ldap objectclass methods                                         *;
;*-------------------------------------------------------------------*;
(define-generic(genid::bstring self::ldap-objectclass nd::node)
  (or (node-attribute-first nd "uid")
      (symbol->string(gensym(ldap-schema-named-object-name self)))))

(define-method (node-display self::ldap-objectclass port::output-port)
  (with-access::ldap-objectclass
   self
   (obsolete sup type must may allowsoc named-by)
   (with-output-to-port
       port
     (lambda()
       (call-next-method)
       (when obsolete(display " OBSOLETE"))
       (when type(display* " " type))
       (when named-by
	     (display* " X-NAMED-BY "(ldap-schema-named-object-name named-by)))
       (for-each
	(lambda(oc)
	  (display* " SUP "(ldap-schema-object-oid oc)))
	sup)
       (and(pair? must)
	   (display* " MUST ( "
		     (print-list-delimited(map ldap-schema-named-object-name must) " $ ")
		     " ) "))

       (and(pair? may)
	   (display* " MAY ( "
		     (print-list-delimited(map ldap-schema-named-object-name may) " $ ")
		     " ) "))
       ;; FIXME: ... other slots need to be printed here
       ))))

;*-------------------------------------------------------------------*;
;*  ldap schema methods                                              *;
;*-------------------------------------------------------------------*;
(define-method (node-display self::ldap-schema port::output-port)
  (with-access::ldap-schema
   self
   (syntaxes attribute-types objectclasses matchingrules matchingruleuse)
   (with-output-to-port
       port
     (lambda()
       (for-each
	(lambda(self)
	  (print "ldapSyntaxes: ("self")"))
	(reverse syntaxes))
       (for-each
	(lambda(self)
	  (print "attributeTypes: ("self ")"))
	(reverse attribute-types))
       (for-each
	(lambda(self)
	  (print "objectClasses: ("self ")"))
	(reverse objectclasses))
       (for-each
	(lambda(self)
	  (print "matchingRules: ("self ")"))
	(reverse matchingrules))
       (for-each
	(lambda(self)
	  (print "matchingRuleUse: ("self ")"))
	(reverse matchingruleuse))
       ))))

(define (ldap-schema-grammar port::input-port)
  (read/rp (regular-grammar
    (
     (a (in ("azAZ")))
     (d (in ("09")))
     ;     (hex-digit (or d (in ("afAF"))))
     (k (or a d "-" ";" "."))
     ;     (p (or a d (in "\()+,-./:? ")))
     ;     (letterstring (+ a))
     (numericstring (+ digit))
     ;(anhstring (+ k))
     (keystring (: a (* k)))
     ;     (printablestring (+ p))
     ;     (space (+ " "))
     ;     (whsp (? space))
     ;     (qdstring (: whsp "'"(*(out "'")) "'" whsp))
     ;     (qdstringlist (* qdstring))
     ;     (qdstrings (or qdstring (: whsp "(" qdstringlist ")" whsp)))
     ;	     
     ;     (descr keystring)

     ;; this differs from rfc2252 in that oid may be non-numeric
     (numericoid (: numericstring (+ (: "." numericstring))))
     ;     (woid (: whsp oid whsp))
     ;     (oidlist (: woid (*(: "$" woid))))
     ;     (oids (or woid (: "(" oidlist ")")))
     ;
     ;     (qdescr (: whsp "'" (submatch descr) "'" whsp))
     ;     (qdescrlist (* qdescr))
     ;     (qdescrs (or qdescr (: whsp "(" qdescrlist ")" whsp)))
     ;
     ;     (len numericstring)
     ;     (noidlen (: numericoid (? "{" len "}")))
     )
	    
    ((: #\# (* all))  (ignore))
    (#\newline        (ignore))
    (blank (ignore))

    ("(" 'lparen)
    (")" 'rparen)
    ("{" 'lcurly)
    ("}" 'rcurly)
    ("$" 'dollar)

    ((: "'" (submatch(+(out "'")))"'")
     (cons 'qdstring
	   (unescape-ldap-schema-string(the-submatch 1))))
    (numericoid `(numericoid . ,(the-string)))
    (numericstring `(numeric . ,(the-fixnum)))
    ((: (submatch keystring) #\:)
     `(command . ,(string->symbol-ci(the-submatch 1))))
    (keystring
     (let((keystring(the-string))
	  (key(the-symbol)))
       (case key
	 ((applies must may not oc
		   form collective desc equality name
		   no-user-modification obsolete ordering
		   single-value substr sup syntax usage
		   extra)
	  key)

	 ((abstract structural auxiliary)
	  `(type . ,key))

	 (else
	  (let((len(string-length keystring)))
	    (if(and(>fx len 2)
		   (string-ci=?(substring keystring 0 2)"x-"))
	       `(extra . ,(string->symbol-ci(substring keystring 2 len)))
	       `(keystring . ,keystring)))


;	  (string-case
;	   keystring
;	   ((bol(:(uncase "x-")(submatch (+ all))))
;	    `(extra . ,(string->symbol-ci(the-submatch 1))))
;	   (else
;	    `(keystring . ,keystring)))
	  )))))
   port))

;*-------------------------------------------------------------------*;
;*  Find attribute by name or oid                                    *;
;*-------------------------------------------------------------------*;
(define(ldap-schema-lookup lst::pair-nil name::bstring)
  (let loop((lyst lst))
    (if(null? lyst)
       #f
       (let((o(car lyst)))
	 (if
	  (or
	   (and(ldap-schema-named-object? o)
	       (string-ci=?
		(ldap-schema-named-object-name o)
		name))
	   (string-ci=?(ldap-schema-object-oid o)name))
	  o
	  (loop(cdr lyst)))))))

(define(ldap-schema-lookup-mandatory lst::pair-nil name::bstring)
  (or(ldap-schema-lookup lst name)
     (error "ldap-schema-lookup-mandatory"
	    "no object: name/list" (cons name lst))))

(define (ldap-schema-lookup-attribute name::bstring #!optional schema)
  (ldap-schema-lookup
   (ldap-schema-attribute-types (or schema (current-ldap-schema)))
   name))
;;(ldap-schema-lookup-attribute(make-default-schema)"objectClass")

(define (ldap-schema-lookup-objectclass
	 name::bstring
	 #!optional schema)
  (ldap-schema-lookup (ldap-schema-objectclasses
		       (or schema (current-ldap-schema)))
		      name))

(define (ldap-schema-lookup-syntax
	 name::bstring
	 #!optional schema)
  (ldap-schema-lookup
   (ldap-schema-syntaxes (or schema (current-ldap-schema)))
   name))

(define (ldap-schema-lookup-matchingrule
	 name::bstring
	 #!optional schema)
  (ldap-schema-lookup
   (ldap-schema-matchingrules (or schema (current-ldap-schema)))
   name))

(define(make-default-schema)
  (instantiate::ldap-schema))

(define-macro(insert-item! lyst item)
  `(let((@item ,item))
     (if(ldap-schema-lookup
	 ,lyst
	 (ldap-schema-object-oid @item))
	(begin
	 [assert(@item ,lyst)#f]
	 (error "insert-item!" "already exists" (cons @item ,lyst)))
	(push! ,lyst @item))))

(define-macro(declare-slot-adder class-name slot-name slot-type)
  `(define(,(symbol-append class-name '- slot-name '-add!)
	   ,(symbol-append 'o:: class-name)
	   ,(symbol-append 'val:: slot-type))
     (,(symbol-append class-name '- slot-name '-set!)
      o
      (cons val (,(symbol-append class-name '- slot-name) o)))))

(declare-slot-adder ldap-schema syntaxes ldap-syntax)
(declare-slot-adder ldap-schema objectclasses ldap-objectclass)
(declare-slot-adder ldap-schema attribute-types ldap-attribute-type)
(declare-slot-adder ldap-schema matchingrules ldap-matchingrule)
(declare-slot-adder ldap-schema matchingruleuse ldap-matchingruleuse)
;;(expand-once '(declare-slot-adder ldap-schema attribute-types ldap-schema-attribute))

(define (ldap-schema-read-subschema #!key port schema include-path)
  (let read-internal((port(or port(current-input-port)))
		     (schema(make-default-schema))
		     (include-path(or include-path '("."))))
    (let((lookup-attribute
	  (lambda(name)
	    (ldap-schema-lookup-mandatory (ldap-schema-attribute-types schema) name)))
	 (lookup-objectclass
	  (lambda(name)
	    (ldap-schema-lookup-mandatory (ldap-schema-objectclasses schema)name)))
	 (lookup-syntax
	  (lambda(name)
	    (ldap-schema-lookup-mandatory (ldap-schema-syntaxes schema)name)))
	 (lookup-matchingrule
	  (lambda(name)
	    (ldap-schema-lookup-mandatory (ldap-schema-matchingrules schema)name)))
	 )
      (let*((namev '())
	    (descv                #f)
	    (obsoletev::bool      #f)
	    (supv                 '())
	    (equalityv            #f)
	    (orderingv            #f)
	    (substrv              #f)
	    (syntaxv              #f)
	    (lengthv              #f)
	    (single-valuev::bool  #f)
	    (collectivev::bool    #f)
	    (no-user-modificationv::bool #f)
	    (usagev::symbol       'userApplications)
	    (typev::symbol        'structural)
	    (mustv                '())
	    (mayv                 '())
	    (appliesv             '())
	  
	    ;; non-standard extensions
	    (extrav               '())
	    (allowsocv            '())
	    (named-byv            #f)

	    (make-object
	     (lambda(command numericoid)
	       (case command
		 ((ldapSyntaxes)
		  (ldap-schema-syntaxes-add!
		   schema
		   (make-ldap-syntax
		    schema
		    numericoid
		    descv
		    extrav)))
	       
		 ((attributeTypes)
		  (let*((sup(if(null? supv)
			       #f
			       (lookup-attribute(car supv))))
		      
			(lookup-matchingrule-hierarchy
			 (lambda(name getter)
			   (or(and name(lookup-matchingrule equalityv))
			      (and sup(getter sup)))))
			(esyntax
			 (cond
			  (syntaxv (lookup-syntax syntaxv))
			  (sup (ldap-attribute-type-syntax sup))
			  (else
			   (error "ldap-schema-read-subscheme"
				  "at least one of SUP or SYNTAX must be defined for attribute definition"
				  numericoid)))))

		    (for-each
		     (lambda(name)
		       (ldap-schema-attribute-types-add!
			schema
			(make-ldap-attribute-type
			 schema
			 numericoid
			 descv
			 extrav
			 name
			 obsoletev
			 sup
			 (lookup-matchingrule-hierarchy equalityv ldap-attribute-type-equality)
			 (lookup-matchingrule-hierarchy orderingv ldap-attribute-type-ordering)
			 (lookup-matchingrule-hierarchy substrv ldap-attribute-type-substr)
			 esyntax
			 lengthv
			 single-valuev
			 collectivev
			 no-user-modificationv
			 usagev)))
		     namev)))
		 ((objectClasses)
		  ;;(print "insert oc: " numericoid)
		  (for-each
		   (lambda(name)
		     (let((new
			   (make-ldap-objectclass
			    schema
			    numericoid
			    descv
			    extrav
			    name
			    obsoletev
			    (map lookup-objectclass supv)
			    typev
			    (map lookup-attribute mustv)
			    (map lookup-attribute mayv)
			    '();; be replaced in a next line
			    named-byv
			    )))

		       ;; NOTE: since allowsoc may refer to object about to
		       ;; create, we need to bind this slot after the object is
		       ;; registered
		       (ldap-schema-objectclasses-add! schema new)
		       (ldap-objectclass-allowsoc-set!
			new
			(map lookup-objectclass allowsocv))))
		   namev))
	       
		 ((matchingRules)
		  (for-each
		   (lambda(name)
		     (ldap-schema-matchingrules-add!
		      schema
		      (make-ldap-matchingrule
		       schema
		       numericoid
		       descv
		       extrav
		       name
		       obsoletev
		       (if syntaxv
			   (lookup-syntax syntaxv)
			   (error "make-ldap-matchingrule"
				  "no synax given"
				  numericoid))
		       )))
		   namev))
	       
		 ((matchingRuleUse)
		  (for-each
		   (lambda(name)
		     (ldap-schema-matchingruleuse-add!
		      schema
		      (ldap-schema-object-bind
		       (make-ldap-matchingruleuse
			schema
			numericoid
			descv
			extrav
			name
			obsoletev
			(map lookup-attribute appliesv)
			))))
		   namev))
		 (else
		  (error "ldap-schema-read-subscheme"
			 "unknown subschema attribute"
			 command)))
	       (set! namev '())
	       (set! descv                #f)
	       (set! obsoletev            #f)
	       (set! supv                 '())
	       (set! equalityv            #f)
	       (set! orderingv            #f)
	       (set! substrv              #f)
	       (set! syntaxv              #f)
	       (set! lengthv              #f)
	       (set! single-valuev        #f)
	       (set! collectivev         #f)
	       (set! no-user-modificationv #f)
	       (set! usagev               'userApplications)
	       (set! typev                'structural)
	       (set! mustv                '())
	       (set! mayv                 '())
	       (set! appliesv             '())
	       (set! extrav               '())
	       (set! allowsocv            '())
	       (set! named-byv            #f)
	       )))
      
      
	(read/lalrp
	 (lalr-grammar
	  (command lparen rparen lcurly rcurly dollar
		   numericoid numeric qdstring keystring
		 
		   name desc obsolete sup equality
		   ordering substr syntax single-value collective
		   no-user-modification usage
		   must may type applies
		 
		   extra
		   )
	  (top
	   (() #unspecified)
	   ((top item)
	    #unspecified))
	  (item	  
	   ((command lparen numericoid exprlist rparen)
	    (make-object command numericoid))
	   ((command lparen keystring exprlist rparen)
	    (make-object command keystring))
	   ((command qdstring)
	    (case command
	      ((include)
	       ;; lookup other schema file
	       (let((ip(open-input-file
			(or(find-file/path qdstring include-path)
			   (error "ldap-schema-read-subschema"
				  "cannot find include file"
				  qdstring)))))
		 (unwind-protect
		  (read-internal ip schema include-path)
		  (close-input-port ip))))
	      (else
	       (error "ldap-schema-read-subschema"
		      "unknown command"
		      (cons command qdstring)))))
	   )
	
	  (exprlist
	   (())
	   ((exprlist expr)))
	
	  (expr
	   ((name qdstrings)
	    ;; FIXME: need check that qdstring-s are qdescr-s really
	    (set! namev qdstrings))
	   ((desc qdstring)(set! descv qdstring))
	   ((obsolete)(set! obsoletev #t))
	   ((sup oids)(set! supv oids))
	   ((equality oid)(set! equalityv oid))
	   ((ordering oid)(set! orderingv oid))
	   ((substr oid)(set! substrv oid))
	   ((syntax noidlen)
	    (set! syntaxv (car noidlen))
	    (set! lengthv (cdr noidlen))
	    )
	   ((single-value)
	    (set! single-valuev #t))
	   ((collective)
	    (set! collectivev #t))
	   ((no-user-modification)
	    (set! no-user-modificationv #t))
	   ((usage keystring)
	    (let((key(string->symbol-ci keystring)))
	      (if(memq key
		       '(userApplications directoryOperation
					  distributedOperation dSAOperation))
		 (set! usagev key)
		 (error "attribute-type-read" "invalid 'usage' field"
			keystring))))
	   ((type)
	    (set! typev type))
	   ((may oids)
	    (set! mayv oids))
	   ((must oids)
	    (set! mustv oids))
	   ((applies oids)
	    (set! appliesv oids))
	   ((extraval)
	    (for-each
	     (lambda(ass)
	       (case(car ass)
		 ((allowsoc)
		  (push! allowsocv(cdr ass)))
		 ((named-by)
		  (set! named-byv(lookup-attribute(cdr ass))))
		 (else
		  (push! extrav ass))))
	     extraval))
	   )
	     
	  (extraval
	   ((extra qdstrings)
	    (map(lambda(s)(cons extra s))qdstrings))
	   ((extra keystring)(list(cons extra keystring))))

	  (noidlen
	   ((oid)
	    (cons oid #f))
	   ((oid lcurly numeric rcurly)
	    (cons oid numeric)))
      
	  (qdstringlist
	   (()
	    '())
	   ((qdstringlist qdstring)
	    (cons qdstring qdstringlist)))
      
	  (qdstrings
	   ((qdstring)(list qdstring))
	   ((lparen qdstringlist rparen)
	    (reverse qdstringlist)))
      
	  (oid
	   ((keystring) keystring)
	   ((numericoid)numericoid))

	  (oidlist
	   ((oid)
	    ;;(print " first oid: "oid)
	    (list oid))
	   ((oidlist dollar oid)
	    ;;(print " next oid: "oid oidlist)
	    (cons oid oidlist)))

	  (oids
	   ((oid)
	    (list oid))
	   ((lparen oidlist rparen)
	    oidlist))
	  )
	 ldap-schema-grammar
	 port)))
    schema))

;;(with-input-from-file "../etc/ldap-schema.ldif" ldap-schema-read-subscheme)
