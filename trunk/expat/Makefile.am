# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE			= bigloo-expat
SUBPACKAGE		= bexpat

EXTRA_LIBRARIES		= libbexpat-@bigloo_revision@.a libbexpat_u-@bigloo_revision@.a 
libbexpat_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbexpat_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libbexpat_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

libbexpat_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbexpat_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libbexpat_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libbexpat_s-@bigloo_revision@.la
libbexpat_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
libbexpat_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
libbexpat_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

SCM		= expat-utils

USE_LIBS	= node common
LIBS		  = -lexpat @common_libs@

data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init

EXTRA_DIST  = test.scm test.sch expat.m4 $(SUBPACKAGE).init

bin_PROGRAMS	= driver$(EXEEXT) @xml2bigloo_target@
driver_SOURCES	= driver.scm
driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) $(SUBPACKAGE).heap driver.o
driver_LDADD	= driver.o $(TOOL_LIBS)

CLEANFILES	= $(CLEANFILES_COMMON) driver.scm
DEFS		= $(DEFS_COMMON)
DEFS_SRC	= expat

EXTRA_PROGRAMS	= xml2bigloo$(EXEEXT)

#======================================================================
# xml2bigloo

xml2bigloo_SOURCES	= xml2bigloo.scm
xml2bigloo_LDADD	= xml2bigloo.o  $(TOOL_LIBS)

xml2bigloo_DEPENDENCIES = xml2bigloo.o lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) \
	 $(SUBPACKAGE).heap

