# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE			= bigloo-xml
SUBPACKAGE		= bxml

EXTRA_LIBRARIES		= libbxml-@bigloo_revision@.a libbxml_u-@bigloo_revision@.a
libbxml_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbxml_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libbxml_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

libbxml_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbxml_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libbxml_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libbxml_s-@bigloo_revision@.la
libbxml_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
libbxml_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
libbxml_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

SCM		= xmlutils
DEFS_SRC	= xmlio xmlsave xmlmemory xtree xmlregexp xpath xparser \
	xmlglobals encoding

C		= 
# xmlc

LIBS		= @bigloo_xml_libs@ @common_libs@

EXTRA_DEFS	= xslt xsltutils transform
EXTRA_DEFS_F	= @xslt_target@

bin_PROGRAMS	= driver$(EXEEXT)
EXTRA_PROGRAMS	= 
LIB_PEM_HOME	= 
USE_LIBS	= common
INCLUDES	= @bigloo_xml_cflags@

data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init
pkgdata_DATA	= $(XSL:%=%.xsl)
include_HEADERS	=

bin_SCRIPTS	= 
# db2word

EXTRA_DIST = test.scm test.sch

CONFIG_CLEAN_FILES = bigloo-xml.spec config.guess config.sub configure \
	COPYING INSTALL install-sh ltmain.sh missing aclocal.m4 bxml.init \
	config.texi

info_TEXINFOS	= bigloo-xml.texi
bigloo_xml_TEXINFOS = readme.texi authors.texi intro.texi \
	getstarted.texi advanced.texi reference.texi xpath.texi \
	xmlutils.texi encoding.texi xparser.texi

bigloo-xml.info: $(bigloo_xml_TEXINFOS)

#======================================================================
driver_SOURCES	= driver.defs

driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) \
	$(SUBPACKAGE).heap driver.o

driver_LDADD	= driver.o $(TOOL_LIBS)

#bigloo-xml.o: bigloo-xml.sch

CLEANFILES	= $(CLEANFILES_COMMON)
DEFS		= $(DEFS_COMMON)

README: readme.texi
	rm -f foo.texi
	for file in $< ; do		\
	  echo "@include $$file" >> foo.texi ;	\
	done
	makeinfo -o - foo.texi | tail -n +2 > $@
	rm -f foo.texi
