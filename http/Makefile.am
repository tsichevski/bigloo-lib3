# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE=bigloo-http
SUBPACKAGE=http

EXTRA_LIBRARIES		= libhttp-@bigloo_revision@.a libhttp_u-@bigloo_revision@.a 
libhttp_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libhttp_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libhttp_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

libhttp_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libhttp_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libhttp_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libhttp_s-@bigloo_revision@.la
libhttp_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
libhttp_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
libhttp_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

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
