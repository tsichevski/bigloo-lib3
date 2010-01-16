;; -*-scheme-*-
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

(define-macro (make-gd-image-reader format)
  (let*((procedure-name (string-append "gd-image-create-from-"  (string-downcase format)))
	(procedure-c-name (string-append "gdImageCreateFrom" format)))
    `(define(,(symbol-append (read (open-input-string procedure-name)) '::gd-image) #!optional fn)
       (let((fp::file
	     (cond
	      ((string? fn)
	       (let((fn::string fn))
		 (pragma::file "fopen($1, \"rb\")" fn)))
	      ((binary-port? fn)
	       ($binary-port->file fn))	 
	      ((not fn)
	       (pragma::file "stdin"))
	      (else
	       (error ,procedure-name "invalid argument"fn)))))
	 
	 (when (pragma::bool "$1 == NULL" fp)
	       (error ,procedure-name "cannot open for read"fn))
	 
	 (let((im(pragma::gd-image ,(string-append procedure-c-name "($1)")fp)))
	   (unless im
		   (error ,procedure-name "file format problem" fn))
	   (when(string? fn)
		(pragma "fclose($1)" fp))
	   im)))))
;;(pp (expand-once '(make-gd-image-reader "Gif")))

(define-macro (make-gd-image-writer format)
  (let*((procedure-name(string-append "gd-image-write-" (string-downcase format)))
	(procedure-c-name(string-append "gdImage" format)))
  `(define(,(read (open-input-string procedure-name)) im::gd-image #!optional fn)
     (let((fp::file
	   (cond
	    ((string? fn)
	     (let((fn::string fn))
	       (pragma::file "fopen($1, \"wb\")" fn)))
	    ((binary-port? fn)
	     ($binary-port->file fn))	 
	    ((not fn)
	     (pragma::file "stdout"))
	    (else
	     (error ,procedure-name "invalid argument"fn)))))
       
       (when (pragma::bool "$1 == NULL" fp)
	     (error ,procedure-name "cannot open for write"fn))
       
       (pragma ,(string-append procedure-c-name "($1, $2)")im fp)
       (when(string? fn)
	    (pragma "fclose($1)" fp))
       #unspecified))))
;;(pp(expand-once '(make-gd-image-writer "Gif")))

(define-macro (make-gd-image-reader/writer format)
  `(begin
     (make-gd-image-reader ,format)
     (make-gd-image-writer ,format)))

;;(pp (expand '(make-gd-image-reader/writer "Gif")))
