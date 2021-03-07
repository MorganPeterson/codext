(local parser (require :lib.parser))

(local results (parser "test.txt"))

(if (= results.status nil)
  (each [_ line (ipairs results.cmds)]
    (print line.type line.command line.arg))
  (print results.status))
