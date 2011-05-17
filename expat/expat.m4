dnl ***************************************************
dnl configure expat XML parser
dnl ***************************************************
AC_CHECK_HEADERS(expat.h)
if test "$ac_cv_header_expat_h" = yes ; then
  expat=expat
fi
AC_SUBST(expat)

