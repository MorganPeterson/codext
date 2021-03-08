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
  "Takes two parsers and if both work returns the result of both"
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

{: apply : p-and : p-or : check-char}
