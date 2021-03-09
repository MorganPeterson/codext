(fn publisher [pdata]
  (var t (. pdata :txt))
  (let [cde (. pdata :cde)]
    (each [k v (pairs cde)]
      (let [ldv (string.format "[%s]" k)
            nwv (string.format "%s\n```\n'%s'```" k v)]
        (set t (string.gsub t ldv nwv)))))
  t)
