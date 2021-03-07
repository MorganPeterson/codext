(local compiler (require :lib.compiler))
(local publisher (require :lib.publisher))

(when (= (length arg) 1)
  (compiler (. arg 1) (publisher (. arg 1))))
