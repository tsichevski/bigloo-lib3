# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE			= bigloo-rdbms
SUBPACKAGE		= rdbms

EXTRA_LIBRARIES		= librdbms-@bigloo_revision@.a librdbms_u-@bigloo_revision@.a 
librdbms_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
librdbms_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
librdbms_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

librdbms_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
librdbms_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
librdbms_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= librdbms_s-@bigloo_revision@.la
librdbms_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
librdbms_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
librdbms_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

SCM		= rdbms
EXTRA_DEFS	= mysql oracle sqlite sqlite3 pgsql
EXTRA_DEFS_F	= @mysql@ @oracle@ @sqlite@ @pgsql@


LIBS		= @mysql_libs@ @mysql_rpath@ @oracle_libs@ @oracle_rpath@ \
		@sqlite_libs@ @pgsql_libs@ @pgsql_rpath@ \
		@common_libs@

USE_LIBS	= common

INCLUDES=@oracle_cflags@ @mysql_cflags@ @pgsql_cflags@

data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init
# include_HEADERS	= rdbms.h

EXTRA_DIST = test.scm $(SUBPACKAGE).init adhoc.scm rdbms.m4 test.sch

bin_PROGRAMS	= driver
driver_SOURCES	= driver.scm
driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) \
		$(SUBPACKAGE).heap driver.o

driver_LDADD	= driver.o $(TOOL_LIBS)

CLEANFILES	= $(CLEANFILES_COMMON) driver.scm
DEFS		= $(DEFS_COMMON)

adhoc: adhoc.scm
	bigloo -o $@ $<
