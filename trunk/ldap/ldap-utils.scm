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
 ldap-utils
 (import
  ldap
  ;;(ldap "ldap.scm")
  )
 (library common)
 (include "common.sch")
 (extern
  (include "string.h")
  )
 (export
  (ldap-answer::pair-nil ld::ldap msgid::int)
  (ldap-delete-recursive::pair-nil ld::ldap dn::bstring)
  (current-ldap . args)
  (ldap-defbase::bstring #!optional arg default)
  (ldap-commit! dn::bstring new-atts::pair #!optional ldap)
  (make-ldap-filter-clause::bstring attname attvalue::bstring #!optional match)
  ))

(define-parameter current-ldap)
(current-ldap(ldap-init))

(define *ldap-defbase* #f)

(define (ldap-defbase::bstring #!optional arg default)
  (cond((string? arg)
	(set! *ldap-defbase* arg))
       
       ((ldap? arg)
	(let((answer (ldap-answer arg (ldap-search arg scope: 'base))))
	  (if (null? answer)
	      (if default
		  (set! *ldap-defbase* default)
		  (error "ldap-defbase"
			 "no base configured in ldap.conf and no default given"
			 arg))
	      (set! *ldap-defbase*(caar answer)))))
       (else
	(or *ldap-defbase* (ldap-defbase (current-ldap)))))
  *ldap-defbase*)

(define(ldap-answer ld msgid)
  (let((res(ldap-result ld msgid)))
    (let loop((msg(ldap-first-entry ld res))
	      (accu '()))
      (if msg
	  (let((node(cons(ldap-get-dn ld msg)
			 (ldap-get-attributes ld msg))))
	    (loop
	     (ldap-next-entry ld msg)
	     (cons node accu)))
	  (begin(ldap-message-free res)
		(reverse accu))))))

(define(ldap-commit! dn::bstring new-atts::pair #!optional ldap)
  ;; проверяем, есть ли такой узел
  (let*((ldap (or  (ldap (current-ldap))))
	(found(ldap-answer ldap(ldap-search ldap base: dn scope: 'base))))
    (if(null? found)
       ;; новая запись
       (ldap-add ldap dn new-atts)
       (let((previous-atts(cdar found)))

	 (define(car-string-ci=? a b)
	   (string-ci=?(car a)(car b)))
	 
	 (define(attribute=? a b)
	   (and(car-string-ci=? a b)
	       (lset= string=?(cdr a)(cdr b))))
	 
	 ;; remove atribute values
	 (ldap-modify-delete
	  ldap dn
	  (lset-difference car-string-ci=?
			   previous-atts
			   new-atts))

	 ;; add brand new attributes
	 (let((brand-new(lset-difference car-string-ci=? new-atts previous-atts))
	      (changed
	       (lset-difference
		attribute=?
		(lset-intersection car-string-ci=?
				   new-atts
				   previous-atts)
		previous-atts)))
	   (ldap-modify-replace ldap dn changed)
	   (ldap-modify-add ldap dn brand-new)
	   )))))

;; Note: really need to check for USERAPPLICATIONS objectclass usage
(define (ldap-delete-recursive ld dn)
  (let*((msgid(ldap-search ld base: dn atts: '()))
	(items(ldap-answer ld msgid)))
    (for-each
     (lambda(item)
       (ldap-delete ld (car item)))
     (reverse items))
    items))

;;(let((ld(ldap-open)))(ldap-bind ld "cn=root,dc=jet,dc=msk,dc=su" "secret")(ldap-delete-recursive ld(ldap-defbase)))

(define (make-ldap-filter-clause attname attvalue::bstring #!optional match)
  ;; Note: we should process optional argument explicitly since
  ;; #f is a valid match value
  (let((match(or match "=*~a*")))
    (check-range
     (unless(member match '("=*~a*" "=~a" "=*~a" "=~a*"))
	    (error "make-ldap-filter-clause" "invalid match argument"match)))
    (format (string-append "(~a"match")")
	    attname
	    (string-grammar-apply
	     attvalue
	     (regular-grammar
	      ()
	      ((in "\*()")
	       (string #\\ (the-failure))))))))
;;(make-ldap-filter-clause 'a "&")

