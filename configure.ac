#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([simpledataio], [VERSION], [BUG-REPORT-ADDRESS])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([])
LT_INIT
AC_CONFIG_SRCDIR([src/simpledataio.c])

# Checks for programs.
AC_PROG_CC
AC_PROG_FC
#AC_PROG_FPP
#AC_PROG_RANLIB
#AC_PROG_INSTALL

# Checks for libraries.
AC_CHECK_LIB([hdf5], [H5open])
AC_CHECK_LIB([netcdf], [nc_create])
AC_CHECK_LIB([netcdff], [nc_create])

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h])
AC_CHECK_HEADERS([netcdf.h], [], [echo "netcdf.h not found... suggest defining CFLAGS='-I/location/of/netcdf/include'" && exit])
#AC_CHECK_HEADERS([netcdf.mod])
#AC_CHECK_HEADERS([simpledataio.h])

# Checks for typedefs, structures, and compiler characteristics.
#AC_TYPE_SIZE_T

# Checks for library functions.
#AC_FUNC_MALLOC

# Check whether to build it with support for parallel netcdf IO
AC_MSG_CHECKING([whether to build using parallel netcdf])
AC_ARG_ENABLE([parallel],
              [AS_HELP_STRING([--enable-parallel],
                              [build with parallel netcdf (requires netcdf4, hdf5 and mpi)])],
							[enable_parallel=yes], [enable_parallel=no])
AC_MSG_RESULT([$enable_parallel])
AM_CONDITIONAL(PARALLEL, [test "$enable_parallel" = yes])

if test "$enable_parallel" = yes; then
  AC_CHECK_HEADERS([mpi.h], [], [echo "mpi.h not found... suggest defining CFLAGS='-I/location/of/mpi/include'" && exit])
fi

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
