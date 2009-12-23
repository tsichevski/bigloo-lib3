# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

PACKAGE			= bigloo-ldap
SUBPACKAGE			= bldap

EXTRA_LIBRARIES		= libbldap-@bigloo_revision@.a libbldap_u-@bigloo_revision@.a 
libbldap_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbldap_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libbldap_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

libbldap_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libbldap_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libbldap_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libbldap_s-@bigloo_revision@.la
libbldap_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
libbldap_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
libbldap_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

CGEN_LOCAL_OPTIONS 	= \
	-e '(define have-cache-functions? (string=? "@ldap_have_cache_funcs@" "yes"))'

SCM		= ldap-utils cache-node ldap-node ldap-schema
DEFS_SRC	= ldap

LIBS		= @ldap_libs@ @common_libs@

USE_LIBS	= node common

data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init ldap-t.sch
include_HEADERS	= ldap-compat.h

EXTRA_DIST	= test.scm $(SUBPACKAGE).init ldap-t.sch \
	ldap.m4 Makefile.rules

bin_PROGRAMS	= driver ldapscheme2bigloo
driver_SOURCES	= driver.scm
driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) \
	$(SUBPACKAGE).heap driver.o
driver_LDADD	= driver.o $(TOOL_LIBS)

CLEANFILES	= $(CLEANFILES_COMMON) driver.scm
DEFS		= $(DEFS_COMMON)

#======================================================================
# ldapscheme2bigloo

ldapscheme2bigloo_SOURCES	= ldapscheme2bigloo.scm
ldapscheme2bigloo_LDADD	= ldapscheme2bigloo.o  $(TOOL_LIBS)

ldapscheme2bigloo_DEPENDENCIES = ldapscheme2bigloo.o \
	lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) $(SUBPACKAGE).heap
