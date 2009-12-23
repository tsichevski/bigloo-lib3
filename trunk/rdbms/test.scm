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

(define (rdbms-test conn result)
  (define in-transaction?
    (test-execute
     (begin-transaction! conn 120)
     "begin transaction"))
  (define sess (test-execute(acquire conn)"session-acquire"))

  (try
   (begin
     (prepare sess "drop table person_")
     (execute sess))
   
   (lambda (escape proc mes obj)
     (print "table person_ wasn't dropped")
     (escape #unspecified)))

  (try
   (begin
     (test-execute
      (prepare sess
	       "
create table person_ (
  id          INTEGER PRIMARY KEY,
  last_name    VARCHAR(20),
  first_name   VARCHAR(20))")
      "session-prepare `create table' statement")
     
     (test-execute(execute sess)"session-execute")

     (when in-transaction?
	   (test-execute
	    (commit-transaction! conn)
	    "commit transaction"))

     (test-execute
      (prepare
       sess
       "insert into person_ values(100, 'Tsichevski', 'Vladimir')")
      "prepare `insert' with literal data statement")

     (test-execute (execute sess) "execute statement")
     
     (test-execute (prepare sess "insert into person_ values(:1,:2,:3)")
		   "prepare `insert' with data placeholder statement")
     (test-execute (bind! sess '(101 "Taranoff" "Alexander"))
		   "bind input data")
     (test-execute (execute sess)
		   "execute statement")
     (bind! sess '(102 "Ananin" "Vladimir"))
     (execute sess)
     
     (prepare sess "select * from person_")
     (test-execute(execute sess)
		  "execute `select' statement")
     (test-execute(describe sess)
		  "describe")
     
     (test(fetch-all! sess)
	  result
	  "value returned by `select'")
     (prepare sess "drop table person_")
     (execute sess))
   
   (lambda (escape proc mes obj)
     (print "ERROR:" proc ":" mes " -- " obj)
     (when in-transaction?
	   (print "rolling back")
	   (test-execute
	    (rollback-transaction! conn)
	    "rolling back"))))
  
  (test-execute(dismiss! sess)
	       "dismiss the session")
  (test-execute(dismiss! conn)
	       "dismiss the connection")
  )

;; Note:: log in as scott/tiger should be enabled
(cond-expand
 (oracle
  (begin
    (msg-checking "oracle backend")

    (let((connection
	  (try
	   (rdbms-connect "oracle")
	   (lambda (escape proc mes obj)
	     (print "Entire test skipped: " proc ":" mes " -- " obj)
	     (newline)
	     (escape #f)))))
      (when connection
	    (rdbms-test connection
			'((100 "Tsichevski" "Vladimir")
			  (101 "Taranoff" "Alexander")
			  (102 "Ananin" "Vladimir")))
	    ;; Additional tests: failing these tests causes a warning message only
	    
	    ;; Check if we can connect in SYSDBA mode. Prerequisites: the
	    ;; UNIX user belongs to ORACLE dba group, and the Oracle SYS has
	    ;; default password
	    (display* "checking: whether we can connect as SYSDBA ..."
		      (try
		       (begin
			 (rdbms-connect "oracle"
					username: "sys"
					password: "change_on_install"
					mode: '(sysdba))
			 "yes")
		       (lambda (escape proc mes obj)
			 (escape "no")))
		      #\newline)
	    ))))
 (else (print "Oracle support is not compiled in")))

(cond-expand
 (sqlite
  (begin
    (msg-checking "sqlite backend")
    (let((dbfile "test.db"))
      (delete-file dbfile)
      (rdbms-test(rdbms-connect "sqlite" dbfile)
		 '(("100" "Tsichevski" "Vladimir")
		   ("101" "Taranoff" "Alexander")
		   ("102" "Ananin" "Vladimir")))
      
      (delete-file dbfile)
      )))
 (else (print "SQLite support is not compiled in")))

(cond-expand
 (sqlite3
  (begin
    (msg-checking "sqlite3 backend")
    (let((dbfile "test.db"))
      (delete-file dbfile)
      (rdbms-test(rdbms-connect "sqlite3" dbfile)
		 '((100 "Tsichevski" "Vladimir")
		   (101 "Taranoff" "Alexander")
		   (102 "Ananin" "Vladimir")))
      
      (delete-file dbfile)
      )))
 (else (print "Sqlite3 support is not compiled in")))

(cond-expand
 (pgsql
  (begin
    (msg-checking "PostgreSQL backend")

    (let((connection
	  (try
	   (rdbms-connect "pgsql")
	   (lambda (escape proc mes obj)
	     (print "Entire test skipped: " proc ":" mes " -- " obj)
	     (newline)
	     (escape #f)))))
      (and connection
	   (rdbms-test connection
		       '((100 "Tsichevski" "Vladimir")
			 (101 "Taranoff" "Alexander")
			 (102 "Ananin" "Vladimir")))
	   ))))
 (else (print "PostgreSQL support is not compiled in")))

(cond-expand
 (mysql
  (begin
    (msg-checking "mysql backend")

    (let((connection
	  (try
	   (rdbms-connect "mysql" dbname: "test")
	   (lambda (escape proc mes obj)
	     (print "Entire test skipped: " proc ":" mes " -- " obj)
	     (newline)
	     (escape #f)))))
      (and connection
	   (rdbms-test connection
		       '((100 "Tsichevski" "Vladimir")
			 (101 "Taranoff" "Alexander")
			 (102 "Ananin" "Vladimir")))
	   ))))
 (else (print "MySQL support is not compiled in")))




