(module
 trim
 (extern
  (include "ctype.h")
  )
 (export
  (trim-head::bstring s::bstring)
  (trim-tail::bstring s::bstring)
  (trim::bstring s::bstring)
  ))

(define(trim-head s)
  (string-case
   s
   ((: (+ blank))(substring s(the-length)(string-length s)))
   (else s)))
;;(trim-head " aaa")

(define(trim-tail s)
  (let loop((idx(string-length s)))
    (let((nidx(-fx idx 1)))
      (if(< nidx 0)
	 ""
	 (if(pragma::bool "isspace($1)"
			  (string-ref s nidx))
	    (loop nidx)
	    (substring s 0 idx))))))
;;(trim-tail "aaa    ")

(define(trim s)
  (trim-tail(trim-head s)))
;;(trim " asdd dfdfd ")
