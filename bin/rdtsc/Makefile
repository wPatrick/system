CC=gcc
CFLAGS=-W -Wall
DEPS =
OBJ = rdtsc.o 

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

rdtsc: $(OBJ)
	gcc -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o rdtsc
