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
# Create test.db database

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

# Examples

## populate_tables.xc

[populate_tables.xc](populate_tables.xc) deletes all rows from the `person` and `details` tables then repopulates them.

## print_person_table.xc

[print_person_table.xc](print_person_table.xc) selects all rows from the `person` table and prints them.

## join_person_details.xc

[join_person_details.xc](join_person_details.xc) prints the results of a more complex query that joins the `person` and `details` tables, renames a column, and embeds C variables.

## populate_tables_random.xc

[populate_tables_random.xc](populate_tables_random.xc) repopulates the tables from C structs containing randomized data.

## syntax_error.xc

[syntax_error.xc](syntax_error.xc) illustrates how the benefits of the sqlite ableC extension extend beyond providing convenient syntax; errors that, without this extension, would not have appeared until run-time are now able to be caught earlier, at compile-time.

```c
  // this is a compile-time error
  on db query {
    SELECT * FROM
  } as from_what;
  
  // this is a run-time error
  sqlite3_prepare_v2(db, "SELECT * FROM", len, query, 0);
```

## semantic_errors.xc

[semantic_errors.xc](semantic_errors.xc) further illustrates the compile-time error checking that is done by the extension. Even if an SQL query is syntactically valid, various errors can occur and be detected at compile-time.

```
  // table `foo' does not exist
  on db query {
    SELECT * FROM foo
  } as foos;

  // column `bar' does not exist
  on db query {
    SELECT bar FROM person
  } as bars;

  // column `age' does not exist in table `person' even though `age' is
  //  available in the results
  on db query {
    SELECT person.age
    FROM   person JOIN details
                    ON person.person_id = details.person_id
  } as no_ages;
```

## foreach_error.xc

[foreach_error.xc](foreach_error.xc) is another example of compile-time error checking.

## beware_bugs.xc

[beware_bugs.xc](beware_bugs.xc) contains examples of bugs in this extension.


