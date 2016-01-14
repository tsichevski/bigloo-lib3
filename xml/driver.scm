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
 xml
 (library common xml)
 (include "common.sch")
 (main main)
 (eval (export-all))
 )

*common-version*
*xml-version*

(define *output-encoding* #f) ;; #f means "same as the document encoding"
(define *indent-output* #f)

(define *source-file* #f)
(define *output-file* #f)

(define *xsl-style* #f)
(define *xslt-parameters* '())

(define *read-options* '())

(define (find-file filename)
  (let((source (find-file/path filename *load-path*)))
    
    (unless source
	    (print "Cannot find: " filename
		   " in " (print-list-delimited *load-path* ":") "\n")
	    (exit 1))
    source))

(define (output-doc output::xml-doc)
  (if *output-file*
      (xml-doc-save output
		    *output-file*
		    encoding: *output-encoding*
		    indent: *indent-output*)
      (let((buf (xml-buffer-create)))
	(xml-node-dump buf output 0)
	(display (xml-buffer-content buf)))
      ))

(define (locate-file::bstring filename::bstring #!optional search-path)
  (let ((path
	 (find-file/path
	  filename
	  (or search-path
	      (if (pair? *load-path*)
		  *load-path*
		  '("."))))))
    
    (unless path
	    (error "bigloo-xml"
		   (format "Cannot find: ~a in " filename)
		   (print-list-delimited *load-path* ":")))
    path))

(define (main argv)
  (xml-substitute-entities-default-value #t)

  (args-parse
   (cdr argv)
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (section "Help")
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (("--version"
     (help "Print version info and exit"))
    (print *xml-version*)
    (exit 0))
   
   ((("-h" "--help")
     (help "Print this help message and exit"))
    (print "
Usage:
  bigloo-xml [options] [file] [file ...]
")
    (args-parse-usage #f)
    (exit 0))
   
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (section "Options")
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ((("--indent")
     (synopsis "Indent output XML"))
    (set! *indent-output* #t))
   
   ((("-I" "--include")
     ?path
     (synopsis "Add to file search path"))
    (set! *load-path*
	  (append! *load-path* (list path))))
   
   ((("-s" "--style")
     ?xsl
     (synopsis "Set XSLT stylesheet"))
    (set! *xsl-style*
	  (xslt-parse-stylesheet-file (locate-file xsl))))

   ((("--output-encoding")
     ?name
     (synopsis "Set output files encoding: (default same as input)"))
    (set! *output-encoding* name))
   
   ((("-o" "--output")
     ?path
     (synopsis "Set output filename (default stdout)"))
    (set! *output-file* path))
   
   ((("--read-options")
     ?options
     (synopsis "Set XML read options"))
    (set! *read-options* (scheme-read-string options)))

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (section "Commands")
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ((("-r" "--repl")
     (synopsis "Run read-eval-print loop and exit"))
    (exit (repl)))
   
   ((("-l" "--load")
     ?scheme-file
     (synopsis "Load and Eval scheme file"))
    (loadq (find-file scheme-file)))
   
   ((("-q" "--quit")
     (synopsis "Exit program"))
    (exit))
   
   ((("-v" "--verbose")
     (synopsis "Be one level more verbose"))
    (set! *trace-level* (+fx *trace-level* 1)))
   
   (else
    (match-case
     (pregexp-match "([^=]+)=(.*)" else)
     ((?- ?name ?value)
      [trace 1 "XSL parameter: " name " => " value]
      (push! *xslt-parameters* (cons name value)))
     (else
      (let((input (xml-read-file (find-file else) options: *read-options*)))
        (output-doc
         (if *xsl-style*
             (xslt-apply-stylesheet
              *xsl-style*
              input
              *xslt-parameters*)
             input)))))))
  0)
