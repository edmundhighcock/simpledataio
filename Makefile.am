

ACLOCAL_AMFLAGS=-I m4
lib_LTLIBRARIES = libsimpledataio.la libsimpledataiof.la
include_HEADERS = include/simpledataio.h include/simpledataio.mod include/simpledataio_write.mod
libsimpledataio_la_SOURCES = src/simpledataio.c 
libsimpledataiof_la_SOURCES = src/simpledataiof.F95 src/simpledataio_write.f95
#libsimpledataiof_la_SOURCES = src/simpledataio.f95

bin_PROGRAMS=$(top_builddir)/test/testprog 
bin_PROGRAMS+=$(top_builddir)/test/testprog_fortran

__top_builddir__test_testprog_SOURCES=test/test.c
__top_builddir__test_testprog_LDADD=libsimpledataio.la
__top_builddir__test_testprog_fortran_SOURCES=test/testf.f95
__top_builddir__test_testprog_fortran_LDADD=libsimpledataio.la libsimpledataiof.la

AM_FCFLAGS=-I/usr/include

if PARALLEL
AM_CPPFLAGS=-DPARALLEL
bin_PROGRAMS+=$(top_builddir)/test/testprog_fortran_parallel

__top_builddir__test_testprog_fortran_parallel_SOURCES=test/test_parallelf.f95
__top_builddir__test_testprog_fortran_parallel_LDADD=libsimpledataio.la libsimpledataiof.la
__top_builddir__test_testprog_fortran_parallel_LDFLAGS=-lmpi -lmpi_f90
endif

CLEANFILES=test.cdf testfile.cdf test_parallel.cdf simpledataio.mod simpledataio_write.mod include/simpledataio_write.mod include/simpledataio.mod


TESTS = test/testprog test/testprog_fortran test/test_parallel.sh
TESTS_ENVIRONMENT = 
#TEST_EXTENSIONS = .sh
#SH_LOG_COMPILER = bash
#LOG_COMPILER = sh

include/simpledataio.mod: simpledataiof.lo
	cp simpledataio.mod include/.
include/simpledataio_write.mod: simpledataio_write.lo
	cp simpledataio_write.mod include/.

src/simpledataio_write.f95: src/generate_simpledataio_write.rb
	env ruby $< > $@

