# SQLite 3

This directory contains the SQLite source code, version 3.14.2.  It
came from the "amalgamation" zip file here:
https://www.sqlite.org/2016/sqlite-amalgamation-3140200.zip


To compile SQLite use the `-lpthread` for thread-safe code, and the
`-ldl` to enable dynamic loading.  To experiment with SQLite, it is
easiest to use it as an interactive application.  To create this,
compile it as follows:
```
gcc shell.c sqlite3.c -lpthread -ldl
```

SQLite is freely available as it is the public domain.  See
https://www.sqlite.org/copyright.html


