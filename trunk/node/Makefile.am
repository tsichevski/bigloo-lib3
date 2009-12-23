# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE=bigloo-node
SUBPACKAGE=node

EXTRA_LIBRARIES		= libnode-@bigloo_revision@.a libnode_u-@bigloo_revision@.a 
libnode_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libnode_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libnode_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

libnode_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libnode_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libnode_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libnode_s-@bigloo_revision@.la
libnode_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
libnode_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
libnode_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

SCM		= node dl-node tree-node sgml-node html-node
USE_LIBS	= common
LIBS	= @common_libs@

data_DATA	= $(SUBPACKAGE).heap

EXTRA_DIST	= test.scm Makefile.rules bigloo-node.spec.in

bin_PROGRAMS	= driver$(EXEEXT)
driver_SOURCES	= driver.scm
driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) $(SUBPACKAGE).heap driver.o
driver_LDADD	= driver.o $(TOOL_LIBS)

CLEANFILES	= $(CLEANFILES_COMMON) driver.scm
DEFS		= $(DEFS_COMMON)
