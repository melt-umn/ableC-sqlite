# How to compile

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

# Examples

## Create test.db database

The examples included in this directory use the sqlite ableC extension to modify and query `test.db`.

Run `./create_database.sh` to create `test.db` with the appropriate tables for these examples.

`create_database.sh` uses the `sqlite3` interactive shell. If this is not installed on your system, it will be built from the included source automatically (using `cd ../sqlite/; make`).

The following is the command that `create_database.sh` uses to create the database after deciding whether to use the command `sqlite3` or `../sqlite/sqlite3`.

```bash
#!/bin/bash
echo "
	CREATE TABLE person (
		person_id  INTEGER,
		first_name VARCHAR,
		last_name  VARCHAR
	);
	CREATE TABLE details (
		person_id  INTEGER,
		age        INTEGER,
		gender     VARCHAR
	);
" | sqlite3 "test.db"
```



