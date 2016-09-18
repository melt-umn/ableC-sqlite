#!/bin/bash
set -e

# This script shows the steps in compiling an extended C program (.xc)
# down to C via an extended instance of ableC and then using GCC to
# compile the generated C code to an executable.
# Of course, if the use of 'cut' below fails for you, then just run
# the commands individually by hand.

cmd="java -jar ../artifact/ableC.jar $1 -I ../include"
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
elif [ -f ../sqlite/sqlite3.c ]; then
	CC=gcc make ../sqlite/sqlite3.o
	link_sqlite3="../sqlite/sqlite3.o"
else
	echo "ERROR: sqlite3 library not found" >&2
	exit 255
fi

cmd="gcc -lpthread -ldl ${link_sqlite3} ${cfile} -o ${basefilename}"
echo $cmd
$cmd

