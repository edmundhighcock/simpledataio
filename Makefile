
CC?=gcc
CFLAGS= -I include/ -I /usr/include $(NETCDF)
LDFLAGS= -lnetcdf -L lib/ -lsimpledataio

.PHONY: all lib

all: lib

lib: libsimpledataio.a

libsimpledataio.a: simpledataio.o
	mkdir -p lib
	ar cr lib/$@ $<
	ranlib lib/$@

test: testprog 
	./testprog

simpledataio.o: src/simpledataio.c include/simpledataio.h
	$(CC) -c src/simpledataio.c -o  $@  $(CFLAGS)

testprog: lib
	$(CC)  test/test.c -o $@  $(CFLAGS) $(LDFLAGS) 

cuda: testprog_cuda 
	./testprog_cuda

testprog_cuda: testprog_cuda.o lib
	$(CC)  -o $@ $< $(CFLAGS) $(LDFLAGS) 

testprog_cuda.o: test/test.cu simpledataio.o 
	$(CC)  -c $< -o $@  $(CFLAGS) $(LDFLAGS)

clean: 
	rm -f testprog testprog_cuda simpledataio.o  testfile.cdf

distclean: clean
	rm -f lib/libsimpledataio.a


commit: distclean
	git commit -av

push: commit
	git push




