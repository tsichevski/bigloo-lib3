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
 rdbms
 (library common)
 (include "common.sch")
 (export (class rdbms-object)
	 (generic _dismiss! ::rdbms-object)
	 (dismiss! ::rdbms-object)
	 (generic error-string::string ::rdbms-object)

	 (class connection::rdbms-object
		(sessions::pair-nil (default '())))
	 (class session::rdbms-object
		connection::connection
		(statement (default #f)))

	 ;; FIXME: all arguments should be optional
	 ;;(generic connect ::connection environment username password . options)

	 (generic begin-transaction!::bool ::connection . timeout)
	 (generic commit-transaction! ::connection)
	 (generic rollback-transaction! ::connection)
	 (acquire::session ::connection)
	 (generic _acquire::session ::connection)
	 (generic cancel! ::session)
	 (generic has-answer?::bool ::session)
	 (generic execute::bool ::session)
	 (generic prepare::bool ::session sql::bstring)
	 (generic bind! ::session bindings::pair-nil)
	 (generic fetch!::pair-nil ::session)
	 (generic describe::pair-nil ::session)
	 (generic fetch-all!::pair-nil ::session)

	 (rdbms-register! vendortag::bstring connect::procedure)
	 (rdbms-connect vendortag::bstring . args)

	 ;; Get list of driver names
	 (rdbms-drivers)

	 (string->dbstring::bstring s::bstring)
	 (rdbms-format::bstring statement::bstring bindings::pair-nil)
	 ))

(define (unimplemented-method-error name::bstring o)
  (error name "abstract method called" o))

(define-generic (_dismiss! self::rdbms-object)
  (unimplemented-method-error "dismiss!"self))

(define (dismiss! self::rdbms-object)
  (when (connection? self)
	(with-access::connection
	 self (sessions)
	 (for-each dismiss! sessions)))
  (_dismiss! self))

(define-generic (error-string::string self::rdbms-object)
  (unimplemented-method-error "error-string" self))

(define-generic (begin-transaction!::bool self::connection . timeout)
  (unimplemented-method-error "begin-transaction!"self))

(define-generic (commit-transaction! self::connection)
  (unimplemented-method-error "commit-transaction!"self))

(define-generic (rollback-transaction! self::connection)
  (unimplemented-method-error "rollback-transaction!"self))

(define (acquire::session self::connection)
  (with-access::connection
   self
   (sessions)
   (let((sess(_acquire self)))
     (push! sessions sess)
     sess)))

;; This is where the `acquire' is really implemented
(define-generic (_acquire::session self::connection)
  (unimplemented-method-error "acquire" self))

(define-generic (cancel! self::session)
  (unimplemented-method-error "cancel!" self))

(define-generic (has-answer?::bool self::session)
  (unimplemented-method-error "has-answer?" self))

(define-generic (execute::bool self::session)
  (unimplemented-method-error "execute" self))

(define-generic (prepare::bool self::session sql::bstring)
  (session-statement-set! self sql))

(define-generic (bind! self::session bindings::pair-nil)
  (unimplemented-method-error "bind!" self))

(define-generic (fetch!::pair-nil self::session)
  (unimplemented-method-error "fetch!" self))

(define-generic (describe::pair-nil self::session)
  (unimplemented-method-error "fetch!" self))

(define-generic (fetch-all!::pair-nil self::session)
  (let loop((accu '()))
    (let((value(fetch! self)))
      (if(pair? value)
	 (loop(cons value accu))
	 (reverse accu)))))

(define *rdbms-registry* (make-hashtable))

(define (rdbms-drivers)
  (let((result '()))
    (hashtable-for-each
     *rdbms-registry*
     (lambda(k v)(push! result k))
     )
    result))

(define (rdbms-register! vendortag::bstring connect::procedure)
  (hashtable-put! *rdbms-registry* vendortag connect))

(define (rdbms-connect vendortag::bstring . args)
  (let((handler (hashtable-get *rdbms-registry* vendortag)))
     (if handler
	 (apply handler args)
	 (error "rdbms-connect" "no driver found"vendortag))))

;; Miscellanious utilities

(define (string->dbstring::bstring s::bstring)
  (let*((is(open-input-string s))
	(os(open-output-string)))
    (let loop()
      (let((ch(read-char is)))
	(if(eof-object? ch)
	   (get-output-string os)
	   (begin
	     (case ch
	       ((#\" #\' #\\)
		(write-char #\\ os)
		(write-char ch os))
	       ((#a000)
		(write-char #\\ os)
		(write-char #\0 os))
	       (else
		(write-char ch os)))
	     (loop)))))))

;;; Print parameter values into an SQL statement. Used to simulate
;;; parameter binding on systems like MySQL and SQLite that do not
;;; support it.

(define (rdbms-format statement bindings)
  (string-grammar-apply
   statement
   (lambda(port)
     (read/rp
      (regular-grammar
       ()
       ((: #\: (submatch(+ digit)))
	(let((bind-no(string->integer(the-submatch 1))))
	  (check-range
	   (when(>fx bind-no(length bindings))
		(error "bind!" "bind position out of range"bind-no)))
	  (let((arg(list-ref bindings(-fx bind-no 1))))
	    (cond
	     ((eq? arg #unspecified) "NULL")

	     ((tm? arg)
	      (strftime arg "%Y%m%d%H%M%S"))

	     ((or (string? arg)
		  (symbol? arg))
	      (format "'~a'" (string->dbstring arg)))

	     ((llong? arg)
	      (llong->string arg))

	     ((elong? arg)
	      (elong->string arg))

	     (else arg))))))
      port))))
