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
 expat-utils
 (library common node)
 (include "common.sch")
 (import
  expat
  )

 (export
  (xml-build-node::pair
   str
   #!key
   (escape-cdata #t)
   (encode (lambda(t)t))
   decode

   ;; elements and attributes that do not match this namespace
   ;; will be filtered out, of #f to disable filtering
   (namespaces #f)

   ;; is not used
   (namespace-delim #\:)
   )
  )
 )

;; parse the string for predefined XML entityes. Return a list of
;; elements of SGML-CHAR SGML-CHAR-REF and SGML-ENTITY in
;; !!!REVERSE!!! order
(define (encode-predefined-entities::pair-nil
         str::bstring
         #!optional (parents::pair-nil '()))
  (let* ((chars '())
         (res '())
         (flush-chars!
          (lambda()
            (if(pair? chars)
               (begin
                 (push!
                  res
                  (make-sgml-char parents(list->string(reverse chars))))
                 (set! chars '())))))
         (push-entity!
          (lambda(e)
            (flush-chars!)
            (push! res e))))
    
    (read/rp (regular-grammar
              ()
              ((: "&#"(in (uncase (in ("09af")))))
               (push-entity!
                (make-sgml-char-ref
                 parents
                 (string->integer (the-substring 2 (the-length)) 16)))
               (ignore))
              (#\&
               (push-entity!
                (make-sgml-entity parents "amp"))
               (ignore))
              (#\<
               (push-entity!
                (make-sgml-entity parents "lt"))
               (ignore))
              (#\>
               (push-entity!
                (make-sgml-entity parents "gt"))
               (ignore))
              (#\"
               (push-entity!
                (make-sgml-entity parents "quot"))
               (ignore))
              ((or #\newline #\return #\tab)
               (push-entity!
                (make-sgml-char-ref parents(char->integer(string-ref(the-string)0))))
               (ignore))
              (else
               (let((c(the-failure)))
                 (if(eof-object? c)
                    (begin
                      (flush-chars!)
                      res)
                    (begin
                      (push! chars c)
                      (ignore))))))
             (open-input-string str))))

;;(encode-predefined-entities "asdf<qwerty>zxcv")

;; FIXME: the implementation has to be refactored to make dealing with
;; namespaces more clean
(define (xml-build-node
         str
         #!key
         (escape-cdata #t)
         (encode (lambda(t)t))
         decode

         ;; elements and attributes that do not match this namespace
         ;; will be filtered out, of #f to disable filtering
         (namespaces #f)

         ;; is not used
         (namespace-delim #\:)
         )
  
  
  ;; Use namesapace info to translate name. If namespaces equals #f,
  ;; then return the argument. Otherwise, if name matches one of
  ;; namespaces, return the argument with the namespace prefix
  ;; stripped. If the argument doesn't match any namespace, return #f
  (define (translate-name name)
    (if namespaces
        (let loop ((namespaces namespaces))
          (and (pair? namespaces)
               (let*((namespace (car namespaces))
                     (nslength(string-length namespace)))
                 (or
                  (and (string-prefix? namespace name)
                       (>fx (string-length name) nslength)
                       (char=? (string-ref name nslength) namespace-delim)
                       (substring name (+fx 1 nslength) (string-length name)))
                  (loop (cdr namespaces))))))
        name))

  (let ((decode (or decode encode))
        (elem-stack '())
        
        ;; uniq name <-> entity relationship
        (lookup-entity
         (let((registry '()))
           (lambda(name::bstring)
             (cond((assoc name registry) => cdr)
                  (else
                   (let((new-node(instantiate::sgml-entity (name name))))
                     (push! registry (cons name new-node))
                     new-node)))))))

    (xml-parse
     (encode str)
     
     encoding: "utf-8"
     
     stag-handler:
     (lambda(gi atts)
       ;; after an stag is processed, the elem-stack is as follows: attlist, gi, ...
       (set! elem-stack
             (cons*
              atts
              gi
              elem-stack)))
     
     etag-handler:
     (lambda(gi::bstring)
       (let children-collect ((children '()))
         (let((top (pop! elem-stack)))
           (if (list? top)
               (let((top-gi (pop! elem-stack))
                    (eff-gi (translate-name gi)))
                 
                 (if eff-gi
                     (let((node
                           (instantiate::sgml-element
                            (gi eff-gi)
                            (atts
                             (filter-map
                              (lambda(ass)
                                (let ((aname (translate-name(decode(car ass)))))
                                  (and aname
                                       (cons aname
                                             (decode (cdr ass))))))
                              top))
                            (children children))))
                       (for-each
                        (lambda (child)
                          (node-parents-set!
                           child
                           (list node)))
                        children)
                       (push! elem-stack node))

                     ;; gi doesn't match any of requested namespaces,
                     ;; put all children collected on stack
                     (for-each
                      (lambda (child)(push! elem-stack child))
                      children)
                     )
                 
                 (if (string=? top-gi gi)
                     #unspecified
                     (children-collect '())))
               (children-collect (cons top children))))))
     
     cdata-handler:
     (lambda(utf8-data)
       (let((data (decode utf8-data)))
         (set! elem-stack
               (if escape-cdata
                   (append! (encode-predefined-entities data)
                            elem-stack)
                   (cons (instantiate::sgml-char
                          (text (utf8-data data)))
                         elem-stack)))))
     
     default-handler:
     (lambda(data)
       (push!
        elem-stack
        (read/rp (regular-grammar
                  ()
                  
                  ;; FIXME: this should be obsoleted by latest versions of expat
                  ((: "<!--"
                      (submatch
                       (*
                        (or
                         (out "-")
                         (: "-" (out "-") all)
                         (: "--" (out ">") all))))
                      "-->")
                   (instantiate::sgml-comment(text(the-submatch 1))))
                  
                  ((: "<?"
                      (submatch
                       (*
                        (or
                         (out "?>")
                         (: "?" (out ">") all)))
                       )
                      (? "?")">")
                   (instantiate::sgml-pi(text(the-submatch 1))))
                  
                  ((: "&"(+(or (in("azAZ")) digit)))
                   (lookup-entity(the-substring 1(the-length))))
                  
                  (else
                   (instantiate::sgml-unparsed-data(text data))))
                 (open-input-string data)))))
    (reverse elem-stack)))
;;(xml-build-node "<!DOCTYPE HTML SYSTEM \"qqq\"><a>sss<!-- comment -->&nbsp;<b/>eee</a>")
