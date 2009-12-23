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
 node
 (library common)
 (export
  (class node)
  (current-node . args)

  (generic node-parents::pair-nil ::node)
  (generic node-parent::node ::node)
  (generic node-parents-set! ::node parents::pair-nil)

  (generic node-root::node ::node)
  (generic node-ancestors::pair-nil ::node)
  (generic node-atts::pair-nil ::node)
  (generic node-add-attribute! ::node attname::bstring attvalue::bstring)
  (generic node-atts-set! ::node atts::pair-nil)
  (generic node-children-set! ::node children::pair-nil)
  (generic node-add-child! ::node child::node . after)
;   (generic node-bind! ::node parent::node)
;   (generic node-bind-descendants! ::node)
  (generic node-children::pair-nil ::node)
  (generic node-subtree::pair ::node)
  (generic node-descendants::pair-nil ::node)
  (generic node-data::bstring ::node)

  (generic node-rdn::bstring ::node)
  (generic node-modrdn! ::node ::bstring . deleteatt)
  (generic node-dn::bstring ::node)

  (attribute-first alist::pair-nil attname::bstring)
  (attribute-list::pair-nil alist::pair-nil attname::bstring)

  (generic node-attribute-first ::node attname::bstring)
  (generic node-attribute-list::pair-nil ::node attname::bstring)
  (generic node-remove-attribute! ::node attname::bstring . value)
  (generic node-replace-attribute! ::node attname::bstring . attvalues)
  (generic node-set-attribute! ::node attname::bstring attvalue::bstring)
  (generic node-title::bstring ::node)
  (generic node-lookup ::node dn::bstring)
  (generic node-display ::node port::output-port)
  (generic node-valid? ::node)
  (generic node-remove! ::node)

  (generic node-siblings::pair-nil self::node)
  (generic node-rsiblings::pair-nil self::node)
  (generic node-ifollows::node self::node)
  (generic node-lsiblings::pair-nil self::node)
  (generic node-ipreced::node self::node)
  (generic node-next-hierarchy::node self::node)
  (generic node-prev-hierarchy::node self::node)
  (generic node-dn-separator::char self::node)
  (generic node-dn-from-root::bool self::node)

  (node-lookup-child self::node rdn::bstring)
  node-root-registry::procedure
  (node-lookup-global dn::bstring)
  )
 (include "common.sch")
 (extern
  (include "string.h")
  )
 )

(define-parameter current-node)

(define (unimplemented-method-error name::bstring o)
  (error name "abstract method called" o))

(define-generic (node-parents::pair-nil self::node)
  '())

(define-generic (node-parent::node self::node)
  (let((parents (node-parents self)))
    (if(null? parents)
       self
       (car parents))))

;; List of ancestors starting from root
(define-generic (node-ancestors::pair-nil self::node)
  (grove-walk (list self) node-parents '()))

(define-generic (node-subtree::pair self::node)
  (grove-walk (list self)
	      node-children
	      '()))

(define-generic (node-root::node self::node)
  (let((ancestry(node-ancestors self)))
    (if(null? ancestry)
       self
       (car ancestry))))

(define-generic (node-atts-set! self::node atts::pair-nil)
  (unimplemented-method-error"node-atts-set!" self))

(define-generic (node-parents-set!::node self::node parents::pair-nil)
  (unimplemented-method-error"node-parents-set!" self))

(define-generic (node-atts::pair-nil self::node)
  '())

(define-generic (node-add-attribute! self::node
				    attname::bstring
				    attvalue::bstring)
  (node-atts-set!
   self
   (cons(cons attname attvalue)
	(node-atts self))))

(define-generic (node-children-set! self::node children::pair-nil)
  (unimplemented-method-error"node-children-set!" self))

(define-generic (node-add-child! self::node child::node . after)
  (let((children (node-children self)))
    (if(pair? after)
       (let((rest(memq (car after) children)))
	 [assert (self after)rest]
	 (set-cdr! rest (cons child(cdr rest))))
       (node-children-set!
	self
	(cons child (node-children self))))
    (node-parents-set!
     child
     (cons self(node-parents self)))))

; (define-generic (node-bind! self::node parent::node)
;   (let((parents(node-parents self)))
;     (for-each
;      (lambda(parent)
;        (node-children-set!
; 	parent
; 	(cons self (node-children parent))))
;      parents)
;     (node-parents-set!
;      self
;      (append parents(node-parents parent))))
;   self)

; (define-generic (node-bind-descendants! self::node)
;   (let loop((self self))
;     (for-each
;      (lambda(child)
;        (node-parents-set!
; 	child
; 	(cons self(node-parents child)))
;        (loop child))
;      (node-children self)))
;   self)

(define-generic (node-children::pair-nil self::node)
  '())

(define-generic (node-descendants::pair-nil self::node)
  (cdr (node-subtree self)))

(define-generic (node-data::bstring self::node)
  (apply string-append
	 (map
	  node-data
	  (node-children self))))

(define-generic (node-rdn::bstring self::node)
  (unimplemented-method-error"node-rdn" self))

(define-generic (node-modrdn! self::node newrdn::bstring . deleteatt)
  (unimplemented-method-error"node-modrdn" self))

(define-generic (node-dn-separator::char self::node)
  (unimplemented-method-error "node-dn-separator" self))

;; If (node-dn-from-root) is #t, the DN starts with the root's rdn,
;; otherwise from this node's rdn to root
(define-generic (node-dn-from-root::bool self::node)
  (unimplemented-method-error "node-dn-from-root" self))

(define-generic (node-dn::bstring self::node)
  (let((ancestry (node-ancestors self)))
    (print-list-delimited
     (map
      node-rdn
      (if (node-dn-from-root self)
	  ancestry
	  (reverse ancestry)))
     (node-dn-separator self))))

(define (attribute-first alist::pair-nil attname::bstring)
  (let((ass (assoc attname alist)))
    (and ass (cdr ass))))

(define (attribute-list::pair-nil alist::pair-nil attname::bstring)
  (map cdr
       (filter
	(lambda(ass)
	  (string=? (car ass)attname))
	alist)))

(define-generic (node-attribute-first self::node attname::bstring)
  (attribute-first (node-atts self) attname))

(define-generic (node-attribute-list::pair-nil self::node attname::bstring)
  (attribute-list (node-atts self) attname))

(define (attlist-remove alist attname #!optional values)
  (remove
   (lambda(ass)
     (and (string=? (car ass) attname)
	  (if (pair? values)
	      (member (cdr ass) values)
	      #t)))     
   alist))
;;(attlist-remove '(("asdf" . "qwerty")("asdf" . "zxcv")("asdf" . "qwerty")) "asdf" '("qwerty"))
;;(attlist-remove '(("asdf" . "qwerty")("asdf" . "zxcv")("asdf" . "qwerty")) "asdf")

(define-generic (node-remove-attribute! self::node attname::bstring . value)
  (node-atts-set!
   self
   (attlist-remove (node-atts self) attname value)))

;; remove all the old values, set the new values
(define-generic (node-replace-attribute! self::node attname::bstring . attvalues)
  (node-atts-set!
   self
   (append (map(lambda(v)(cons attname v))attvalues)
	   (attlist-remove (node-atts self) attname))))

(define-generic (node-set-attribute! self::node attname::bstring attvalue::bstring)
  (let*((atts (node-atts self))
	(ass (assoc attname atts)))
    (if ass
	(set-cdr! ass attvalue)
	(node-atts-set!
	 self
	 (cons(cons attname attvalue)atts)))))

;; Conventional utils

(define-generic (node-title::bstring self::node)
  (or (node-attribute-first self "cn")
      (symbol->string(class-name(object-class self)))))

(define (node-lookup-child self::node rdn::bstring)
  (let loop ((childs (node-children self)))
    (if (null? childs)
	#f
	(let((child(car childs)))
	  (if (string=? (node-rdn child) rdn)
	      child
	      (loop (cdr childs)))))))

(define (node-lookup-descendant self::node rdns)
  (if (null? rdns)
      self
      (let((found(node-lookup-child self(car rdns))))
	(and found
	     (node-lookup-descendant found(cdr rdns))))))


;; look up node with given `dn' in the same grove as `node'
;; return node or #f
(define-generic (node-lookup self::node dn::bstring)
  (define sep (node-dn-separator self))
  (define (dn->path dn)
    (let((path-native::pair-nil (string-split-by dn sep)))
      (if (node-dn-from-root self)
	  path-native
	  (reverse path-native))))
  (define root (node-root self))
  (let loop((root-path (dn->path (node-dn root)))
	    (this-path (dn->path dn)))
    (cond
     ((null? root-path)
      (node-lookup-descendant root this-path))
     ((null? this-path)
      #f)
     ((string=? (car root-path)(car this-path))
      (loop(cdr root-path)(cdr this-path)))
     (else
      ;; chunks differ
      #f))))

(define (node-lookup-global dn::bstring)
  (let((registry(node-root-registry dn)))
    (and registry(node-lookup registry dn))))

(define-generic (node-display self::node port::output-port)
  (display (node-title self)port))

(define-method (object-display self::node . op)
  (node-display
   self
   (if(null? op)
      (current-output-port)
      (car op))))

(define-generic (node-valid? self::node)
  #t)

(define-generic (node-siblings self::node)
  (let((parent(node-parent self)))
    (if (eq? parent self)
	'()
	(delete self (node-children parent)))))

; Note: If the node is not registered, is is treated as the last
; sibling node

(define-generic (node-rsiblings self::node)
  (let((parent(node-parent self)))
    (if(eq? parent self)
       '()
       (cond((memq self (node-children parent))
	     => cdr)
	    (else
	     '())))))

(define-generic (node-lsiblings::pair-nil self::node)
  (let((parent(node-parent self)))
    (if (eq? parent self)
	'()
	(take-while
	 (lambda(elt)
	   (not(eq? elt self)))
	 (node-children parent)))))

(define-generic (node-ifollows::node self::node)
  (let((rsiblings(node-rsiblings self)))
    (if (null? rsiblings)
	self
	(car rsiblings))))

(define-generic (node-ipreced::node self::node)
  (let((lsiblings(node-lsiblings self)))
    (if (null? lsiblings)
	self
	(car (last-pair lsiblings)))))

(define-generic (node-next-hierarchy::node self::node)
  (let((next(node-ifollows self)))
    (if(eq? next self)
       (node-ifollows(node-parent self))
       next)))

(define-generic (node-prev-hierarchy::node self::node)
  (let((prev(node-ipreced self)))
    (if(eq? prev self)
       (node-parent self)
       prev)))

(define node-root-registry
  (let((roots '()))
    (lambda( #!optional s delay)
      (if s
	  (if delay
	      (set! roots
		    (begin
		      [assert(s)(or(string? s)(procedure? s))]
		      (alist-cons s delay roots)))
	      (let((len(string-length s)))
		(let loop((alist roots))
		  (and(pair? alist)
		      (if
		       (let((match(caar alist)))
			 ;;(trace match)
			 (if(string? match)
			    (let((match-len(string-length match)))
			      ;;(trace s match(-fx len match-len))
			      (and(>=fx len match-len)
				  (string-contains
				   s
				   match
				   (-fx len match-len))))

			    ;; else match should be a procudure
			    (match s)))
		       (force(cdar alist))
		       (loop(cdr alist)))))))
	  ;; if called without parameters, returns the registry itself
	  ;; (for debugging)
	  roots))))
;;(node-root-registry ","(lambda() "found"))
;;(node-root-registry ",")
;;(node-root-registry)

;;(node-root-registry "dc=jet,dc=msk,dc=ru"(lambda() "found"))
;;(node-root-registry "root,dc=jet,dc=msk,dc=ru")

;; must report "assertion failed" if compiled with debug on
;;(node-root-registry #f (lambda()(display "found")))

;;(node-root-registry string-null?(lambda()(display "found")))
;;(node-root-registry "")

(define-generic (node-remove! self::node)
  (for-each
   (lambda (parent::node)
     (node-children-set!
      parent
      (delete! self (node-children parent))))
   (node-parents self))
  (node-parents-set! self '()))


