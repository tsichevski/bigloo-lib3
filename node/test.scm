#!./driver
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

(loadq (find-file/path "test.sch" '(".." "../..")))

(letrec((elt (make-sgml-element
	      '()                 ;; parents
	      "html"               ;; gi
	      '(("a" . "b"))        ;; attributes
	      (list               ;; children
	       (make-sgml-entity (list elt) "quot")
	       )
	      ))
	(elt1 (make-sgml-element '() "html" '(("a" . "b'c")) '() ))
	(elt2 (make-sgml-element '() "html" '(("a" . "b\"c")) '() ))
	)
  (test (proc-output display elt) "<html a='b'>&quot;</html>" "sgml output")
  (test (proc-output display elt1) "<html a=\"b'c\"></html>"
	"sgml output single-quote in attribute value")
  (test (proc-output display elt2) "<html a='b\"c'></html>"
	"sgml output double-quote in attribute value")
  (test 
   (node-data elt)
   "\""
   "node-data")
  )

