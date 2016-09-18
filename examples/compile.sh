#!/bin/bash

# This script shows the steps in compiling an extended C program (.xc)
# down to C via an extended instance of ableC and then using GCC to
# compile the generated C code to an executable.
# Of course, if the use of 'cut' below fails for you, then just run
# the commands individually by hand.

java -jar ../artifact/ableC.jar $1 -I ../include

# extract the base filename, everything before the dot (.)

filename=$1
extension="${filename##*.}"
filename_withoutpath=$(basename $filename)
basefilename="${filename_withoutpath%.*}"

cfile="${basefilename}.pp_out.c"
#cfile="${basefilename}.c"

CC=gcc make ../sqlite/sqlite3.o

gcc -lpthread -ldl ../sqlite/sqlite3.o ${cfile} -o ${basefilename}
