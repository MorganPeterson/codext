(local parser (require :lib.parser))
(local combinators (require :lib.combinators))

(local p-and combinators.p-and)
(local check-char combinators.check-char)

(local env {:TITLE "" :AUTHOR "" :EMAIL "" :TYPE ""})
(local document [])

(fn trim-space [s]
  "trim spaces of string"
  (let [s-match string.match]
   (s-match s "^%s*(.*%S)")))

(fn out-file-name [n]
  "append .txt to file name"
  (.. (n:sub 0 -3) "txt"))

(fn write-text [d fd]
  "write text to file"
  (fd:write (string.format "%s: %s\n" :TITLE (. env :TITLE)))
  (fd:write (string.format "%s: %s\n" :AUTHOR (. env :AUTHOR)))
  (fd:write (string.format "%s: %s\n" :EMAIL (. env :EMAIL)))
  (fd:write (string.format "%s: %s\n" :TYPE (. env :TYPE)))
  (each [_ v (ipairs d)]
    (fd:write (string.format "%s\n" v))))

(fn fill-text [d filename]
  "open file for writing"
  (with-open [file (io.open filename :wb)]
    (write-text d file)))

(fn print-header [text]
  "print h1"
  (table.insert document "============================================================")
  (table.insert document text)
  (table.insert document "============================================================\n"))

(fn print-section [text]
  "print h2"
  (table.insert document text)
  (table.insert document "------------------------------------------------------------"))

(fn print-text [cmd arg]
  "print plain text"
  (if (= cmd "##")
    (print-section arg)
    (= cmd "#")
    (print-header arg)
    (table.insert document arg)))

(fn print-cmd [cmd arg]
  "print command line"
  (if (= cmd "end")
    (table.insert document (string.format "[/%s]\n" arg))
    (table.insert document (string.format "\n[%s]" arg))))

(fn print-code [cmd arg]
  "print user code"
  (if (= cmd arg)
    (print-cmd cmd arg)
    (let [cp (p-and (check-char "!") (check-char "="))
          cv (cp (trim-space arg))]
      (if (~= (. cv 1) nil)
        (table.insert document (string.format "<%s>" (. cv 2)))
        (table.insert document arg)))))

(fn publisher [filename]
  (var block {})
  (let [results (parser filename)]
    (if (= (. results :status) nil)
      (each [_ line (ipairs (. results :cmds))]
        (if (= (. line :type) :var)
          (tset env (. line :command) (. line :arg))
          (= (. line :type) :text)
          (print-text (. line :command) (. line :arg))
          (= (. line :type) :code)
          (print-code (. line :command) (. line :arg))
          (table.insert document (. line :arg))))
      (print (. results :status))))
  (fill-text document (out-file-name filename))
  (. env :TYPE))

