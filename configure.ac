AC_CONFIG_MACRO_DIR([m4])

AC_INIT([bigloo-lib3], [0.11])
AC_CONFIG_SRCDIR([Makefile.rules])
AM_INIT_AUTOMAKE

dnl FIXME: these two declarations should appear in bgtk/bgtk.m4 and
dnl gl/gl.m4 if aclocal would parse process these files

dnl AM_PATH_GTK
dnl AM_PATH_GTKGL

m4_include([bigloo-lib.m4])
m4_include([common/common.m4])
m4_include([xml/xml.m4])
m4_include([gd/gd.m4])
m4_include([expat/expat.m4])
m4_include([rdbms/rdbms.m4])
# bgtk/bgtk.m4
# gl/gl.m4
m4_include([ldap/ldap.m4])

AM_PROG_LIBTOOL

AC_OUTPUT([					\
  Makefile					\
  bigloo-lib.spec				\
  common/Makefile				\
  common/common.init		\
  expat/Makefile				\
  xml/Makefile					\
  xml/config.texi				\
  xml/xml.init					\
  ldap/Makefile					\
  gd/Makefile					  \
  node/Makefile					\
  http/Makefile					\
  rdbms/Makefile				\
  rdbms/rdbms.init			\
  docs/Makefile					\
  docs/bigloo-lib-version.texi			\
])
#  bgtk/Makefile					\
#  bgtk/bgtk.init				\
#  gl/Makefile					\
#  gl/gl.init					\
