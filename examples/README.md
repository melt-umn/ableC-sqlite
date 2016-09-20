# How to Compile

First, follow the instructions in [../README.md](../README.md#set-up-environment) to set up the build environment.

## With compile.sh

Run `./compile.sh filename.xc` to generate the executable `filename`.

This script requires:
* `../artifact/ableC.jar`
* `../include/sqlite.xh`
* either:
  * installation of the SQLite shared library and header files; or
  * `../sqlite/sqlite3.c`

For example:
```
$ ./compile.sh print_person_table.xc
$ ./print_person_table
```

## Without compile.sh

Run `java -jar ../artifact/ableC.jar filename.xc -I ../include` to translate the extended C source file `filename.xc` to a pure C source file `filename.pp_out.c`. This can be compiled with gcc as usual. Be sure to pass the `-lsqlite3` option to gcc to link the SQLite shared library.

For example:
```
$ java -jar ../artifact/ableC.jar print_person_table.xc -I ../include/
$ gcc -lsqlite3 -o print_person_table print_person_table.pp_out.c
$ ./print_person_table
```

