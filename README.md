# Introduction
This ableC extension provides language constructs useful for working with
sqlite3 databases.

# Quick Start

## Set up environment
The build scripts assume that the [ableC](https://github.com/melt-umn/ableC)
source exists at `../../ableC/` relative to here. The prerequisites for building
this extension, particularly that [Silver](http://melt.cs.umn.edu/silver/doc/install-guide/)
be installed, are identical to those of building ableC.

## Build the extended ableC
Also see [artifact/README.md](artifact/README.md).

```
cd artifact/
./build.sh
```

This will produce `ableC.jar`.

## Use the extended ableC
Also see [examples/README.md](examples/README.md).

```
cd examples/
./compile.sh example1-print-person-table.xc

```

