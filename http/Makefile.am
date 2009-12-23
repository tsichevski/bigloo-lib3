# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE=bigloo-http
SUBPACKAGE=http

EXTRA_LIBRARIES		= libhttp.a libhttp_u.a 
libhttp_a_SOURCES	= $(lib_SOURCES)
libhttp_a_LIBADD	= $(lib_OBJECTS)
libhttp_a_DEPENDENCIES = $(lib_OBJECTS)

libhttp_u_a_SOURCES	= $(lib_SOURCES)
libhttp_u_a_LIBADD	= $(lib_OBJECTS)
libhttp_u_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libhttp_s.la
libhttp_s_la_SOURCES	= $(lib_SOURCES)
libhttp_s_la_LIBADD	= $(lib_LTOBJECTS)
libhttp_s_la_DEPENDENCIES = $(lib_LTOBJECTS)

SCM		= http html-form-adapter http-cgi http-parse http-response
EXTRA_SCM	= http-charset
EXTRA_SCM_F	= @http_charset_target@

USE_LIBS	= common
LIBS		= @common_libs@

EXTRA_DIST	= test.scm $(SUBPACKAGE).init Makefile.rules bigloo-http.spec.in
data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init

bin_PROGRAMS	= driver
driver_SOURCES	= driver.scm
driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) $(SUBPACKAGE).heap driver.o
driver_LDADD	= driver.o $(TOOL_LIBS)

CLEANFILES	= $(CLEANFILES_COMMON) driver.scm
DEFS		= $(DEFS_COMMON)
