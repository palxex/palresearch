CC=gcc -ggdb
MINGWGCC=x86_64-w64-mingw32-gcc -static
RM=rm
CUTEXE=CUT.EXE
MAKEXE=MAK.EXE
CUT=$(CUTEXE)
MAK=$(MAKEXE)
SYS := $(shell gcc -dumpmachine)
ifneq (, $(findstring linux, $(SYS)))
	CUT=cut
	MAK=mak
else ifneq (, $(findstring darwin, $(SYS)))
	CC=clang -g
	CUT=cut
	MAK=mak
#else ifneq(, $(findstring mingw, $(SYS)))
 # Do mingw things
#else ifneq(, $(findstring cygwin, $(SYS)))
 # Do cygwin things
else
 # Do things for others
endif
TARGETS=$(CUT) $(MAK)

all: $(TARGETS)

mingw: $(CUTEXE) $(MAKEXE)

clean:
	$(RM) *.o $(TARGETS)

.c.o:
	$(CC) -c $<

.C.o:
	$(CC) -c $<

$(CUT): CUT.o
	$(CC) $^ -o $@

$(MAK): MAK.o
	$(CC) $^ -o $@

$(CUTEXE): CUT.c
	$(MINGWGCC) $^ -o $@

$(MAKEXE): MAK.c
	$(MINGWGCC) $^ -o $@
