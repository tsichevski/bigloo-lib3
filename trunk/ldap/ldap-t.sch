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
(directives
  (type (subtype ldap #"LDAP*" (cobj))
        (coerce cobj ldap () (cobj->ldap))
        (coerce ldap cobj () (ldap->cobj))
        (coerce
          ldap
          bool
          ()
          ((lambda (x::ldap) (pragma::bool #"$1 != NULL" x)))))
  (foreign
    (macro ldap cobj->ldap (cobj) #"(LDAP*)")
    (macro ldap ldap->cobj (cobj) #"(long)"))
  (type (subtype bldap #"obj_t" (obj))
        (coerce obj bldap (ldap?) ())
        (coerce bldap obj () ())
        (coerce
          bldap
          bool
          ()
          ((lambda (x::bldap)
             (pragma::bool #"$1 != NULL" x)))))
  (type (coerce
          bldap
          ldap
          (ldap?)
          ((lambda (x)
             (pragma::ldap #"(LDAP*)FOREIGN_TO_COBJ($1)" x))))
        (coerce
          ldap
          bldap
          ()
          ((lambda (x)
             (pragma::bldap
               #"cobj_to_foreign($1, $2)"
               'ldap
               x)))))
  (type (subtype ldap-message #"LDAPMessage*" (cobj))
        (coerce
          cobj
          ldap-message
          ()
          (cobj->ldap-message))
        (coerce
          ldap-message
          cobj
          ()
          (ldap-message->cobj))
        (coerce
          ldap-message
          bool
          ()
          ((lambda (x::ldap-message)
             (pragma::bool #"$1 != NULL" x)))))
  (foreign
    (macro ldap-message
           cobj->ldap-message
           (cobj)
           #"(LDAPMessage*)")
    (macro ldap-message
           ldap-message->cobj
           (cobj)
           #"(long)"))
  (type (subtype bldap-message #"obj_t" (obj))
        (coerce obj bldap-message (ldap-message?) ())
        (coerce bldap-message obj () ())
        (coerce
          bldap-message
          bool
          ()
          ((lambda (x::bldap-message)
             (pragma::bool #"$1 != NULL" x)))))
  (type (coerce
          bldap-message
          ldap-message
          (ldap-message?)
          ((lambda (x)
             (pragma::ldap-message
               #"(LDAPMessage*)FOREIGN_TO_COBJ($1)"
               x))))
        (coerce
          ldap-message
          bldap-message
          ()
          ((lambda (x)
             (pragma::bldap-message
               #"cobj_to_foreign($1, $2)"
               'ldap-message
               x)))))
  (type (subtype ber-element #"BerElement*" (cobj))
        (coerce cobj ber-element () (cobj->ber-element))
        (coerce ber-element cobj () (ber-element->cobj))
        (coerce
          ber-element
          bool
          ()
          ((lambda (x::ber-element)
             (pragma::bool #"$1 != NULL" x)))))
  (foreign
    (macro ber-element
           cobj->ber-element
           (cobj)
           #"(BerElement*)")
    (macro ber-element
           ber-element->cobj
           (cobj)
           #"(long)"))
  (type (subtype bber-element #"obj_t" (obj))
        (coerce obj bber-element (ber-element?) ())
        (coerce bber-element obj () ())
        (coerce
          bber-element
          bool
          ()
          ((lambda (x::bber-element)
             (pragma::bool #"$1 != NULL" x)))))
  (type (coerce
          bber-element
          ber-element
          (ber-element?)
          ((lambda (x)
             (pragma::ber-element
               #"(BerElement*)FOREIGN_TO_COBJ($1)"
               x))))
        (coerce
          ber-element
          bber-element
          ()
          ((lambda (x)
             (pragma::bber-element
               #"cobj_to_foreign($1, $2)"
               'ber-element
               x)))))
  (export (ldap?::bool ::obj))
  (export (ldap-message?::bool ::obj))
  (export (ber-element?::bool ::obj)))
(define (ldap? x)
  (and (foreign? x) (eq? (foreign-id x) 'ldap)))

(define (ldap-message? x)
  (and (foreign? x)
       (eq? (foreign-id x) 'ldap-message)))

(define (ber-element? x)
  (and (foreign? x)
       (eq? (foreign-id x) 'ber-element)))

