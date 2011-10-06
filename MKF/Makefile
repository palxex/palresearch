CC=gcc
RM=rm
TARGETS=CUT.EXE MAK.EXE

all: $(TARGETS)

clean: 
	$(RM) *.o $(TARGETS)

.c.o:
	$(CC) -c $<

.C.o:
	$(CC) -c $<

CUT.EXE: CUT.o
	$(CC) $^ -o $@

MAK.EXE: MAK.o
	$(CC) $^ -o $@

	
