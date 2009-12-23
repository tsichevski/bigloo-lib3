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
 sgml-node
 (use    node)
 (import dl-node tree-node)
 (library common)
 (export
  (class sgml-element::tree-node
	 )
  (class sgml-char::dl-node
	      (text::bstring read-only))
  (class sgml-comment::dl-node
	      (text::bstring read-only))
  (class sgml-unparsed-data::dl-node
	      (text::bstring read-only))
  (class sgml-entity::dl-node
	      (name::bstring read-only))
  (class sgml-char-ref::dl-node
	      (value::int read-only))
  (class sgml-pi::dl-node
	      (text::bstring read-only))
  (sgml-copy-tree snl #!key
		  filter-element
		  filter-char
		  filter-comment
		  filter-entity
		  filter-pi
		  filter-unparsed-data)

  (sgml-node-display-xml node::sgml-element)
  (sgml-node-display-html node::sgml-element)
  (sgml-node-display node::sgml-element
		     #!optional (empty-elements '()))
  (sgml-element-instantiate
   gi
   #!rest
   children
   #!key
   parent
   atts)
  )
 (include "common.sch")
 )

(define-method (node-data::bstring self::sgml-char)
  (sgml-char-text self))

(define-method (node-data::bstring self::sgml-char-ref)
  ;; FIXME: need treate unicode characters
  (string(integer->char(sgml-char-ref-value self))))

;; decode well-known entities
(define-method (node-data::bstring self::sgml-entity)
  (let((name (sgml-entity-name self))) 
    (cond ((assoc name
		  '(("amp" . "&")
		    ("lt" . "<")
		    ("gt" . ">")
		    ("quot" . "\""))) => cdr)
	  (else
	   (format "&~a;"name)))))

;;(define-method (node-children-set! self::sgml-element children::pair-nil)
;;  (sgml-element-children-set! self children))

;; print as XML by default
(define (node-emit-stag self::sgml-element term)
  (display* "<"(sgml-element-gi self))
  (for-each
   (lambda(att)
     (display* " "
	       (car att)
	       "="
	       (let((attval::bstring (cdr att)))
		 (if (string-index attval #\')
		     (if (string-index attval #\")
			 (string-append "'"(pregexp-replace* "[']" attval "&apos;")"'")
			 (string-append "\"" attval "\""))
		     (string-append "'" attval "'")))))
   (node-atts self))
  (display*
   (if(null?(node-children self))
      term
      "")
   ">"))

(define (node-emit-etag self::sgml-element)
  (display* "</"(sgml-element-gi self)">"))

(define (sgml-node-display-children self::sgml-element
				    sgml-display::procedure)
  (for-each
   (lambda(o)
     ((if(sgml-element? o)
	 sgml-display
	 display)
      o))
   (node-children self)))

(define (sgml-node-display-xml self::sgml-element)
  (node-emit-stag self "/")
  (sgml-node-display-children self sgml-node-display-xml)
  (unless(null? (node-children self))
	 (node-emit-etag self)))

(define (sgml-node-display self::sgml-element #!optional (empty-elements '()))
  (node-emit-stag self "")
  (sgml-node-display-children
   self
   (lambda(o)
     (sgml-node-display o empty-elements)))
  (unless(member(sgml-element-gi self) empty-elements)
	 (node-emit-etag self)))

(define (sgml-node-display-html self::sgml-element)
  (sgml-node-display
   self
   '(basefont br area link img param hr input isindex base meta)))

(define-method (node-display self::sgml-element port::output-port)
  (with-output-to-port
      port
    (lambda()
      (sgml-node-display self))))

(define-method (node-display self::sgml-comment port::output-port)
  (with-output-to-port
      port
    (lambda()
      (display* "<!--"(sgml-comment-text self)"-->"))))

(define-method (node-display self::sgml-char port::output-port)
  (display(sgml-char-text self)port))

(define-method (node-display self::sgml-char-ref port::output-port)
  ;; FIXME: need more processing here
  (display(integer->char(sgml-char-ref-value self))port))

(define-method (node-display self::sgml-entity port::output-port)
  (with-output-to-port
      port
    (lambda()
      (display* "&"(sgml-entity-name self)";"))))

(define-method (node-display self::sgml-unparsed-data port::output-port)
  (display(sgml-unparsed-data-text self)port))

(define-method (node-display self::sgml-pi port::output-port)
  (with-output-to-port
      port
    (lambda()
      (display* "<?"(sgml-pi-text self)">"))))


(define (sgml-copy-tree snl
			#!key
			filter-element
			filter-char
			filter-comment
			filter-entity
			filter-pi
			filter-unparsed-data)
  (let loop((snl snl))
    (if(list? snl)
       (apply append(map loop snl))
       (let((node-list
	     (cond
	      ((sgml-element? snl)
	       (if(procedure? filter-element)
		  (or (filter-element snl)
		      (loop (sgml-element-children snl)))
		  (duplicate::sgml-element
		   snl
		   (atts(map values(sgml-element-atts snl)))
		   (children(loop(sgml-element-children snl))))))
	      ((sgml-char? snl)
	       (if(procedure? filter-char)
		  (filter-char snl)
		  snl))
	      ((sgml-comment? snl)
	       (if(procedure? filter-comment)
		  (filter-comment snl)
		  snl))
	      ((sgml-entity? snl)
	       (if(procedure? filter-entity)
		  (filter-entity snl)
		  snl))
	      ((sgml-unparsed-data? snl)
	       (if(procedure? filter-unparsed-data)
		  (filter-unparsed-data snl)
		  snl))
	      ((sgml-pi? snl)
	       (if(procedure? filter-pi)
		  (filter-pi snl)
		  snl))
	      (else snl))))
	 (if(list? node-list)
	    node-list
	    (list node-list))))))

;; Convenience procedure for using in the interpreter
(define (sgml-element-instantiate
         gi
	 #!rest
         children
         #!key
         parent
         atts)
  (let loop((children children)
	    (real-children '()))
    (match-case
     children
     (((? keyword?) ?- . ?children)
      ;; skip keywords and their arguments
      (loop children real-children))
     ((?arg . ?children)
      (loop children (cons arg real-children)))
     (else
      (instantiate::sgml-element
       (gi gi)
       (children (reverse real-children))
       (atts (or atts '()))
       (parents (if
		 parent
		 (list parent)
		 '())))))))
