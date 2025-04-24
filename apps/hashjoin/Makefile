CC=gcc
CFLAGS=-std=gnu99 -Wall -O3
LDFLAGS=-lm -lnuma

all:
	$(CC) $(CFLAGS) -fopenmp -o hashjoin hashjoin.c murmurhash.c $(LDFLAGS)
	$(CC) $(CFLAGS) -fopenmp -o hashjoin2 hashjoin_2.c murmurhash.c $(LDFLAGS)

clean:
	rm -f hashjoin hashjoin2
	rm -f *.o
	rm -f *.a