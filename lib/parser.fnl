;; publisher variables
(local pub {})

;; compiler variables
(local cde {})

(fn set-pub-var [str]
  "Sets publisher variables after being pulled from text"
  (let [i (str:find ":")]
    (when (~= i nil)
      (tset pub (str:sub 1 (- i 1)) (str:sub (+ i 1))))))

(fn set-code [name str]
  "Sets compiler variables after being pulled from text"
  (tset cde name str))

(fn get-pub-var [fp]
  "Finds and grabs publisher variables from the text"
  (var c "")
  (var done? false)
  (while (not done?)
    (let [t (fp:read 1)]
      (set c (.. c t))
      (when (or (= t "\n") (= t nil))
        (set done? true))))
  (set-pub-var c))

(fn get-code-name [fp]
  "Gets compiler variable name from the text"
  (var done? false)
  (var r "")
  (while (not done?)
    (let [c (fp:read 1)]
      (if (or (= c "\n") (= c nil))
        (set done? true)
        (set r (.. r c)))))
  r)

(fn get-code [fp]
  "Gets code from the text to be set in the compilers variables"
  (var n (get-code-name fp))
  (var r "")
  (var done? false)
  (while (not done?)
    (let [c (fp:read 1)]
      (if (~= c nil)
        (if (= c "!")
          (let [t (fp:read 1)]
            (if (= t "<")
              (set done? true)
              (set r (.. r c t))))
          (set r (.. r c)))
        (set done? true))))
  (set-code n r)
  (.. "[" n "]"))

(fn gobbler [fp]
  "Generic function for transversing the text and parsing it"
  (var r "")
  (let [c (fp:read 1)]
    (when (~= c nil)
      (if (= c "!")
        (let [m (fp:read 1)]
          (if (= m "=")
            (get-pub-var fp)
            (= m ">")
            (set r (.. r (get-code fp)))
            (set r (.. r c m))))
        (set r ( .. r c)))
      (set r (.. r (gobbler fp)))))
  r)

(fn read-file [filename]
  "opens and reads entire file returning a table [ok msg]"
  (let [(ok msg)
        (pcall #(with-open [fp (io.open filename :rb)]
                           (gobbler fp)))]
    {: ok : msg}))

(fn set-parsed [txt]
  "Set the final parsed table"
  {: pub : cde : txt})

(fn parser [filename]
  "Main parser function and wrapper for read-file"
  (var txt (read-file filename))
  (if (. txt :ok)
    (set-parsed (. txt :msg))
    (error :parser-failed)))
