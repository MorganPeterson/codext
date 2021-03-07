(local parser (require :lib.parser))
(local combinators (require :lib.combinators))

(local p-and combinators.p-and)
(local check-char combinators.check-char)

(local env {:TITLE "" :AUTHOR "" :EMAIL "" :TYPE ""})
(local document [])

(fn trim-space [s]
  (let [s-match string.match]
   (s-match s "^%s*(.*%S)")))

(fn out-file-name [n]
  (.. (n:sub 0 -3) "txt"))

(fn write-text [d fd]
  (fd:write (string.format "%s: %s\n" :TITLE (. env :TITLE)))
  (fd:write (string.format "%s: %s\n" :AUTHOR (. env :AUTHOR)))
  (fd:write (string.format "%s: %s\n" :EMAIL (. env :EMAIL)))
  (fd:write (string.format "%s: %s\n" :TYPE (. env :TYPE)))
  (each [_ v (ipairs d)]
    (fd:write (string.format "%s\n" v))))

(fn fill-text [d filename]
  (with-open [file (io.open filename :wb)]
    (write-text d file)))

(fn print-header [text]
  (table.insert document "============================================================")
  (table.insert document text)
  (table.insert document "============================================================\n"))

(fn print-section [text]
  (table.insert document text)
  (table.insert document "------------------------------------------------------------"))

(fn print-text [cmd arg]
  (if (= cmd "**")
    (print-section arg)
    (= cmd "*")
    (print-header arg)
    (table.insert document arg)))

(fn print-cmd [cmd arg]
  (if (= cmd "begin_src")
    (table.insert document (string.format "\n[%s]" arg))
    (= cmd "end_src")
    (table.insert document (string.format "[/]\n" arg))))

(fn print-code [arg]
  (let [cp (p-and (check-char "#") (check-char "="))
        cv (cp (trim-space arg))]
    (if (~= (. cv 1) nil)
      (table.insert document (string.format "  <%s>" (. cv 2)))
      (table.insert document arg))))

(fn publisher [filename]
  (var block {})
  (let [results (parser filename)]
    (if (= (. results :status) nil)
      (each [_ line (ipairs (. results :cmds))]
        (if (= (. line :type) :var)
          (tset env (. line :command) (. line :arg))
          (= (. line :type) :text)
          (print-text (. line :command) (. line :arg))
          (= (. line :type) :cmd)
          (print-cmd (. line :command) (. line :arg))
          (= (. line :type) :code)
          (print-code (. line :arg))
          (table.insert document (. line :arg))))
      (print (. results :status))))
  (fill-text document (out-file-name filename))
  (. env :TYPE))

