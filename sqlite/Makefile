CC = gcc
LIBS = -lpthread -ldl

sqlite3 : shell.o sqlite3.o
	$(CC) $(LIBS) -o $@ $^

