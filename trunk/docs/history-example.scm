(module test
   (library common)
   )
     
(history-init)
(let loop ()
   (display "history$ ")
   (let((line(read-line)))
     (unless(eof-object? line)
	    (let((result(history-expand line)))
	      (when(string? result)
		   ;; line was expanded
		   (print result)
		   (set! line result))
	      (unless (pair? result)
		      (history-add line)
		      (read/rp (regular-grammar
			()
			("save"
			 (history-write "history-file"))
			("read"
			 (history-read "history-file"))
			("list"
			 (let loop((the-list(history-list))
				   (i (history-base)))
			   (when(pair? the-list)
				(print i ": "(caar the-list))
				(loop(cdr the-list)
				     (+fx i 1)))))
			((: "delete" (+ blank)(submatch (+ digit)))
			 (let((no(string->number (the-submatch 1))))
			   (unless(history-remove no)
				  (print "No such entry " no)))))
		       (open-input-string line))))
	    (loop))))
	 
