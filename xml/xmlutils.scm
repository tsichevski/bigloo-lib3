(module
 xmlutils
 (import xtree xpath xmlio xmlregexp encoding xmlsave)
 (library common)
 (export
  (xml-as-xpath-object arg #!optional arg1)
  (xml-xpath-object->obj self::xml-xpath-object)
  (xml-node-set->string::bstring ns::xml-node-set #!optional encoding)
  (xml->string::bstring arg #!optional arg1 encoding)

  (xml-as-node-set::xml-node-set arg #!optional arg1)
  (xml-node-set-for-each proc::procedure ns::xml-node-set)
  (xml-node-set-map::pair-nil proc::procedure self::xml-node-set)
  (xml-node-set-filter::pair-nil proc::procedure self::xml-node-set)
  (xml-node-set-filter-map::pair-nil proc::procedure self::xml-node-set)
  (xml-node-set->list::pair-nil self::xml-node-set)

  (xml-for-each proc::procedure arg #!optional arg1)
  (xml-map::pair-nil proc::procedure arg #!optional arg1)
  (xml-filter::pair-nil proc::procedure arg #!optional arg1)
  (xml-filter-map::pair-nil proc::procedure arg #!optional arg1)
  (xml->list::pair-nil arg #!optional arg1)
  (xmlobj-children->list::pair-nil node::xmlobj)
  )
 )

(define (xmlobj-children->list::pair-nil node::xmlobj)
  (let loop ((child (xmlobj-children node))
	     (accu '()))
    (if child
	(loop (xmlobj-next child)(cons child accu))
	(reverse! accu))))

(define (xml-as-xpath-object arg #!optional arg1)
  (let loop ((arg arg))
    (and arg
	 (cond ((xml-node? arg)
		(if arg1
		    (let ((ctxt (xml-xpath-new-context (xmlobj-doc arg))))
		      (xml-xpath-context-set-node ctxt arg)
		      (loop ctxt))
		    (xml-xpath-new-node-set arg)))
	       
	       ((xml-xpath-context? arg)
		(xml-xpath-eval arg1 arg))
	       (else
		[error "xml-as-xpath-object" "Invalid argument type" arg))))))

	  
(define (xml-node-set->string::bstring ns::xml-node-set #!optional encoding)
  (let((length (xml-node-set-length ns)))
    (if (=fx length 0)
	""
	(let((buf
	      (xml-alloc-output-buffer
	       (and encoding
		    (xml-find-char-encoding-handler encoding)))))

	  (do ((i 0 (+ i 1)))
	      ((>= i length) #unspecified)
	    (xml-node-dump-output buf (xml-node-set-ref ns i)
				  encoding: encoding))

	  (let((result::bstring
		(xml-buffer-content
		 (if encoding
		     (begin
		       (xml-output-buffer-flush buf)
		       (xml-output-buffer-conv buf))
		     (xml-output-buffer-buffer buf)))))
	    (xml-output-buffer-close buf)
	    result)))))

(define (xml-xpath-object->obj self::xml-xpath-object)
  (case (xml-xpath-object-type self)
    ((undefined)
     #unspecified)
    
    ((nodeset)
     (xml-node-set->list (xml-xpath-object-nodesetval self)))
    
    ((boolean)
     (xml-xpath-object-boolval self))
    
    ((number)
     (xml-xpath-object-floatval self))
    
    ((string)
     (xml-xpath-object-stringval self))
    
    ((point range locationset users xslt-tree)
     ;; At the moment, I don't know how to print that types, display
     ;; it as is.
     self)))

;; This worked in bigloo-2.6
;; (add-printer xml-xpath-object?
;;   (lambda (display obj port)
;;     (display (xml-xpath-object->obj obj) port)))

(define (xml->string::bstring arg #!optional arg1 encoding)
  (let loop ((obj (xml-as-xpath-object arg arg1)))
    (cond ((xml-xpath-object? obj)
	   (case (xml-xpath-object-type obj)
	     ((nodeset)
	      (xml-node-set->string (xml-as-node-set obj)
				    encoding))
	     (else
	      (proc-output display obj))))
	  (else
	   ""))))

(define (xml-as-node-set::xml-node-set arg #!optional arg1)
  (let loop ((arg arg))
    (if arg
	(cond ((xml-xpath-object? arg)
	       (loop (xml-xpath-object-nodesetval arg)))
	      
	      ((xml-node-set? arg) arg)
	      (else
	       (loop (xml-as-xpath-object arg arg1))))
	(loop (xml-xpath-new-node-set)))))

(define (xml-node-set->list::pair-nil self::xml-node-set)
  (let((len (xml-node-set-length self)))
    (let loop ((i 0)
	       (accu '()))
      (if (<fx i len)
	  (loop (+fx i 1)
		(cons (xml-node-set-ref self i)
		      accu))
	  (reverse! accu)))))

(define (xml-node-set-for-each proc self::xml-node-set)
  (let((len (xml-node-set-length self)))
    (let loop ((i 0))
      (unless
       (>=fx i len)
       (proc (xml-node-set-ref self i))
       (loop (+fx i 1))))))

(define (xml-node-set-map proc self::xml-node-set)
  (let((len (xml-node-set-length self)))
    (let loop ((i 0)
	       (accu '()))
      (if (<fx i len)
	  (loop (+fx i 1)
		(cons (proc (xml-node-set-ref self i))
		      accu))
	  (reverse! accu)))))

(define (xml-node-set-filter proc self::xml-node-set)
  (let((len (xml-node-set-length self)))
    (let loop ((i 0)
	       (accu '()))
      (if (<fx i len)
	  (loop (+fx i 1)
		(let((nd (xml-node-set-ref self i)))
		(if (proc nd)
		    (cons nd accu)
		    accu)))
	  (reverse! accu)))))

(define (xml-node-set-filter-map proc self::xml-node-set)
  (let((len (xml-node-set-length self)))
    (let loop ((i 0)
	       (accu '()))
      (if (<fx i len)
	  (loop (+fx i 1)
		(let((result (proc (xml-node-set-ref self i))))
		(if result
		    (cons result accu)
		    accu)))
	  (reverse! accu)))))

(define (xml-for-each proc arg #!optional arg1)
  (xml-node-set-for-each proc (xml-as-node-set arg arg1)))

(define (xml-map proc arg #!optional arg1)
  (xml-node-set-map proc (xml-as-node-set arg arg1)))

(define (xml-filter proc arg #!optional arg1)
  (xml-node-set-filter proc (xml-as-node-set arg arg1)))

(define (xml-filter-map proc arg #!optional arg1)
  (xml-node-set-filter-map proc (xml-as-node-set arg arg1)))

(define (xml->list::pair-nil arg #!optional arg1)
  (xml-node-set->list (xml-as-node-set arg arg1)))
