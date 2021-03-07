(fn read-input [input]
  "Get the first character of a string"
  (input:sub 1 1))

(fn input-advance [input inc]
  "Remove first character of string and return new string"
  (input:sub (+ inc 1)))


(fn create-result [...]
  "Varadic function return a table of all args"
  [...])

(fn check-char [ch]
  "Checks if character is the first in a string. Returns table [char, rest]"
  (fn [input]
    (let [r (read-input input)]
      (if (= r ch)
        (create-result r (input-advance input 1))
        (create-result nil input)))))

(fn p-or [parser1 parser2]
  "Takes two parsers and if either one works returns result"
  (fn [input]
    (let [result1 (parser1 input)
          result2 (parser2 input)]
      (if (. result1 1)
        result1
        (. result2 1)
        result2
        (create-result nil input)))))

(fn p-and [parser1 parser2]
  "Takes tow parsers and if both work returns the result of both"
  (fn [input]
    (let [result1 (parser1 input)]
      (if (. result1 1)
        (let [result2 (parser2 (input-advance input 1))]
          (if (. result2 1)
            (create-result 
              (.. (. result1 1) (. result2 1))
              (input-advance input 2))
            (create-result nil input)))
        (create-result nil input)))))

(fn apply [f parser]
  "Applies a function to the first field of result table of a parser"
  (fn [input]
    (let [result (parser input)]
      (if (. result 1)
        (create-result (f (. result 1) (. result 2)))
        result))))

(fn find-cmd-line [str]
  "find a line that contains a command"
  (p-and (check-char "#") (check-char "+")))

(fn find-txt-line [str]
  (p-or
    (p-or
      (p-and (check-char "*")
             (check-char "*"))
      (check-char "*"))
    (check-char "")))

(fn find-command-arg [_ cstr]
  "parse a command and the args to a table [command arg type]"
  (var s [])
  (each [cs (cstr:gmatch "%S+")]
    (if (< (length s) 2)
      (table.insert s cs)
      (table.insert s 2 (.. (. s 2) " " cs))))
  {:command (. s 1) :arg (. s 2) :type "cmd"})

(fn find-txt-arg [cmd cstr]
  "parse a command and the args to a table [command arg type]"
  (var s [])
  {:command cmd :arg cstr :type "text"})

(fn p-commands [text]
  "parse commands"
  (let [cmd ((apply find-command-arg (find-cmd-line)) text)]
    (if (~= (. cmd 1) nil)
      (. cmd 1)
      (let [txt ((apply find-txt-arg (find-txt-line)) text)]
        (if (~= (. txt 1) nil)
          (. txt 1)
          {:command nil :arg (. txt 2) :type "text"})))))

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
  (var status nil)
  (var cmds [])
  (let [fileStatus (read-file "test.txt")]
    (if fileStatus.ok
      (each [_ line (ipairs (split-lines fileStatus.msg))]
        (let [cmd (p-commands line)]
          (table.insert cmds cmd)))
    (set status fileStatus.msg)))
  {: status : cmds})

