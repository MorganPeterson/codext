# Codext

## init.fnl

This is the main function for codext. All this file handles is the command
line arguments and sending requests to their given functions.

>main
```
<<imported_libs>>

<<usage_func>>

<<codext_func>>

(if (~= (length arg) 2)
  (usage (. arg 0))
  (codext (. arg 1) (. arg 2)))
```

Codext has two actions that a user can do. One is publish which writes the
markdown file. The second is compiler which will write the code file with all
of the code in it.

>codext_func
```
(fn codext [action filename]
  (let [p (parser filename)]
    (if (= action "publish")
      (io.write (publisher p))
      (= action "compile")
      (io.write (compiler p))
      (error :non-action))))
```

If incorrect command line options are passed then the usage function will run
and print out usage for the user to see.

>usage_func
```
(fn usage [pn]
  (io.write (string.format "usage: %s [publish | compile] [file]\n" pn)))
```

The program relies on the lib/ directory for the following functions.

>imported_libs
```
(local parser (require :lib.parser))
(local compiler (require :lib.compiler))
(local publisher (require :lib.publisher))
```
