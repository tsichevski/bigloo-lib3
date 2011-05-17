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
 xml2bigloo
 (library
  common
  node
  bexpat
  )
 (main main)
 )

(define *in-encoding* #f)
(define *out-encoding* #f)
(define *in* #f)
(define *out* #f)

(define(main argv)
  (args-parse
   (cdr argv)
   (("-o" ?name (synopsis "The name of the output file (default stdout)"))
    (set! *out* name))
   
   (("-s" ?name (synopsis "The name of the input encoding (default UTF-8)"))
    (set! *in-encoding* name))
   (("-t" ?name (synopsis "The name of the output encoding (default input-encoding)"))
    (set! *out-encoding* name))
   (("-h"(synopsis "Print usage info"))
    (print "Usage: xml2bigloo [options] inputfile outputfile")
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
  
  (unless *out*
	  (print "no output file name given")
	  (exit 1))

  (unless *in-encoding*
	  (set! *in-encoding* "UTF-8"))

  (unless *out-encoding*
	  (set! *out-encoding* *in-encoding*))

  (let((tree
	(xml-build-node
	 (file-contents *in*)

	 encode:
	 (if (string=? *in-encoding* "UTF-8")
	     values
	     (make-iconv-encoder *in-encoding* "UTF-8"))

	 decode:
	 (if (string=? *out-encoding* "UTF-8")
	     values
	     (make-iconv-encoder  "UTF-8" *out-encoding*))))
       
       (op(open-output-binary-file *out*)))
    (unless (binary-port? op)
	    (error "open-input-binary-file" "cannot open" *out*))
    (output-obj op tree)
    (close-binary-port op)))