
CC=gcc

.PHONY: all

all: testprog 
	./testprog

simpledataio.o: 
	$(CC) -c src/simpledataio.c -o  $@

testprog: simpledataio.o
	$(CC)  test/test.c -o $@ $<


clean: 
	rm testprog
	rm simpledataio.o

