CC=gcc

all: cut mak

.c.o:
	$(CC) -c $<

cut: cut.o
	$(CC) $^ -o $@

mak: mak.o
	$(CC) $^ -o $@

	
