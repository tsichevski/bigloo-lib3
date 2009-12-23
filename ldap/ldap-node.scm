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
 ldap-node
 (library common node)
 (import
  ldap
  ldap-utils
  cache-node
  )
 (export
  (class ldap-container
	 ldap::ldap
	 lookup::procedure)
  (class ldap-node::node
	 dn::bstring
	 container::ldap-container
	 (atts (default #f))
	 (children (default #f)))
  ;; FIXME: move it to node.scm!
  (ldap-node-flush-atts! node::ldap-node)
  (ldap-container-new #!optional connection)

  (ldap-node-search nodeo #!key base scope filter atts)

;;  *ldap-trace-level*
  )
 )

;;(define *ldap-trace-level* 0)

(define-inline (ldap-node-ldap node)
  (ldap-container-ldap(ldap-node-container node)))

(define-inline(ldap-node-lookup node)
  (ldap-container-lookup(ldap-node-container node)))

(define (dn-parent s::bstring)
  (let((found(pragma::string "strchr($1, ',')"($bstring->string s))))
    (and(pragma::bool "$1 != NULL" found)
	($string->bstring(pragma::string "$1 + 1" found)))))

(define (dn-rdn::bstring s::bstring)
  (let*((ss($bstring->string s))
	(found(pragma::string "strchr($1, ',')"ss)))
    (if(pragma::bool "$1 == NULL" found)
       s
       (substring s 0 (pragma::int "$1 - $2" found ss)))))

(define (ldap-container-new #!optional connection)
  (let((connection (or connection(current-ldap))))
    (letrec((container
	     (make-ldap-container
	      connection
	      (make-cache
	       ldap-node-dn
	       (lambda(dn)
		 (instantiate::ldap-node
		  (dn dn)
		  (container container)))))))
      container)))
;;(ldap-container-new)

(define-method (node-dn-separator self::ldap-node)
  ",")

(define-method (node-dn::bstring node::ldap-node)
  (ldap-node-dn node))
;;(node-dn(make-ldap-node "cn=wowa,o=jet,c=ru"))

(define-method (node-rdn::bstring node::ldap-node)
  (dn-rdn (ldap-node-dn node)))
;;(node-dn(make-ldap-node "cn=wowa,o=jet,c=ru"))

(define-method (node-modrdn! self::ldap-node newrdn::bstring . deleteatt)
  (with-access::ldap-node
   self
   (dn container)
   (let((newdn(string-append newrdn ","(dn-parent dn)))
	(lookup(ldap-container-lookup container))
	(ldap(ldap-container-ldap container)))
     (unless(string=? newdn dn)
	    ;;(trace ldap dn newrdn deleteatt)
	    (ldap-modrdn ldap dn newrdn
			 (and(not(null? deleteatt))
			     (car deleteatt)))
			    
	    (lookup dn 'remove)
	    (ldap-node-dn-set! self newrdn)
	    (lookup newdn 'insert self)))))


(define-inline(ldap-build-dn rdn-list)
  (print-list-delimited rdn-list ", "))

(define-method (node-lookup node::ldap-node dn::bstring)
  (let*((conn(ldap-node-container node))
	(lookup(ldap-container-lookup conn)))
    (lookup dn)))

(define-method (node-parents::node node::ldap-node)
  (let((parent-dn (dn-parent(ldap-node-dn node))))
    (if parent-dn
	(let((candidate(node-lookup node parent-dn)))
	  (if(node-valid? candidate)
	     (list candidate)
	     '()))
	'())))
;;(node-parents *current-node*)

;; FIXME: the abstract generic must me declared in node.scm
(define-method (node-remove! node::ldap-node)
  (with-access::ldap-node
   node
   (container dn)
   (ldap-delete (ldap-container-ldap container) dn)
   ((ldap-container-lookup container)dn 'remove)
   ))

(define(ldap-node-flush-atts! node::ldap-node)
  ;; total amnesia
  (ldap-node-atts-set! node #f))

(define-method (node-add-attribute! self::ldap-node
				    attname::bstring
				    attvalue::bstring)
  ;; WARNING: no check for uniquesness
  (let*((container(ldap-node-container self))
	(ldap(ldap-container-ldap container))
	(dn(ldap-node-dn self)))
    (ldap-modify-add ldap dn (list(list attname attvalue))))
  (ldap-node-flush-atts! node))

(define-method (node-remove-attribute! self::ldap-node attname::bstring . value)
  (let*((container(ldap-node-container self))
	(ldap(ldap-container-ldap container))
	(dn(ldap-node-dn self)))
    (ldap-modify-delete ldap dn(list(cons attname value))))
  (ldap-node-flush-atts! self))

(define-method (node-replace-attribute! self::ldap-node attname::bstring . attvalues)
  (if(null? attvalues)
     (node-remove-attribute! self attname)
     (let*((container(ldap-node-container self))
	   (ldap(ldap-container-ldap container))
	   (dn(ldap-node-dn self)))
       (ldap-modify-replace ldap dn(list(cons attname attvalues)))))
  (ldap-node-flush-atts! self))

(define(decode-ldap-answer answer::pair-nil)
  ;; note: ldap-answer returns attributes in
  ;; (list attname . multiple-attvalues) form
  (map-append
   (lambda(ass)
     (let((attname(read(open-input-string(car ass)))))
       (map
	(lambda(attval)
	  (cons attname attval))
	(cdr ass))))
   answer))
;;(decode-ldap-answer (cdr jet))

;; do ldap-search request and intern all the result
(define (ldap-node-search node
			  #!key
			  base
			  scope
			  filter
			  atts)
  (let*((base (or base (ldap-node-dn node)))
	(scope (or scope 'subtree))
	(filter (or filter "objectclass=*"))
	(ld (ldap-node-ldap node))
	(lookup(ldap-node-lookup node))
	(answer(ldap-answer
		ld
		(ldap-search ld base: base scope: scope filter: filter))))
    (when (>fx *ldap-trace-level* 0)
	  (fprintf(current-error-port)
		  "base: `~a' scope: `~a' filter: `~a' atts: ~a returned: ~a entries~%"
		  base scope filter atts (length answer)))
    (map
     (lambda(thunk)
       (let*((dn(car thunk))
	     (node(lookup dn)))
	 (unless(ldap-node-atts node)
		(ldap-node-atts-set! node(decode-ldap-answer(cdr thunk))))
	 (let((parent-dn(dn-parent dn)))
	   (when parent-dn
		 (let((parent(lookup parent-dn)))
		   (let((parent-childs(or(ldap-node-children parent) '())))
		     (unless(memq node parent-childs)
			    (ldap-node-children-set!
			     parent
			     (cons node parent-childs)))))))
	 node))
     answer)))
;;(define s(ldap-node-search *current-node* scope: 'onelevel))
;;(ldap-node-search *current-node* base: "dc=msk,dc=su")
;;(ldap-node-search *current-node* scope: 'subtree)

(define-method (node-atts::pair-nil node::ldap-node)
  (or(ldap-node-atts node)
     (begin(ldap-node-search node scope: 'base)
	   (ldap-node-atts node))
     (begin(ldap-node-atts-set! node '())
	   '())))     

(define-method (node-children::pair-nil node::ldap-node)
  (or(ldap-node-children node)
     (begin(ldap-node-search node scope: 'onelevel)
	   (ldap-node-children node))
     (begin(ldap-node-children-set! node '())
	   '())))

;; FIXME: atts use for title cinstruction should go to
;; ldap-node subclasses methods!
(define-method (node-title::bstring node::ldap-node)
  (or
   (node-attribute-first node "ou")
   (node-attribute-first node "documentTitle")
   (call-next-method)))
;;(node-title *base-node*)
;;(node-atts *base-node*)

(define-method (node-valid? self::ldap-node)
  (pair?(node-atts self)))

