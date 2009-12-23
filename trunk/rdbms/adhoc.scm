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
 test
 (library bgtk common rdbms)
 (main main)
 )

*common-version*
*rdbms-version*
*bgtk-version*
       
(define-parameter current-driver)
(define-parameter current-username)
(define-parameter current-password)
(define-parameter current-dbname)
(define-parameter current-hostname)
(define-parameter current-statement)
(define-parameter max-rows)

(define *conn* #f)
(define *sess* #f)

(define (disconnect)
  (when *conn*
	(dismiss! *conn*)
	(set! *conn* #f)
	(set! *sess* #f)))

(define (connect)
  (disconnect)
  (when (string?(current-driver))
	(rdbms-try
	 (lambda()
	   (unless(member (current-driver)(rdbms-drivers))
		  (error "adhoc"
			 (format "invalid driver name, must be on of ~a"
				 (rdbms-drivers))
			 (current-driver)))

	   (let((connect-params '()))
	     (when(and(current-username)
		      (not(string-null? (current-username))))
		  (set! connect-params
			(cons* username: (current-username)
			       password: (current-password)
			       connect-params)))
	     (when(and(current-hostname)
		      (not(string-null? (current-hostname))))
		  (set! connect-params
			(cons* hostname: (current-hostname)
			       connect-params)))
	     (when(and(current-dbname)(not(string-null? (current-dbname))))
		  (set! connect-params
			(cons* dbname: (current-dbname)
			       connect-params)))
	     
	     ;;[trace connect-params]
	     (set! *conn* (apply rdbms-connect
				 (cons (current-driver) connect-params)))
	     (signal 2
		     (lambda(signo)
		       (rollback-transaction! *conn*)
		       (dismiss! *conn*)
		       (exit -1)))
	     )

	   (set! *sess*(acquire *conn*))))))
  
(define tooltips(delay(gtk-tooltips-new)))

(define(build-option-menu model::procedure items::pair)
  (let((omenu(gtk-option-menu-new))
       (menu(gtk-menu-new))
       (selected? #f))
    ;; Prepend dummy "Not-selected" item
    (let((menu-item(gtk-menu-item-new "---")))
      (gtk-menu-shell-append menu menu-item)
      (gtk-widget-show menu-item))

    (let loop ((items items)
	       (counter 1))
      (when(pair? items)
	   (let*((item(car items))
		 (label(if(pair? item)(car item)item))
		 (value(if(pair? item)(cdr item)item))
		 (menu-item(gtk-menu-item-new label)))
	     (when(equal? (model)value)
		  (trace "select: "value)
		  (gtk-option-menu-set-history omenu counter))
	     (gtk-signal-connect
	      menu-item "activate" (lambda args(model value)))
	     (gtk-menu-shell-append menu menu-item)
	     (gtk-widget-show menu-item)
	     (loop(cdr items)(+fx 1 counter)))))
    (gtk-option-menu-set-menu omenu menu)
    omenu))

(define (connect-dialog window::gtk-window trigger::procedure)
  (define table
    (gtk-object-new
     (gtk-table-get-type)
     border_width: 10
     ))

  (define(add-labeled-entry model::procedure
			    labeltext::bstring
			    #!key
			    tip
			    options
			    visible
			    )
    (let((i(gtk-table-nrows table)))
      (let((label(gtk-object-new
		  (gtk-label-get-type)
		  label: labeltext
		  xalign: 1.0
		  xpad: 5)))
	(gtk-table-attach-defaults
	 table
	 (if tip
	     (let((ebox(gtk-event-box-new)))
	       (gtk-container-add ebox label)
	       (gtk-tooltips-set-tip (tooltips) ebox tip)
	       ebox)
	     label)
	 0 1 i (+fx 1 i)))

      (let((entry
	    (if options
		(build-option-menu model options)
		(let((entry(gtk-entry-new)))
		  (when(string? (model))
		       (gtk-entry-set-text entry (model)))
		  (gtk-entry-set-visibility entry(not visible))
		  (gtk-signal-connect
		   entry
		   "changed"
		   (lambda args
		     (model(gtk-editable-get-chars entry))
		     ))
		  entry))))	
	(gtk-table-attach-defaults table entry 1 2 i (+fx 1 i))
	entry)))
  
  (add-labeled-entry current-driver
		     "Driver:"
		     options: (rdbms-drivers)
		     tip: "Connection type")
  (add-labeled-entry current-username "Username:"
		     tip: "Name of the user")
  (add-labeled-entry current-password "Password:"
		     visible: #f)

  (add-labeled-entry current-dbname "Dbname:")
  (add-labeled-entry current-hostname "Hostname:")
  
  (let((dialog (gtk-dialog-new)))
    (gtk-window-set-modal dialog #t)
    (gtk-window-set-transient-for dialog window)    
    (gtk-box-pack-start (gtk-dialog-vbox dialog)table #t #t 0)
    (gtk-window-set-title dialog (_"Connect to database"))

    (let((button (gtk-button-new (_"OK"))))
      (gtk-signal-connect 
       button "clicked" 
       (lambda args
	 (trigger)
	 (gtk-widget-destroy dialog)
	 (gtk-main-quit)
	 ))
      (gtk-widget-set-flags button '(can-default))
      (gtk-box-pack-start (gtk-dialog-action-area dialog)
			  button #t #t 0)
      (gtk-widget-grab-default button))
    
    (let((button (gtk-button-new (_"Cancel"))))
      (gtk-signal-connect 
       button "clicked" 
       (lambda args (gtk-widget-destroy dialog)))
      (gtk-box-pack-start (gtk-dialog-action-area dialog)
			  button #t #t 0))
    (gtk-widget-show-all dialog)
    (gtk-main)))

(define(rdbms-try proc::procedure)
  (try 
   (proc)
   (lambda (escape proc mes obj)
     (print "***ERROR:" proc ":" mes
	    ;;" -- " obj
	    )
     (escape #f))))

(define(do-sql stmt) ;; => result list or #f
  (rdbms-try
   (lambda()
     (prepare *sess* stmt)
     (and(execute *sess*)
	 (let loop((accu '())
		   (count 0))

	   (define(result more-results?)
	     (cons*
	      (describe *sess*)
	      more-results?
	      (reverse accu)))

	   (if (and(max-rows)(>=fx count (max-rows)))
	       (result #t)
	       (let((value(fetch! *sess*)))
		 (if(pair? value)
		    (loop(cons value accu)
			 (+fx count 1))
		    (result #f)))))))))

(define(gui-mode)
  (let((window(gtk-window-new))
       (mainbox(gtk-vbox-new))
       
       (sql(gtk-object-new(gtk-text-get-type)
			  editable: #t
			  height: 30))
       (scrolled-win (gtk-scrolled-window-new))
       (clist #f)
       (execute(gtk-button-new (_"Execute")))
       (next(gtk-button-new (_">")))
       (prev(gtk-button-new (_"<")))
       (all(gtk-button-new (_"All")))
       (status(gtk-label-new "status line"))
       )
    (when(current-statement)
	 (gtk-text-insert sql (current-statement)))
    (gtk-widget-set-usize scrolled-win 0 0)
    (gtk-window-set-title window(basename(car (command-line))))
    (gtk-signal-connect window "delete_event"(lambda args #f))
    (gtk-signal-connect window "destroy"(lambda args(gtk-main-quit)))
    (gtk-widget-realize window)
    
    (gtk-container-add window mainbox)
    
    ;; Menu
    (let*((accel-group(gtk-accel-group-new))
	  (item-factory(gtk-item-factory-new(gtk-menu-bar-get-type)
					    "<main>"
					    accel-group)))
      (gtk-accel-group-attach accel-group window)
      (when *conn*
	    (gtk-label-set-text status "Connected")
	    (gtk-widget-set-sensitive execute #t))
      (for-each
       (lambda (record)
	 (apply gtk-item-factory-create-item
		(cons item-factory record)))
       `(("/_File" type: "<Branch>")
	 ("/File/tearoff1"type: "<Tearoff>" )
	 ("/File/_Connect"
	  accelerator: "<control>C"
	  callback: ,(lambda args
		       (connect-dialog
			window
			(lambda()
			  (connect)
			  (when *conn*
				(gtk-label-set-text status "Connected")
				(gtk-widget-set-sensitive execute #t))
			  ))
		       ))
	 ("/File/sep1"type: "<Separator>")
	 ("/File/_Quit"
	  accelerator: "<control>Q"
	  callback: ,(lambda args(gtk-widget-destroy window)))
	 ("/_Help" type: "<LastBranch>")
	 ("/Help/_About")))
  
      (gtk-box-pack-start
       mainbox
       (gtk-item-factory-get-widget item-factory "<main>")
       #f #f 0))
    
    ;; Vertical pane with text and table
    (let((vpaned(gtk-vpaned-new)))
      (gtk-box-pack-start mainbox vpaned #t #t 0)
      
      (gtk-paned-add1 vpaned sql)
      
      (gtk-scrolled-window-set-policy scrolled-win 'automatic 'automatic)
      (gtk-container-set-border-width scrolled-win 5)
      (gtk-paned-add2 vpaned scrolled-win)
      )
    
    ;; Horizontal button-box
    (let((bbox
	  ;;(gtk-hbutton-box-new)
	  (gtk-hbox-new #f 5)
	  ))
      ;;(gtk-button-box-set-layout bbox 'start)
      ;;(gtk-button-box-set-spacing bbox 0)

      ;; Disable button if not connected
      (gtk-widget-set-sensitive execute *conn*)
      (gtk-signal-connect
       execute "clicked" 
       (lambda args
	 (let*((query(gtk-editable-get-chars sql))
	       (answer(do-sql query)))
	   (when
	    answer
	    (let*((desc(first answer))
		  (more-results? (second answer))
		  (data(cddr answer))
		  (columns(length desc)))
	      (gtk-label-set-text
	       status
	       (format "~a records retrieved~a"
		       (length data)
		       (if more-results?
			   ", more results follow"
			   "")))
	      (when clist
		    (gtk-container-remove scrolled-win clist))
	      (set! clist(apply gtk-clist-new (map car desc)))

	      (let*((accel-group(gtk-accel-group-new))

		    (item-factory(gtk-item-factory-new
				  (gtk-menu-get-type)"<popup>" accel-group))
		    )
		;;(gtk-accel-group-attach accel-group window)
		(gtk-item-factory-create-item item-factory "/Print selection")
		(gtk-signal-connect
		 clist
		 "button_press_event"
		 (lambda(output event)
		   (case(gdk-event-type event)
		     ((button-press)
		      (and(=fx(gdk-event-button event) 3)
			  (multiple-value-bind
			   (x y)
			   (gdk-window-get-root-origin (gtk-widget-window window))
			   [print "x: "x " y: "y]
			   [print "event-y: "(gdk-event-y event)]
			   [print "alloc-y: "(gtk-widget-allocation-y clist)]
			   (gtk-item-factory-popup
			    item-factory
			    (+ x (gtk-widget-allocation-x clist)
			       (inexact->exact(gdk-event-x event)))
			    (+ y (gtk-widget-allocation-y clist)
			       (inexact->exact(gdk-event-y event)))
			    1
			    (gdk-event-time event)))))))
		 #t))
	      
	      (gtk-widget-show clist)
	      (gtk-widget-set-usize clist 400 200)
	      (gtk-container-add scrolled-win clist)
	      
	      (let((sort-column 0)
		   (sort-ascending? #t))
		(gtk-signal-connect
		 clist "click_column" 
		 (lambda(w column)
		   (if (=fx column sort-column)
		       (set! sort-ascending?(not sort-ascending?))
		       (begin
			 (set! sort-column column)
			 (set! sort-ascending? #t)
			 (gtk-clist-set-sort-column clist sort-column)))
		   
		   (gtk-clist-set-sort-type
		    clist
		    (if sort-ascending? 'ascending 'descending))
		   (gtk-clist-sort clist))))
	      
	      (for-each
	       (lambda(record)
		 (apply
		  gtk-clist-append
		  clist
		  (map
		   (lambda(item)
		     (cond
		      ((eq? #unspecified item)"")
		      ((string? item)item)
		      ((tm? item)(strftime item))
		      (else (format "~a" item))))
		   record)))
	       data)
	      )))))
      (gtk-container-add bbox execute)
      (gtk-container-add bbox prev)
      (gtk-container-add bbox next)
      (gtk-container-add bbox all)

      (gtk-container-add bbox status)
      (gtk-box-pack-start mainbox bbox))
    
    (gtk-widget-show-all window)
    (gtk-main)))
    

(define(sql-mode)
  (let loop()
    (display* (current-driver) "> ")
    (let((stmt(read-line)))
      (unless(eof-object? stmt)
	     (let((answer(do-sql stmt)))
	       (when(pair? answer)
		    (for-each
		     (lambda(record)
		       (print record)
		       )
		     answer))
	       (loop))))))

(define *mode* gui-mode)

(define(main argv)
  (unless(pair?(rdbms-drivers))
	 (error(car argv)"no database drivers compiled into" ""))
  (args-parse
   (cdr (command-line))
   ((("-u" "--user-name") ?name (synopsis "user name"))
    (current-username name))
   
   ((("-p" "--password") ?name (synopsis "user password"))
    (current-password name))
   
   ((("-d" "--dbname") ?name (synopsis "database name (connect string)"))
    (current-dbname name))
   
   (("--host" ?name (synopsis "host name"))
    (current-hostname name))
   
   ((("-s" "--sql") ?sql (synopsis "SQL statement"))
    (current-statement sql))
   
   ((("-r" "--max-rows")
     ?number
     (synopsis "Show only the <number> result rows"))
    (max-rows (string->number number)))
   
   ((("-i" "--repl")(synopsis "run (repl)"))
    (set! *mode* repl))
   
   ((("-c" "--comman-line")
     (synopsis "run in command line mode"))
    (set! *mode* sql-mode))
   
   ((("-h" "--help")
     (help "Print this help message and exit"))
    (print "Usage: "
	   (car argv)
	   " [options] driver")
    (print "  where driver is one of "(rdbms-drivers))
    (print "  and options are")
    (args-parse-usage #f)
    (exit 0))
   
   (else(current-driver else)))

  (connect)
  (*mode*))