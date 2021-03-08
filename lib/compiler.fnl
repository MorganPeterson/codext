(local parser (require :lib.parser))
(local combinators (require :lib.combinators))

(local p-and combinators.p-and)
(local check-char combinators.check-char)

(fn write-code [c blk fd]
  "writes code to file"
  (each [_ v (ipairs (. c blk))]
    (let [cp (p-and (check-char "!") (check-char "="))
          cv (cp v)]
      (if (. cv 1)
        (write-code c (. cv 2) fd)
        (fd:write (string.format "%s\n" v))))))

(fn fill-code [c blk filename]
  "Opens fie for writing"
  (with-open [file (io.open filename :wb)]
    (write-code c blk file)))

(fn out-file-name [n t]
  "change file type"
  (.. (n:sub 0 -3) t))

(fn compiler [filename fType]
  (var block {})
  (let [results (parser filename)]
    (when (= (. results :status) nil)
      (each [_ line (ipairs (. results :cmds))]
        (when (and (= (. line :type) :code) (~= (. line :command) (. line :arg)))
          (if (= (. block (. line :command)) nil)
            (tset block (. line :command) [(. line :arg)])
            (table.insert (. block (. line :command)) (. line :arg)))))
      (fill-code block :main (out-file-name filename fType)))
      (print (. results :status))))

