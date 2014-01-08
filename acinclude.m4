

# AC_PROG_FC_MOD
# By Michael R Nolta
# ---------------
AC_DEFUN([AC_PROG_FC_UPPERCASE_MOD],
[
AC_LANG_PUSH(Fortran)
AC_MSG_CHECKING([if Fortran 90 compiler capitalizes .mod filenames])
		    cat <<EOF >conftest.f90
		      module conftest
		      end module conftest
EOF
ac_try='${FC} ${FCFLAGS} conftest.f90 >&AS_MESSAGE_LOG_FD'
AC_TRY_EVAL(ac_try)
if test -f CONFTEST.mod ; then
   ac_cv_prog_f90_uppercase_mod=yes
   rm -f CONFTEST.mod
else
   ac_cv_prog_f90_uppercase_mod=no
fi
AC_MSG_RESULT($ac_cv_prog_f90_uppercase_mod)
#rm -f conftest*
AC_LANG_POP(Fortran)
])
