(local parser (require :lib.parser))
(local combinators (require :lib.combinators))

(local p-and combinators.p-and)
(local check-char combinators.check-char)

(fn write-code [c blk fd]
  (each [_ v (ipairs (. c blk))]
    (let [cp (p-and (check-char "#") (check-char "="))
          cv (cp v)]
      (if (. cv 1)
        (write-code c (. cv 2) fd)
        (fd:write (string.format "%s\n" v))))))

(fn fill-code [c blk filename]
  (with-open [file (io.open filename :wb)]
    (write-code c blk file)))

(fn out-file-name [n t]
  (.. (n:sub 0 -3) t))

(fn compiler [filename fType]
  (var block {})
  (let [results (parser filename)]
    (when (= (. results :status) nil)
      (each [_ line (ipairs (. results :cmds))]
        (when (= (. line :type) :code)
          (if (= (. block (. line :command)) nil)
            (tset block (. line :command) [(. line :arg)])
            (table.insert (. block (. line :command)) (. line :arg)))))
      (print (. results :status))))
  (fill-code block :main (out-file-name filename fType)))

