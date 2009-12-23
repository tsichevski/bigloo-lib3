(module
 biconv
 (library common)
 (main main)
 (include "common.sch")
 )

(define (main argv)
  (define in '())
  (define from #f)
  (define to #f)
  (define output #f)
;   (define escape-from "")
;   (define escape-to "")
  
  (define (parse-args args)
    (args-parse
     args
     ((("-h" "--help")
       (help "Print this help message and exit"))
      (args-parse-usage #f)
      (exit 0))
     
     ((("-f" "--from-code")
       ?encoding
       (synopsis "Convert characters from encoding"))
      (set! from encoding))
     
     ((("-t" "--to-code")
       ?encoding
       (synopsis "Convert characters to encoding"))
      (set! to encoding))
     
;     ((("-l" "--list")
;      (synopsis "List known coded character sets"))
     
;      ((("-r" "--translate")
;        ?from
;        ?to
;        (synopsis "Invalid input character translation"))
;       (unless(=fx (string-length from) (string-length to))
; 	     (print "arguments of --translate option have different length")
; 	     (exit 0))
;       (set! escape-from from)
;       (set! escape-to to)
;       )

     ((("-o" "--output")
       ?file
       (synopsis "Specify output file (instead of stdin)"))
      (set! output file))
     
     (else (push! in else))))
  
  (parse-args(cdr argv))
  (unless (and from to)
	  (parse-args '("-h")))

  (let*((convert (make-iconv-encoder from to))
	(convert-string
	 (lambda(s)
	   (display
	    (convert
	     s
; 	     onerror:
; 	     (lambda(s o p)
; 	       (display
; 		(let*((ch(string-ref s o))
; 		      (index(string-index escape-from ch)))
; 		  (if index
; 		      (string-ref escape-to index)
; 		      ch))
; 		p)
; 	       1)
	     )))))
    
    (if(pair? in)
       (for-each
	(lambda(filename)
	  (let((src (file-contents filename)))
	    (convert-string src)))
	in)
       (let loop()
	 (let((line(read-line)))
	   (unless (eof-object? line)
		   (convert-string line)
		   (newline)
		   (loop)))))))
    