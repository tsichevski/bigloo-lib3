;; Created by cgen from (gc.defs). Do not edit!
(module
  gc
  (extern)
  (export (gc-disable disable::bool)))

(define
  (gc-disable disable::bool)
  (pragma
    "extern int GC_dont_gc; GC_dont_gc = $1"
    disable)
  #unspecified)
