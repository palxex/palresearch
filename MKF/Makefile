CC=gcc
RM=rm
TARGETS=cut mak

all: $(TARGETS)

clean: 
	$(RM) *.o $(TARGETS)

.c.o:
	$(CC) -c $<

cut: cut.o
	$(CC) $^ -o $@

mak: mak.o
	$(CC) $^ -o $@

	
