# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE			= bigloo-gd

SUBPACKAGE		= bgd

EXTRA_LIBRARIES		= libbgd-@bigloo_revision@.a libbgd_u-@bigloo_revision@.a 
libbgd_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbgd_@bigloo_revision@_a_LIBADD		= $(lib_OBJECTS)
libbgd_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

libbgd_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbgd_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libbgd_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libbgd_s-@bigloo_revision@.la
libbgd_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
libbgd_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
libbgd_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

DEFS_SRC        = gd

CGEN_LOCAL_OPTIONS = -e "(define gd-targets '(@gd_targets@))"

$(DEFS_SRC:%=%.c): gd.sch

bin_PROGRAMS	= driver
LIBS		= @gd_libs@ @common_libs@
INCLUDES	= @gd_includes@

USE_LIBS	= common

data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init

EXTRA_DIST = test.scm $(SUBPACKAGE).init gd.sch gd.m4	\
	bigloo-gd.spec.in

driver_SOURCES	= driver.scm
driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) \
	$(SUBPACKAGE).heap driver.o

driver_LDADD	= driver.o $(TOOL_LIBS)

CLEANFILES	= $(CLEANFILES_COMMON) driver.scm
DEFS		= $(DEFS_COMMON)
