CC=gcc
CFLAGS=
CPPFLAGS=$(CFLAGS)
LDFLAGS=`allegro-config --libs` -lstdc++
ALL = fbp f map pv rle rng

all: ${ALL}

fbp: fbp.o yj1.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $? 
f: f.o yj1.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $? 
map: map.o yj1.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $? 
pv: pv.o yj1.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $? 
rle: rleori.o yj1.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $? 
rng: rnggif.o yj1.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $? 
.c.o:
	$(CC) $(CFLAGS) $(LDFLAGS) -c -o $@ $<
.cpp.o:
	$(CC) $(CPPFLAGS) $(LDFLAGS) -c -o $@ $<

clean:
	rm -rf *.o $(ALL)
