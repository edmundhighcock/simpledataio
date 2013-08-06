
CC?=gcc
CFLAGS= -I include/ -I /usr/include $(NETCDF)
LDFLAGS= -lnetcdf

.PHONY: all

all: testprog 
	./testprog

simpledataio.o: src/simpledataio.c include/simpledataio.h
	$(CC) -c src/simpledataio.c -o  $@  $(CFLAGS)

testprog: simpledataio.o
	$(CC)  test/test.c -o $@ $< $(CFLAGS) $(LDFLAGS)

cuda: testprog_cuda 
	./testprog_cuda

testprog_cuda: testprog_cuda.o simpledataio.o
	$(CC)  -o $@ $< simpledataio.o $(CFLAGS) $(LDFLAGS)

testprog_cuda.o: test/test.cu simpledataio.o 
	$(CC)  -c $< -o $@  $(CFLAGS) $(LDFLAGS)

clean: 
	rm testprog
	rm simpledataio.o
	rm testfile.cdf


