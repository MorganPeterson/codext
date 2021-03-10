(fn publisher [pdata]
  (var t (. pdata :txt))
  (let [cde (. pdata :cde)]
    (each [k v (pairs cde)]
      (let [ldv (string.format "%%[%s%%]" k)
            nwv (string.format ">%s\n```\n%s```" k v)
            (x y) (string.find t ldv)]
        (set t (.. (string.sub t 1 (- x 1)) nwv (string.sub t (+ y 1)))))))
  t)
