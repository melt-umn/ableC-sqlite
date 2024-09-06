#!/bin/bash
set -e

# This script shows the steps in compiling an extended C program (.xc)
# down to C via an extended instance of ableC and then using GCC to
# compile the generated C code to an executable.
# Of course, if the use of 'cut' below fails for you, then just run
# the commands individually by hand.

# TODO: better handle dependency on cwd
top_level=".."
if [ -d ../../artifact ]; then
	top_level="../.."
elif [ -d ../../../artifact ]; then
	top_level="../../.."
fi

cmd="java -jar $top_level/artifact/ableC.jar $1 -I $top_level/include"
echo $cmd
$cmd

# extract the base filename, everything before the dot (.)

filename=$1
extension="${filename##*.}"
filename_withoutpath=$(basename $filename)
basefilename="${filename_withoutpath%.*}"

cfile="${basefilename}.pp_out.c"
#cfile="${basefilename}.c"

if ldconfig -p | grep -q libsqlite3; then
	link_sqlite3="-lsqlite3"
elif [ -f $top_level/sqlite/sqlite3.c ]; then
	CC=gcc make $top_level/sqlite/sqlite3.o
	link_sqlite3="$top_level/sqlite/sqlite3.o"
else
	echo "ERROR: sqlite3 library not found" >&2
	exit 255
fi

cmd="gcc ${link_sqlite3} ${cfile} -o ${basefilename} -lpthread -ldl"
echo $cmd
$cmd

