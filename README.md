# Introduction
This ableC extension provides language constructs useful for working with
sqlite3 databases.

# Quick Start

## Set up environment
The build scripts assume that the [ableC](https://github.com/melt-umn/ableC)
source exists at `../../ableC/` relative to this directory. A reasonable location to
clone this repository into might be `ableC/extensions/`. The prerequisites for building
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

