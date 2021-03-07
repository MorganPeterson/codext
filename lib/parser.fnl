(local combinators (require :lib.combinators))
(local p-and combinators.p-and)
(local check-char combinators.check-char)
(local p-or combinators.p-or)
(local apply combinators.apply)

(fn create-string-trim []
  (let [s-match string.match]
    (fn [str]
      (if (= str nil)
        str
        (or (and (s-match str "^()%s*$") "") (s-match str "^%s*(.*%S)"))))))

(fn find-cmd-line []
  "find a line that contains a command"
  (p-and (check-char "#") (check-char "+")))

(fn find-txt-line []
  "parse out text lines given it formatting symbol"
  (p-or
    (p-or
      (p-and (check-char "*")
             (check-char "*"))
      (check-char "*"))
    (check-char "")))

(fn find-command-arg [_ cstr]
  "parse a command and the args to a table [command arg type]"
  (var s [])
  (var str-trim (create-string-trim))
  (each [cs (cstr:gmatch "%S+")]
    (if (< (length s) 2)
      (table.insert s cs)
      (table.insert s 2 (.. (. s 2) " " cs))))
  (if (= (string.sub (. s 1) -1) ":")
    {:command (string.sub (. s 1) 1 -2) :arg (str-trim (. s 2)) :type :var}
    {:command (. s 1) :arg (str-trim (. s 2)) :type :cmd}))

(fn find-txt-arg [cmd cstr]
  "parse a command and the args to a table [command arg type]"
  (var s [])
  (let [str-trim (create-string-trim)]
    {:command cmd :arg (str-trim cstr) :type :text}))

(fn p-commands [text]
  "parse commands"
  (let [cmd ((apply find-command-arg (find-cmd-line)) text)
        str-trim (create-string-trim)]
    (if (~= (. cmd 1) nil)
      (. cmd 1)
      (let [txt ((apply find-txt-arg (find-txt-line)) text)]
        (if (~= (. txt 1) nil)
          (. txt 1)
          {:command "." :arg (str-trim (. txt 2)) :type :text})))))

(fn read-file [filename]
  "opens and reads entire file returning a table [ok msg]"
  (let [(ok msg)
        (pcall #(with-open [file (io.open filename :rb)]
                           (file:read "*a")))]
    {: ok : msg}))

(fn split-lines [text]
  "split text by newline"
  (var splitText [])
  (each [s (string.gmatch text "[^\r\n]+")]
    (table.insert splitText s))
  splitText)

(fn parser [filename]
  "main parser for parsing a raw file"
  (var status nil)
  (var code {:code? false :type nil})
  (var cmds [])
  (let [fileStatus (read-file filename)]
    (if fileStatus.ok
      (each [_ line (ipairs (split-lines fileStatus.msg))]
        (let [cmd (p-commands line)]
          (if (= (. cmd :type) :cmd)
            (if (= (. cmd :command) :begin_src)
              (set code {:code? true :type cmd.arg})
              (= (. cmd :command) :end_src)
              (set code {:code? false :type nil})))
          (if (= (. cmd :type) :text)
            (when code.code?
              (tset cmd :type :code)
              (tset cmd :command (. code :type))))
          (table.insert cmds cmd)))
    (set status fileStatus.msg)))
  {: status : cmds})

