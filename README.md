# Codext

A tool for writing literate programs.

## Dependencies

1. [lua](https://lua.org) >= 5.3
2. [Fennel](https://fennel-lang.org) >= 0.8
3. lua5.3-dev for compiling a binary

## Usage

`fennel init.fnl [publish | compile] [your-file]`

## compiling
Included in the repo is shell script with a sample compile command for
compiling to a single binary. You will need the lua development libs
installed on your system. You will need to link to the shared lua libs
and the lua includes directory. More information can be found running the
command:

`fennel --help`

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
