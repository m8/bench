CC=gcc
CFLAGS=-std=gnu99 -Wall -O3

all: gups gupstoy
	$(CC) $(CFLAGS) -o gups gups.c -fopenmp
	$(CC) $(CFLAGS) -o gupstoy gupstoy.c -fopenmp

clean:
	rm -rf gups gupstoy *.o