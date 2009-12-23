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

;; MzScheme misc compatibility module
(module
 mzcompat
 (option (loadq "common.init"))
 (import
  string-lib
  misc
  os ;; for string* definition
  )
 (export
  (case-lambda-proc patterns)
  (inline load-relative-extension fname::bstring)
  (make-parameter value #!optional)
  (inline directory-exists? path::bstring)
  (make-directory path::bstring #!optional)
;;  read-string::procedure
  current-directory::procedure
  (build-path dir::bstring . chunks)
  )

 (extern
  (include "sys/stat.h")
  ))

(register-eval-srfi! 'mzscheme-compat)

(define(case-lambda-proc patterns)
  (define(make-cond lst)
    (let loop((l 0)(lst lst))
      (cond((pair? lst)
	    (loop(+fx l 1)(cdr lst)))
	   ((null? lst)
	    `(=fx nargs ,l))
	   (else
	    `(>=fx nargs ,l)))))
  `(lambda args
     (let*((nargs(length args))
	   (proc
	    (cond
	     ,@(map
		(lambda(pattern)
		  (list
		   (make-cond(car pattern))
		   `(lambda ,(car pattern)
		      ,@(cdr pattern))))
		patterns)
	     (else(error "case-lambda" "no pattern for n of args:" nargs)))))
       (apply proc args))))

(define-inline(load-relative-extension fname::bstring)
  #t)

(define(make-parameter value #!optional (filter::procedure values))
  (case-lambda
   (()
    value)
   ((newvalue)
    (set! value(filter newvalue)))))

;*-------------------------------------------------------------------*;
;*  Filename & directory utils                                       *;
;*-------------------------------------------------------------------*;
(define-inline(directory-exists? path::bstring)
  (directory? path))

(define (make-directory path::bstring #!optional (mask::int #o0777))
  (mkdir path mask))

;*-------------------------------------------------------------------*;
;*  reading & writing                                                *;
;*-------------------------------------------------------------------*;
; This procedure is already defined in bigloo since 2.5c
;(define read-string
;  (case-lambda
;   (()(read-string -1(current-input-port)))
;   ((count::int)(read-string count(current-input-port)))
;   ((count::int port::input-port)
;    (do((os(open-output-string))
;	(count count(-fx count 1)))
;	((or(zero? count)(eof-object?(peek-char port)))
;	 (get-output-string os))
;      (write-char(read-char port)os)))))

(define (current-directory #!optional newdir)
  (if(string? newdir)
     (unless(zero?(chdir newdir))
	    (error "current-directory" "cannot change to" newdir))
     (pwd)))

(define(build-path dir . chunks)
  (define(split-path dir)
    (let loop((dir dir)(dir-chunks '()))
      (let((ndir(dirname dir))
	   (nchunks(cons(basename dir)dir-chunks)))
	(if(string=? dir ndir)
	   (if(string=? dir ".")
	      (cdr nchunks)
	      nchunks)
	   (loop ndir nchunks)))))
  ;; check for errors
  (for-each
   (lambda(s)
     (cond((string-null? s)
	   (error "build-path" "path chunk should not be empty" s))
	  ((eq?(string-ref s 0) #\/)
	   (error "build-path" "absolute paths should not be appended: " s))))
   chunks)

  (print-list-delimited(map-append split-path(cons dir chunks)) "/"))
;;(build-path "/a/b/c" "d/e/f" "y")
