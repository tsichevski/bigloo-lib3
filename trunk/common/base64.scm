;*=====================================================================*/
;*    serrano/prgm/project/bigloo/runtime/Llib/base64.scm              */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Mon Nov 29 17:52:57 2004                          */
;*    Last change :  Mon May  9 21:05:02 2005 (serrano)                */
;*    Copyright   :  2004-05 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    base64 encoding/decoding                                         */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module base64
   
   (export (base64-encode::bstring ::bstring)
	   (base64-decode::bstring ::bstring)))

;*---------------------------------------------------------------------*/
;*    base64-encode ...                                                */
;*---------------------------------------------------------------------*/
(define (base64-encode s)
   (define *base64-table*
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
   (define (encode-char o)
      (string-ref *base64-table* o))
   (define (string-and str o n)
      (bit-and (char->integer (string-ref str o)) n))
   (let* ((x 0)
	  (y 0)
	  (n 3)
	  (len (string-length s))
	  (len-3 (-fx len 3))
	  (rlen (*fx 4 (/fx (+fx 2 len) 3)))
	  (res (make-string rlen)))
      (let loop ((x 0)
		 (y 0))
	 (if (<=fx x len-3)
	     (let ((o0 (bit-rsh (string-and s x #xfc) 2))
		   (o1 (bit-or (bit-lsh (string-and s x #x03) 4)
			       (bit-rsh (string-and s (+fx x 1) #xf0) 4)))
		   (o2 (bit-or (bit-lsh (string-and s (+fx x 1) #x0f) 2)
			       (bit-rsh (string-and s (+fx x 2) #xc0) 6)))
		   (o3 (string-and s (+fx x 2) #x3f)))
		(string-set! res y (encode-char o0))
		(string-set! res (+fx y 1) (encode-char o1))
		(string-set! res (+fx y 2) (encode-char o2))
		(string-set! res (+fx y 3) (encode-char o3))
		(loop (+fx x 3) (+fx y 4)))
	     (case (-fx len x)
		((2)
		 (let ((o0 (bit-rsh (string-and s x #xfc) 2))
		       (o1 (bit-or (bit-lsh (string-and s x #x03) 4)
				   (bit-rsh (string-and s (+fx x 1) #xf0) 4)))
		       (o2 (bit-lsh (string-and s (+fx x 1) #x0f) 2)))
		    (string-set! res y (encode-char o0))
		    (string-set! res (+fx y 1) (encode-char o1))
		    (string-set! res (+fx y 2) (encode-char o2))
		    (string-set! res (+fx y 3) #\=)))
		((1)
		 (let ((o0 (bit-rsh (string-and s x #xfc) 2))
		       (o1 (bit-lsh (string-and s x #x03) 4)))
		    (string-set! res y (encode-char o0))
		    (string-set! res (+fx y 1) (encode-char o1))
		    (string-set! res (+fx y 2) #\=)
		    (string-set! res (+fx y 3) #\=))))))
      res))

;*---------------------------------------------------------------------*/
;*    base64-decode ...                                                */
;*---------------------------------------------------------------------*/
(define (base64-decode s)
   (define (decode-char c)
      (cond
	 ((and (char>=? c #\A) (char<=? c #\Z))
	  (-fx (char->integer c) (char->integer #\A)))
	 ((and (char>=? c #\a) (char<=? c #\z))
	  (+fx 26 (-fx (char->integer c) (char->integer #\a))))
	 ((and (char>=? c #\0) (char<=? c #\9))
	  (+fx 52 (-fx (char->integer c) (char->integer #\0))))
	 ((char=? c #\+)
	  62)
	 ((char=? c #\/)
	  63)
	 (else
	  0)))
   (let* ((len (string-length s))
	  (nlen (*fx (/fx len 4) 3))
	  (res (make-string nlen)))
      (let loop ((x 0)
		 (y 0))
	 (when (<fx x len)
	    (let* ((q0 (decode-char (string-ref s (+fx x 0))))
		   (q1 (decode-char (string-ref s (+fx x 1))))
		   (q2 (decode-char (string-ref s (+fx x 2))))
		   (q3 (decode-char (string-ref s (+fx x 3))))
		   (v0 (bit-or (bit-lsh q0 2)
			       (bit-rsh q1 4)))
		   (v1 (bit-or (bit-and (bit-lsh q1 4) #xf0)
			       (bit-rsh q2 2)))
		   (v2 (bit-or (bit-and (bit-lsh q2 6) #xc0)
			       q3)))
	       (string-set! res y (integer->char v0))
	       (string-set! res (+fx y 1) (integer->char v1))
	       (string-set! res (+fx y 2) (integer->char v2))
	       (loop (+fx x 4) (+fx y 3)))))
      (cond
	 ((char=? (string-ref s (-fx len 2)) #\=)
	  (string-shrink! res (-fx nlen 2)))
	 ((char=? (string-ref s (-fx len 1)) #\=)
	  (string-shrink! res (-fx nlen 1)))
	 (else
	  res))))
      
   
