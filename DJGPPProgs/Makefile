CFLAGS=-g -O2
CPPFLAGS=$(CFLAGS)
LDFLAGS=`allegro-config --libs`
ALL = fbp f map pv rle rng deyj1

all: ${ALL}

deyj1: deyj1.o yj1.o
	$(CXX) -o $@ $?

fbp: fbp.o yj1.o
	$(CXX) $(LDFLAGS) -o $@ $?
f: f.o yj1.o
	$(CXX) $(LDFLAGS) -o $@ $?
map: map.o yj1.o
	$(CXX) $(LDFLAGS) -o $@ $?
pv: pv.o yj1.o
	$(CXX) $(LDFLAGS) -o $@ $?
rle: rleori.o yj1.o
	$(CXX) $(LDFLAGS) -o $@ $?
rng: rnggif.o yj1.o
	$(CXX) $(LDFLAGS) -o $@ $?

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<
.cpp.o:
	$(CXX) $(CPPFLAGS) -c -o $@ $<

clean:
	rm -rf *.o $(ALL)
