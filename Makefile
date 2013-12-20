
CC?=gcc
FC=gfortran
CFLAGS?= -I include/ -I /usr/include $(NETCDF)
FFLAGS?= -I include/ -I /usr/include $(NETCDF)
LDFLAGS?= -lnetcdf -L lib/ -lsimpledataio



.PHONY: all lib cuda fortran

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

test/test_f95.o: test/test.f95 simpledataio_f95.o
	$(FC) -c $< -o $@ $(FFLAGS) 

libsimpledataiof.a: simpledataio_f95.o
	mkdir -p lib
	ar cr lib/$@ $<
	ranlib lib/$@

libf: libsimpledataiof.a

testprog_fortran: test/test_f95.o  lib libf
	$(FC) -o $@ $<   -lsimpledataiof $(LDFLAGS)

simpledataio_f95.o: src/simpledataio.f95
	$(FC) -c $< -o $@ $(FFLAGS)
	mv simpledataio.mod include/.
	
fortran: testprog_fortran
	./testprog_fortran

clean: 
	rm -f testprog testprog_cuda simpledataio.o  testfile.cdf testprog_fortran test.cdf

distclean: clean
	rm -f include/simpledataio.mod
	rm -f lib/libsimpledataio.a
	rm -f lib/libsimpledataiof.a


commit: distclean
	git commit -av

push: commit
	git push




