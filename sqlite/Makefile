CC = gcc
LIBS = -pthread -ldl

sqlite3 : shell.o sqlite3.o
	$(CC) -o $@ $^ $(LIBS)

