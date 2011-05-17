# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE			= bigloo-expat
SUBPACKAGE		= bexpat

EXTRA_LIBRARIES		= libbexpat.a libbexpat_u.a 
libbexpat_a_SOURCES	= $(lib_SOURCES)
libbexpat_a_LIBADD	= $(lib_OBJECTS)
libbexpat_a_DEPENDENCIES = $(lib_OBJECTS)

libbexpat_u_a_SOURCES	= $(lib_SOURCES)
libbexpat_u_a_LIBADD	= $(lib_OBJECTS)
libbexpat_u_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libbexpat_s.la
libbexpat_s_la_SOURCES	= $(lib_SOURCES)
libbexpat_s_la_LIBADD	= $(lib_LTOBJECTS)
libbexpat_s_la_DEPENDENCIES = $(lib_LTOBJECTS)

SCM		= expat-utils
DEFS_SRC	= expat

bin_PROGRAMS	= driver$(EXEEXT) @xml2bigloo_target@
EXTRA_PROGRAMS	= xml2bigloo$(EXEEXT)
LIBS		= -lexpat @common_libs@
USE_LIBS	= node common

data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init
include_HEADERS	=
# bexpat.h

EXTRA_DIST = test.scm test.sch expat.m4 $(SUBPACKAGE).init

#======================================================================
# xml2bigloo

xml2bigloo_SOURCES	= xml2bigloo.scm
xml2bigloo_LDADD	= xml2bigloo.o  $(TOOL_LIBS)

xml2bigloo_DEPENDENCIES = xml2bigloo.o lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) \
	 $(SUBPACKAGE).heap

driver_SOURCES	= driver.scm

driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) \
	$(SUBPACKAGE).heap driver.o

driver_LDADD	= driver.o $(TOOL_LIBS)

CLEANFILES	= $(CLEANFILES_COMMON) driver.scm
DEFS		= $(DEFS_COMMON)
