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
 html-node
 (use node dl-node)
 (import sgml-node tree-node)
 (library common)
 (export
  (process-form!::pair-nil formelts::pair-nil #!key action enctype atts)
  (html-escape-string::bstring s::bstring)
  )
 )

(define(html-escape-string s::bstring)
  (string-grammar-apply
   s
   (lambda(port)
     (read/rp
      (regular-grammar
       ()
       ;;("&#" "&#")
       ("&" "&amp;")
       ("<" "&lt;")
       (">" "&gt;"))
      port))))
;;(html-escape-string "a&<s>&#34;d")

;*-------------------------------------------------------------------*;
;*  Process HTML form elements using (current-http-query)            *;
;*-------------------------------------------------------------------*;
(define (process-form! node-list::pair-nil #!key action enctype atts)
  (let loop((node-list node-list))
    (for-each
     (lambda(elt)
       (case (string->symbol (sgml-element-gi elt))
	 ((form)
	  (when action
		(node-set-attribute! elt "action" action))
	  (when enctype
		(node-set-attribute! elt "enctype" enctype))
	  )
	 
	 ((input select textarea)
	  (when atts
		(node-remove-attribute! elt "checked")
		(let*((name(node-attribute-first elt "name"))
		      (type(node-attribute-first elt "type"))
		      (value (and name (alist-lookup atts name))))
		  ;;(trace name type value)
		  (if value
		      (case (string->symbol(sgml-element-gi elt))
			((input)
			 ;;(trace "input: " elt)
			 (if(eq? type "checkbox")
			    (node-set-attribute! elt "checked" "checked")
			    (node-set-attribute! elt "value" value)))
			
			((select)
			 (for-each
			  (lambda(option)
			    (let((opvalue(or(node-attribute-first option value)
					    (node-data option))))
			      (node-set-attribute! option "value" opvalue)
			      (when(string=? opvalue value)
				   (node-set-attribute! option "value" "yes"))))
			  (filter sgml-element?(sgml-element-children elt))))
			
			((textarea)
			 (sgml-element-children-set!
			  elt
			  (list(make-sgml-char(list elt)value))))))))))
       (loop(sgml-element-children elt)))
     (filter sgml-element? node-list)))
  node-list)
