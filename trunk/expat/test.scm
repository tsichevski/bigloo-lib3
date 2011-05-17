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

(loadq "test.sch")

;; Note: these tests are very incomplete!

(let(stag cdata etag eeref)
  (xml-parse
   "<!DOCTYPE DUMMY [<!ENTITY nbsp \"[nbsp]\">]><a b='c' d='qwerty'>qwerty&nbsp;</a>"
   
   stag-handler: (lambda args(set! stag args))

  cdata-handler: (lambda args(set! cdata args))

  etag-handler:  (lambda args(set! etag args))

  external-entity-ref-handler:
  (lambda args(set! eeref args))

;;  default-handler:
;;  (lambda args(print "entity: " args))
;;
;;  unparsed-entity-decl-handler:
;;  (lambda args(print "unparsed-entity-decl: " args))
  )
  (test stag '("a" (("b" . "c") ("d" . "qwerty"))) "start tag handler")
  (test cdata '("qwerty")                          "cdata tag handler")
  (test etag '("a")                                "end   tag handler")
  )

(test 
 (node-data
  (car (xml-build-node "<c><b>&amp;printf</b><a>(\"Hello, World!\");</a></c>")))
 "&printf(\"Hello, World!\");"
 "node-data")

(test 
 (print-list-delimited
  (xml-build-node
   "<!DOCTYPE office:document-content PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\"><office:document-content><office:body><table:table table:name=\"table name\"><table:table-column table:style-name='co1'/></table:table></office:body></office:document-content>"
   namespaces: '("table" "text"))"")
 "<!DOCTYPE office:document-content PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\"><table name='table name'><table-column style-name='co1'></table-column></table>"
 "xml-build-node with namespace filtering")