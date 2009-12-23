; -*-Scheme-*-

;************************************************************************/
;*                                                                      */
;*                                                                      */
;* Copyright (c) 1992-1999 Manuel Serrano                               */
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

(module afile (main main))

;*---------------------------------------------------------------------*/
;*    Global variables                                                 */
;*---------------------------------------------------------------------*/
(define *verbose*    #f)
(define *suffixes*   '("scm" "sch" "bgl"))
(define *gui-suffix* "bld")
(define *search-path* '())

;*---------------------------------------------------------------------*/
;*    main ...                                                         */
;*---------------------------------------------------------------------*/
(define (main argv)
  (if (or (null?    (cdr argv))
	  (string=? (cadr argv) "-help"))
      (usage)
      (let loop ((files        (cdr argv))
		 (access-list '())
		 (output-file '()))
	(cond
	 ((null? files)
	  (output access-list output-file))
	 ((string=? (car files) "-v")
	  (set! *verbose* #t)
	  (loop (cdr files) 
		access-list
		output-file))
	 ((string=? (car files) "-o")
	  (if (null? (cdr files))
	      (usage)
	      (loop (cddr files)
		    access-list
		    (cadr files))))
	 ((string=? (car files) "-I")
	  (if (null? (cdr files))
	      (usage)
	      (begin
		(set! *search-path* (cons (cadr files) *search-path*))
		(loop (cddr files)
		      access-list
		      output-file))))
	 ((string=? (car files) "-suffix")
	  (if (null? (cdr files))
	      (usage)
	      (begin
		(set! *suffixes* (cons (cadr files) *suffixes*))
		(loop (cddr files)
		      access-list
		      output-file))))
	 ((string=? (car files) "-gui-suffix")
	  (set! *gui-suffix* (cadr files))
	  (loop (cddr files)
		access-list
		output-file))
	 (else
	  (loop (cdr files)
		(cons (car files) access-list)
		output-file))))))

;*---------------------------------------------------------------------*/
;*    my-open-input-file ...                                           */
;*---------------------------------------------------------------------*/
(define (my-open-input-file file-name)
   (if *verbose*
       (print file-name ":"))
   (open-input-file file-name))
 
;*---------------------------------------------------------------------*/
;*    output ...                                                       */
;*---------------------------------------------------------------------*/
(define (output access-list output-file)
  (let loop ((access-list access-list)
	     (declarations '()))
    (if (null? access-list)
	;; start any writing only after all modules successfully processed
	(if (and (string? output-file)
		 (file-exists? output-file)
		 (equal? (with-input-from-file output-file read)
			 declarations))
	    ;; if the new and old files do not differ, do nothing
	    (when *verbose*
		  (print "file "output-file " unchanged"))
	    
	    ;; do real write
	    (if (string? output-file)
		(with-output-to-file
		    output-file
		  (lambda() (pp declarations)))
		(pp declarations)))
	
	(let*((path (car access-list))
	      (suf (suffix path)))
	  (loop (cdr access-list)
		(cons
		 (cond
		  ((member suf *suffixes*)
		   (find-module-name path))
		  ((string=? suf *gui-suffix*)
		   (find-module-name path #t))
		  (else
		   (error "afile"
			  "invalid suffix given, must be one of"
			  (cons *gui-suffix* *suffixes*))))
		 declarations))))))

	  
;*---------------------------------------------------------------------*/
;*    find-module-name ...                                             */
;*---------------------------------------------------------------------*/
(define (find-module-name file #!optional gui?)
  (let((path(find-file/path
	     file
	     (if(null? *search-path*)
		'(".")
		(reverse *search-path*)))))
    (unless path
	    (error "afile" "Can't find file" file))
    (let ((port
	   (begin
	     (when *verbose*(print path ":"))
	     (open-input-file path))))
      (unless (input-port? port)
	      (error "afile" "Can't open file" file))
      (let ((exp (read port)))
	 (if gui?
	     (list exp(string-append (prefix path)".scm"))
	     (list
	      (match-case exp
			  ((module ?module-name . ?-)
			   (close-input-port port)
			   module-name)
			  (else
			   (error "afile" "Illegal file format" path)))
	      path))))))
;*---------------------------------------------------------------------*/
;*    usage ...                                                        */
;*---------------------------------------------------------------------*/
(define (usage)
   (print "usage: afile [-help] [-v] [-I catalog] [-o output] [-suffix suf] [-gui-suffix suf] file ...")
   (exit -1))
