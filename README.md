# Introduction
This ableC extension provides language constructs useful for working with
sqlite3 databases.

# Quick Start

## Set up environment
The build scripts assume that the [ableC](https://github.com/melt-umn/ableC)
source exists at `../../ableC/` relative to this directory. A reasonable location to
clone this repository into might be `ableC/`. The prerequisites for building
this extension, particularly that [Silver](http://melt.cs.umn.edu/silver/doc/install-guide/)
be installed, are identical to those of building ableC.

### SQLite Shared Library and Header Files

Although not necessary to run the examples, you might find it useful to install the sqlite development package on your system. With this package, the sqlite shared library can be linked by passing `-lsqlite3` to gcc; without it, the `sqlite.c` source needs to be compiled to an `sqlite.o` object file, which your project then needs to link.

This repository includes the sqlite source. The scripts included under `examples/` will first check for the availability of the sqlite3 shared library and, if it is not installed, will then look for and build the sqlite source at `../sqlite/`.

On Ubuntu, the sqlite shared library and header files can be installed by running `sudo apt-get install libsqlite3-dev`. It is installed on the UMN CSE Labs machines. For other systems, see the [SQLite Download Page](https://www.sqlite.org/download.html).

## Build the extended ableC
Also see [artifact/README.md](artifact/README.md).

```
$ cd artifact/
$ ./build.sh
```

This will produce `ableC.jar`.

## Use the extended ableC
Also see [examples/README.md](examples/README.md).

```
$ cd examples/
$ ./create_database.sh
$ ./compile.sh populate_tables.xc
$ ./populate_tables
$ ./compile.sh print_person_table.xc
$ ./print_person_table
```

# New Syntax

## Creating a new database

Support for creating a new database has not yet been implemented. See [examples/create_database.sh](examples/create_database.sh) for an example of using the `sqlite3` interactive binary to do so.

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

## Connecting to a database

The following example declares and initializes a variable `db`. Its type is `_sqlite_db_s *` (a structure containing `sqlite *`) annotated with the specified tables and columns.

```
  use "test.db" with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR ),
    table details ( person_id  INTEGER,
                    age        INTEGER,
                    gender     VARCHAR )
  } as db;
  
  // clean up when done
  db_exit(db);
```

## Modifying a database

The following example commits changes to `db`. Any valid (case-sensitive) SQL statement can be used inside of the braces. The official [SQLite grammar](https://www.sqlite.org/lang.html) grammar is largely, though not completely, supported. Additionally, an SQL expression enclosed in dollar curly-braces (`${c_expr}`) will be interpreted as a regular C expression (not used in this example, see the next section.)


```
  on db commit { DELETE FROM person };
  on db commit { DELETE FROM details };

  on db commit { INSERT INTO person VALUES (0, 'Aaron',    'Allen') };
  on db commit { INSERT INTO person VALUES (1, 'Abigail',  'Adams') };
  on db commit { INSERT INTO person VALUES (2, 'Benjamin', 'Brown') };
  on db commit { INSERT INTO person VALUES (3, 'Belle',    'Bailey') };

  on db commit { INSERT INTO details VALUES (0,  5, 'M') };
  on db commit { INSERT INTO details VALUES (1, 15, 'F') };
  on db commit { INSERT INTO details VALUES (2, 25, 'M') };
  on db commit { INSERT INTO details VALUES (3, 35, 'F') };
```


## Querying a database

The following example queries `db` to declare and initialize variables `all_people` and `selected_people`. The type of `all_people` is `_sqlite_query_s *` (a structure containing `sqlite3_stmt *`) annotated with the selected columns `person_id`, `first_name`, and `last_name`. The type of `selected_people` is `_sqlite_query` annotated with the selected columns `age`, `gender`, and `surname`.

```
  on db query {
    SELECT * FROM person
  } as all_people;
  
  on db query {
    SELECT   age, gender, last_name AS surname
    FROM     person JOIN details
                      ON person.person_id = details.person_id
    WHERE    age >= ${min_age} AND surname <> ${except_surname}
    ORDER BY surname DESC
  } as selected_people;

  // clean up when done
  finalize(all_people);
  finalize(selected_people);
```

### Looping through query results

The following example loops through the results of the queries above. In each loop iteration, a variable `person` is declared and initialized. It is an anonymous structure containing fields matching the selected columns.

```c
  foreach (person : all_people) {
    printf("%d %10s %10s\n", person.person_id, person.last_name,
           person.first_name);
  }

  foreach (person : selected_people) {
    printf("%10s %2d %s\n", person.surname, person.age, person.gender);
  }
```
