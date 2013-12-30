ifdef PARALLEL
CC?=mpicc
FC=mpif90
CFLAGS?= -I include/ -I /usr/include $(NETCDF) -DPARALLEL -I /usr/lib/openmpi/include/ 
FFLAGS?= -I include/ -I /usr/include $(NETCDF) -DPARALLEL -I /usr/lib/openmpi/include/ -cpp
LDFLAGS?= -lnetcdf -L lib/ -lsimpledataio -lhdf5
LDFFLAGS?= -lsimpledataiof -lnetcdff -lhdf5 -lnetcdf
else
CC?=gcc
FC=gfortran
CFLAGS?= -I include/ -I /usr/include $(NETCDF)
FFLAGS?= -I include/ -I /usr/include $(NETCDF)
LDFLAGS?= -lnetcdf -L lib/ -lsimpledataio
LDFFLAGS?= -lsimpledataiof -lnetcdff
endif



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

test/test_parallel_f95.o: test/test_parallel.f95 simpledataio_f95.o simpledataio_write_f95.o
	$(FC) -c $< -o $@ $(FFLAGS) 

test/test_f95.o: test/test.f95 simpledataio_f95.o simpledataio_write_f95.o
	$(FC) -c $< -o $@ $(FFLAGS) 

libsimpledataiof.a: simpledataio_f95.o simpledataio_write_f95.o
	mkdir -p lib
	ar cr lib/$@ $< simpledataio_write_f95.o
	ranlib lib/$@

libf: libsimpledataiof.a

testprog_fortran: test/test_f95.o  lib libf
	$(FC) -o $@ $<   $(LDFFLAGS) $(LDFLAGS)

testprog_fortran_parallel: test/test_parallel_f95.o  lib libf
	$(FC) -o $@ $<   $(LDFFLAGS) $(LDFLAGS)

simpledataio_f95.o: src/simpledataio.f95
	$(FC) -c $< -o $@ $(FFLAGS)
	mv simpledataio.mod include/.

src/simpledataio_write.f95: src/generate_simpledataio_write.rb
	ruby $< > $@

simpledataio_write_f95.o: src/simpledataio_write.f95
	$(FC) -c $< -o $@ $(FFLAGS)
	mv simpledataio_write.mod include/.
	
fortran: testprog_fortran
	./testprog_fortran

parallel_fortran: testprog_fortran_parallel
	mpirun -np 2 testprog_fortran_parallel

clean: 
	rm -f testprog testprog_cuda simpledataio.o  testfile.cdf testprog_fortran test.cdf  simpledataio_f95.o testprog_fortran_parallel test_parallel.cdf simpledataio_write_f95.o

distclean: clean
	rm -f include/simpledataio.mod
	rm -f include/simpledataio_write.mod
	rm -f lib/libsimpledataio.a
	rm -f lib/libsimpledataiof.a


commit: distclean
	git commit -av

push: commit
	git push




