#!/bin/bash
set -eu

main() {
	sqlite3=`find_sqlite3`

	# don't worry if test.db is already populated,
	# running on a pre-existing database will just print an error and exit
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
	" | $sqlite3 "test.db"
}

# find the sqlite3 binary
# use binary in path if it exists, otherwise build from ../sqlite3/
find_sqlite3() {
	# TODO: better handle dependency on cwd
	top_level=".."
	if [ -d ../../artifact ]; then
		top_level="../.."
	elif [ -d ../../../artifact ]; then
		top_level="../../.."
	fi

	if which sqlite3 > /dev/null; then
		sqlite3=`which sqlite3`
	elif [ -f $top_level/sqlite/sqlite3.c ]; then
		make -sC $top_level/sqlite/
		sqlite3="$top_level/sqlite/sqlite3"
	else
		echo "ERROR: $top_level/sqlite3/sqlite3.c not found" >&2
		exit 255
	fi
	echo $sqlite3
}

main

