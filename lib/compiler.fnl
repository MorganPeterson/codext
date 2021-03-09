(fn compiler [pdata]
  (let [c (. pdata :cde)]
    (var block (. c :main))
    (each [f v (pairs c)]
      (when (~= f "main")
        (let [rf (string.format "<<%s>>" f)]
          (set block (string.gsub block rf #v)))))
    block))
