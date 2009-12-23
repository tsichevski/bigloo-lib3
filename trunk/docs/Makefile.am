info_TEXINFOS	= bigloo-lib.texi
bigloo_lib_TEXINFOS = readme.texi announce.texi time.texi cgen.texi \
	common.texi expat.texi gtk.texi \
	http.texi ldap.texi node.texi rdbms.texi afile.texi regexp.texi \
	os.texi iconv.texi string-lib.texi compat.texi gtk-refman.texi \
	bigloo-lib-version.texi gdk-refman.texi compile.texi dl.texi	\
	commandline.texi termios.texi readline.texi history.texi \
	history-example.scm gdbm.texi gl.texi

SUFFIXES	= .html

EXTRA_DIST	= bigloolib-docs.spec.in

html: bigloo-lib.html
bigloo-lib.html: $(bigloo_lib_TEXINFOS)

.texi.html:
	texi2html -split chapter $<

CLEANFILES	= *.html *~ *.cps *.fns *.tps

# FIXME: .info files are always created in the srcdir, which is
# read-only when 'make distcheck' is executed. So I've added the chmod
# command to at the beginning of the rule made by automake

.texi.info:
	chmod -R +w $(srcdir)
	@cd $(srcdir) && rm -f $@ $@-[0-9] $@-[0-9][0-9]
	cd $(srcdir) \
	  && $(MAKEINFO) $(AM_MAKEINFOFLAGS) $(MAKEINFOFLAGS) \
	       `echo $< | sed 's,.*/,,'`


# 	export pwd=`pwd` ; \
# 	export topfile=`echo $< | sed 's,.*/,,'` ; \
# 	cd $(srcdir) \
# 	  && \
# 	echo $$pwd/$$topfile ; \
# 	$(MAKEINFO) $(AM_MAKEINFOFLAGS) $(MAKEINFOFLAGS) \
# 	-o $$pwd/$$topfile $$topfile

rpm: bigloolib-docs.spec.in
	../bootstrap
	./configure
	make dist
	mv bigloolib-docs-$(VERSION).tar.gz /usr/src/redhat/SOURCES
	rpmbuild --target noarch -bb bigloolib-docs.spec
