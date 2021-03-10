(local parser (require :lib.parser))
(local compiler (require :lib.compiler))
(local publisher (require :lib.publisher))

(fn usage [pn]
  (io.write (string.format "usage: %s [publish | compile] [file]\n" pn)))

(fn codext [action filename]
  (let [p (parser filename)]
    (if (= action "publish")
      (io.write (publisher p))
      (= action "compile")
      (io.write (compiler p))
      (error :non-action))))

(if (~= (length arg) 2)
  (usage (. arg 0))
  (codext (. arg 1) (. arg 2)))
(local parser (require :lib.parser))
(local compiler (require :lib.compiler))
(local publisher (require :lib.publisher))


(fn usage [pn]
  (io.write (string.format "usage: %s [publish | compile] [file]\n" pn)))


(fn codext [action filename]
  (let [p (parser filename)]
    (if (= action "publish")
      (io.write (publisher p))
      (= action "compile")
      (io.write (compiler p))
      (error :non-action))))


(if (~= (length arg) 2)
  (usage (. arg 0))
  (codext (. arg 1) (. arg 2)))
