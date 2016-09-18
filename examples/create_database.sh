#!/bin/bash
set -eu

main() {
	sqlite3=`find_sqlite3`

	# don't worry if test.db is already populated,
	# running on a pre-existing database will just print an error and exit
	echo """
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
	""" | $sqlite3 "test.db"
}

# find the sqlite3 binary
# use binary in path if it exists, otherwise build from ../sqlite3/
find_sqlite3() {
	if which sqlite3 > /dev/null; then
		sqlite3=`which sqlite3`
	else
		if [ ! -f ../sqlite/sqlite3.c ]; then
			echo "ERROR: ../sqlite3/sqlite3.c not found" >&2
			exit 255
		fi
		make -sC ../sqlite/
		sqlite3="../sqlite/sqlite3"
	fi
	echo $sqlite3
}

main

