ACLOCAL_AMFLAGS = -I m4

# Note: the order of building of libraries is significant

LIB_SUBDIRS	= common @gd@ xml rdbms node @ldap@ http expat
# @gl@ @gtk@

SUBDIRS		= $(LIB_SUBDIRS) docs
# ext2fs

DIST_SUBDIRS	= gd expat common xml node http ldap rdbms docs
#      bgtk  gl oracle  ext2fs

EXTRA_DIST	= bigloo-lib.spec bigloo-lib.m4 Makefile.rules test.sch bootstrap \
	make-driver README.rpm

CLEANFILES = *~ core

MAINTAINERCLEANFILES = COPYING INSTALL Makefile.in aclocal.m4 configure	\
	install-sh ltconfig ltmain.sh missing mkinstalldirs stamp-h.in	\
	texinfo.tex config.guess config.sub 

afiles:
	for subdir in $(LIB_SUBDIRS) ; \
	  do \
	    (cd $$subdir && make .afile); \
	done

init-subdirs:
	for subdir in $(DIST_SUBDIRS) ; \
	  do \
	    rm -f $$subdir/Makefile.rules ; \
	    ln Makefile.rules.subpackage $$subdir/Makefile.rules ; \
	    cp test.sch $$subdir/ ; \
	done

# Create distribution for each subpackage
all-dist:
	for subdir in $(SUBDIRS) ; \
	  do \
	  (cd $$subdir && aclocal && autoconf && automake && $(MAKE) $(AM_MAKEFLAGS) dist ) ; \
	done

# Create an RPMs for each subpackage
all-rpm:
	for subdir in $(SUBDIRS) ; \
	  do \
	  (cd $$subdir \
	  && ../bootstrap \
	  && ./configure \
	  && $(MAKE) rpm ) ; \
	done
	$(MAKE) $(AM_MAKEFLAGS) rpm

all-check:
	for subdir in $(SUBDIRS) ; \
	  do \
	  (cd $$subdir \
	 && ../bootstrap \
	 && ./configure \
	 && $(MAKE) $(AM_MAKEFLAGS) check ) ; \
	done

# for each subpackage remove all autogenerated files required to build
# stand-alone subpackage. Run it before building all-in-one bigloo-lib
# package to reduce the size ot resultiong distribution file
subdirs-maintainer-clean:
	for subdir in $(SUBDIRS) ; do \
	  (cd $$subdir && rm -f $(MAINTAINERCLEANFILES)); \
	done

rpm: bigloo-lib.spec.in
	./bootstrap
	./configure
	make dist
	mv bigloo-lib-$(VERSION).tar.gz /usr/src/redhat/SOURCES
	rpmbuild -bb bigloo-lib.spec

README: docs/readme.texi docs/bigloo-lib-version.texi.in
	cd docs && \
	make bigloo-lib-version.texi && \
	makeinfo -o - readme.texi | tail -n +2 > ../$@

ANNOUNCE: README docs/announce.texi
	cd docs && \
	make bigloo-lib-version.texi && \
	makeinfo -o - announce.texi | tail -n +2 > ../$@
