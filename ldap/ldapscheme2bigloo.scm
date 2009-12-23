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
 ldapscheme2bigloo
 (library
  common
  node
  bldap
  )
 (include "common.sch")
 (main main)
 )

(define *in* #f)
(define *out* #f)
(define *include-path* '())

(define(main argv)
  (args-parse
   (cdr argv)
   (("-o" ?name (synopsis "The name of the output file (default stdout)"))
    (set! *out* name))
   
   (("-I" ?filename (synopsis "Add item to include file search path (default current directory)"))
    (push! *include-path* filename))
   
   (("-h"(synopsis "Print usage info"))
    (args-parse-usage #f)
    (exit 0))

   (("--help" (synopsis "Print usage info"))
    (args-parse-usage #f)
    (exit 0))

   (else
    ;; other args treated as input files
    (if *in*
	(set! *out* else)
	(set! *in* else))
    ))
  
  (unless *in*
	  (print "no input file name given")
	  (exit 1))
  (unless *out*
	  (print "no output file name given")
	  (exit 1))
  (unless (file-exists? *in*)
	  (error "ldapscheme2bigloo" "cannot open input file" *in*))
  (let((tree(with-input-from-file
		*in*
	      (lambda()
		(ldap-schema-read-subschema
		 include-path:
		 (and(pair? *include-path*) (reverse *include-path*))
		 ))))
       (op(open-output-binary-file *out*)))
    (unless (binary-port? op)
	    (error "open-input-binary-file" "cannot open" *out*))
    (output-obj op tree)
    (close-binary-port op)))

