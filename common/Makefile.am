# -*-Makefile-*-

include $(top_srcdir)/Makefile.rules

# This name is used when compiling as separate package
PACKAGE			= bigloo-common

SUBPACKAGE		= common

CGEN_LOCAL_OPTIONS 	= \
	-e '(define have-syswait (string=? "@have_syswait@" "yes"))' \
	-e '(define have-strncasecmp (string=? "@have_strncasecmp@" "yes"))' \
	-e '(define curlversion "@curlversion@")' \
	-e '(define gcversion "@gcversion@")' \
	-e '(define enable-setenv (string=? "@enable_setenv@" "yes"))' \
	-e '(define enable-flock (string=? "@enable_flock@" "yes"))' \
	-e '(define bigloo-has-sleep? (string=? "@bigloo_implements_sleep@" "yes"))'

EXTRA_LIBRARIES		= libcommon-@bigloo_revision@.a libcommon_u-@bigloo_revision@.a
libcommon_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libcommon_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libcommon_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

libcommon_u_@bigloo_revision@_a_SOURCES	= $(lib_SOURCES)
libcommon_u_@bigloo_revision@_a_LIBADD	= $(lib_OBJECTS)
libcommon_u_@bigloo_revision@_a_DEPENDENCIES = $(lib_OBJECTS)

lib_LTLIBRARIES		= libcommon_s-@bigloo_revision@.la
libcommon_s_@bigloo_revision@_la_SOURCES	= $(lib_SOURCES)
libcommon_s_@bigloo_revision@_la_LIBADD	= $(lib_LTOBJECTS)
libcommon_s_@bigloo_revision@_la_DEPENDENCIES = $(lib_LTOBJECTS)

BOOT_SCM 	= misc srfi-1 string-lib
BOOT_C		= csrfi-13
SCM		= md5 srfi-1 string-lib misc char-hex apropos random \
		string-grammar-apply base64

EXTRA_SCM	= crypt mzcompat regex-output

EXTRA_DEFS	= iconv times regex gettext ipcs dl mmap	\
		readline history termios gdbm curl pthread gc	\
		socket

DEFS_SRC	= os time locale
C		= cmd5

EXTRA_SCM_F	= @crypt_target@ @mzcompat_target@ @regex_output_targets@

EXTRA_DEFS_F	= @iconv_target@ @times_target@				\
		@regex_target@ @gettext_target@				\
		@ipcs_target@ @dl_targets@ @mmap_target@		\
		@commandline_targets@ @gdbm_target@ @db_target@ @curl_target@	\
		@pthread_target@ @gc_target@ @socket_target@ 

bin_PROGRAMS	= cgen$(EXEEXT) driver$(EXEEXT) @bconv_target@ @afile_target@
EXTRA_PROGRAMS	= bconv$(EXEEXT) bigloo-lib-afile$(EXEEXT)

bin_SCRIPTS	= 
bigloo_lib_afile_SOURCES = afile.scm
cgen_SOURCES	= cgen.scm

# override default rules for the modules required to build cgen to
# avoid circular dependencies

misc.c: misc.scm
	$(bigloo) $(BIGLOO_OPTIMIZATION_FLAGS) -cgen $< -o $@

srfi-1.c: srfi-1.scm
	$(bigloo) $(BIGLOO_OPTIMIZATION_FLAGS) -cgen $< -o $@

string-lib.c: string-lib.scm
	$(bigloo) $(BIGLOO_OPTIMIZATION_FLAGS) -cgen $< -o $@

# bigloo-lib-afile and cgen are only targets build directly by bigloo,
# all other targets depend on existense of .afile

# Note: when the new automake makes `distcheck', it copies all sources
# as read-only. On the other side, Bigloo tryes to create intermediate
# files (*.c and *.o) in same directory as the source .scm files
# are. The only way I know at the moment to resolve the conflict is to
# copy or link the source files to the place where all output will be
# made. We also have to remove the copy in order to make distcheck
# happy (it check that no extra files are left in the build tree after
# this commands' execution)

bigloo-lib-afile$(EXEEXT): $(bigloo_lib_afile_SOURCES)
	if test -n "$(VPATH)"; then		\
	  ln -s $(VPATH)/$(bigloo_lib_afile_SOURCES) $(bigloo_lib_afile_SOURCES) ;	\
	fi ;					\
	$(bigloo) $(bigloo_lib_afile_SOURCES) -o $@
	if test -n "$(VPATH)"; then		\
	  rm $(bigloo_lib_afile_SOURCES) ;			\
	fi ;

# FIXME: currently we need to explicitly create intermediate C files
# since Bigloo (2.5c) always tries to write them to the same catalog
# where source files are located. Since automake-1.6 source catalogs
# are read-only during 'make distcheck'
cgen.c: cgen.scm
	$(bigloo) $(BIGLOO_OPTIMIZATION_FLAGS) -cgen $< -o $@

cgen$(EXEEXT): cgen.c $(BOOT:%=%.o)
	$(bigloo) $< $(BOOT:%=%.o) -o $@

$(DEFS_SRC:%=%.scm) $(EXTRA_DEFS_F:%=%.scm): cgen$(EXEEXT)

.afile: bigloo-lib-afile$(EXEEXT) cgen$(EXEEXT)

data_DATA	= $(SUBPACKAGE).heap $(SUBPACKAGE).init $(SUBPACKAGE).sch

include_HEADERS	= md5.h common.h

LIBS		= @common_libs@

EXTRA_DIST = test.scm test.sch $(SUBPACKAGE).sch $(cgen_SOURCES)	\
	$(bigloo_lib_afile_SOURCES) common.m4 bigloo-common.spec.in

driver_SOURCES	= driver.scm
driver_DEPENDENCIES = lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) $(SUBPACKAGE).heap driver.o
driver_LDADD	= driver.o $(TOOL_LIBS)
DEFS		= $(DEFS_COMMON)
#======================================================================
# bconv

bconv_SOURCES	= bconv.scm
bconv_LDADD	= bconv.o  $(TOOL_LIBS)

bconv_DEPENDENCIES = bconv.o lib$(SUBPACKAGE)$(TOOL_LIB_SUFFIX) $(SUBPACKAGE).heap

# Note: this is a copy of $(CLEANFILES_COMMON), all boot files excluded
CLEANFILES	= *.a *.la .afile os.scm time.scm locale.scm iconv.scm times.scm \
	regex.scm gettext.scm dl.scm mmap.scm gdbm.scm db.scm curl.scm \
	ipcs.scm termios.scm readline.scm history.scm socket.scm pthread.scm \
	$(ALL_ALL_SCM:%=%.c) $(bin_PROGRAMS) \
	cgen driver bconv bigloo-lib-afile \
	evprim.scm make-lib.scm 			\
	evprim.c driver.c *.heap core *~ cgen$(EXEEXT) cgen.c \
	driver.scm

