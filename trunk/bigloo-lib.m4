CPPFLAGS=-D_REENTRANT

AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_CC
AC_C_CONST
AC_HEADER_STDC

dnl ***************************************************
dnl Checks for programs.
dnl ***************************************************

AC_ARG_WITH(bigloo,
 [  --with-bigloo           path to Bigloo executable])	

if test -n "$with_bigloo"; then
  AC_MSG_CHECKING([path to Bigloo executable])
  echo $with_bigloo
  bigloo_executable=$with_bigloo
else
  AC_PATH_PROG(bigloo_executable, bigloo)
fi

if test -z "$bigloo_executable" ; then
  AC_MSG_ERROR([bigloo executable is not found. Use --with-bigloo option set the path.])
fi

AC_SUBST(bigloo_executable)

# check for bigloo3.2b final or later. No backward compatibility!

AC_MSG_CHECKING([Bigloo revision])

bigloo_revision=`$bigloo_executable -eval "(display *bigloo-version*)(exit 0)"`

if ! test "0" = "$?" ; then
  AC_MSG_ERROR([
bigloo3.2b final or later is required to
compile this version of bigloo-lib])
fi

echo $bigloo_revision

AC_SUBST(bigloo_revision)

#*-------------------------------------------------------------------*#
#*  optimization and library suffixes                                *#
#*-------------------------------------------------------------------*#
AC_MSG_CHECKING([whether to compile in minimalistic mode])
AC_ARG_ENABLE(minimalistic,
[  --enable-minimalistic          compile in minimalistic mode [[default no]]],
 enable_minimalistic=yes,enable_minimalistic=no)
echo $enable_minimalistic
AC_SUBST(enable_minimalistic)

AC_MSG_CHECKING([whether to compile in benchmark mode])
AC_ARG_ENABLE(bench,
[  --enable-bench          compile in benchmark optimization mode [[default no]]],
 enable_bench=yes,)

if test "$enable_bench" = "yes"; then
#  enable_static=yes
  enable_shared=no
  bigloo_lib_suffix="_u"
  bigloo_optimization_flags=-Obench
  CFLAGS=-O3
  echo yes
else
  if ! test "$bigloo_revision" = "2.5c" ; then
    bigloo_lib_suffix="_s"
  fi
  echo no
fi

if test "$enable_bench" = "yes"; then
  tool_lib_suffix="_u-$bigloo_revision.a"
  lib_LIBRARIES_target="lib\$(SUBPACKAGE)_u-$bigloo_revision.a"
elif test "$enable_shared" = "yes"; then
  tool_lib_suffix="_s-$bigloo_revision.la"
  enable_static=no
else
  tool_lib_suffix="-$bigloo_revision.a"
  lib_LIBRARIES_target="lib\$(SUBPACKAGE)-$bigloo_revision.a"
fi
AC_SUBST(tool_lib_suffix)
AC_SUBST(lib_LIBRARIES_target)

AC_MSG_CHECKING([Bigloo runtime library suffix])
echo $bigloo_lib_suffix

AC_SUBST(bigloo_lib_suffix)
AC_SUBST(bigloo_optimization_flags)

dnl Additional linker options with the list of the libraries,
dnl e.g. "-lm -lsocket -lnsl"

AC_MSG_CHECKING([the Bigloo user lib name])
bigloo_user_lib=`$bigloo_executable -eval "(for-each(lambda(o)(display* o #\space)) *bigloo-user-lib*)(exit 0)"`
echo $bigloo_user_lib

AC_MSG_CHECKING([the Bigloo libraries location])
if test -n "$BIGLOOLIB"; then
  bigloo_lib_dir=$BIGLOOLIB
else
  bigloo_lib_dir=`$bigloo_executable -eval "(display *default-lib-dir*)(exit 0)"`
fi
echo $bigloo_lib_dir
AC_SUBST(bigloo_lib_dir)

if test -z "$prefix" -o "$prefix" = NONE ; then
  lib_prefix=`$bigloo_executable -eval "(display *ld-library-dir*)(exit 0)"`
  prefix=`dirname $lib_prefix`
fi

AC_MSG_CHECKING([Bigloo installation prefix])
echo $prefix

#bindir=`dirname $bigloo_executable`
libdir=${prefix}/lib/bigloo/${bigloo_revision}
datadir=${libdir}
includedir=${libdir}

AC_SUBST(libdir)

dnl ***************************************************
dnl  configure PTHREAD                                 
dnl                                                    
dnl  Note: we should decide whether to support
dnl    pthreads HERE because bigloo runtime libraries
dnl    list depends on this decision
dnl ***************************************************

AC_ARG_WITH(pthread,
 [  --with-pthread          try to add pthread support [[default no]]],,
 test -z "$with_pthread" && with_pthread=no)

if test "$with_pthread" = "yes"; then

# FIXME: we couldn't use AC_SEARCH_LIBS here since the libgc_thread
# can be only linked against programs created by bigloo

dnl  AC_SEARCH_LIBS(GC_pthread_create, gc_thread,
dnl    pthread_target=pthread
dnl    common_headers="$common_headers \"pthread.h\""
dnl    pthread_libs="-lgc_thread -lpthread"
dnl    ,AC_MSG_WARN([no gc-boehm library  supporting threads was found]),
dnl    )
    pthread_target=pthread
    common_headers="$common_headers \"pthread.h\""
    pthread_libs="-L$bigloo_lib_dir -lpthread "
    common_libs="$common_libs $pthread_libs"

fi

AC_SUBST(pthread_target)

dnl ***************************************************
dnl  bigloo lib names
dnl ***************************************************
AC_MSG_CHECKING([the Bigloo library name])
dnl Bigloo runtime lib prefix, e.g "bigloo-2.5b" for libbigloo-2.5b.so
dnl or libbigloo-2.5b.a
bigloo_lib_revision=`$bigloo_executable -eval "(display *bigloo-version*)(exit 0)"`
if test -n "$bigloolibname"; then
  bigloo_lib=$bigloolibname
else
  bigloo_lib_prefix=bigloo
# check for name
  bigloo_lib=${bigloo_lib_prefix}${bigloo_lib_suffix}-${bigloo_lib_revision}
  bigloo_runtime_lib=${bigloo_lib_dir}/lib${bigloo_lib}.a
  if ! test -f "${bigloo_runtime_lib}" ; then
    AC_MSG_ERROR([Bigloo runtime library ${bigloo_runtime_lib} doesn't exist])
  fi
fi
echo $bigloo_lib
AC_SUBST(bigloo_lib)

AC_MSG_CHECKING([the Bigloo gc library name])
if test -n "$bigloolibgcname"; then
  bigloo_libgc=$bigloolibgcname
else
  if test -n "$pthread_target" ; then
    bigloo_lib_fair_thread_part=_fth
    pthread_lib=-lpthread
  fi
  bigloo_libgc_prefix=`$bigloo_executable -eval "(display *gc-lib*)(exit 0)"`
  bigloo_libgc_revision=${bigloo_lib_revision}
  bigloo_libgc="${bigloo_libgc_prefix}${bigloo_lib_fair_thread_part}-${bigloo_libgc_revision} $pthread_lib"

# Note: we have to include this library explicitly, because bigloo
# does not use it by default
  pthread_libs=" -l$bigloo_libgc $pthread_libs "
fi
echo $bigloo_libgc
AC_SUBST(bigloo_libgc)
AC_SUBST(pthread_libs)

dnl ***************************************************
dnl Which `afile' tool to use?
dnl ***************************************************

AC_PATH_PROG(afile, afile)
if test -n "$afile"; then
    AC_MSG_CHECKING([whether Bigloo afile supports the -I flag])
  $afile -I . >/dev/null 2>&1
  if test "$?" = "0" ; then
    echo Ok
  else
    afile=
    echo crashes!!!
  fi
fi

if test -z "$afile"; then
  if test -f ./afile.scm; then
    # we are building the bigloo-common stand-alone or RPM
    afile=./bigloo-lib-afile
    afile_target=bigloo-lib-afile
  else
    if test -f common/afile.scm; then
      # we are building the bigloo-lib composite or RPM
      afile=../common/bigloo-lib-afile
      afile_target=bigloo-lib-afile
    else
      AC_PATH_PROG(afile, bigloo-lib-afile)
    fi
  fi
fi

if test -z "$afile" ; then
  AC_MSG_ERROR("No appropriate afile utility was found");
fi
AC_MSG_CHECKING("for appropriate afile utility")
echo $afile

AC_SUBST(afile)
AC_SUBST(afile_target)

# check for bpp executable exists, use `cat' if absent
AC_PATH_PROG(bpp, bpp, cat)
if test "`basename $bpp`" = "bpp"; then
  AC_MSG_CHECKING([whether bpp works])
  if $bpp < /dev/null 2>&1 > /dev/null; then
    echo yes
  else
    bpp=cat
    echo no, cat will be used
  fi
fi
AC_SUBST(bigloo_user_lib)

dnl Check whether the dl library is available, and is required to use
dnl dlopen et al. If dl library is present, it is usually
dnl *required* to link with Bigloo.

AC_SEARCH_LIBS(dlopen, dl,
[
  # dlopen is present, check whether -dl linker option is required
  AC_CHECK_HEADER(dlfcn.h,
    common_headers="$common_headers \"dlfcn.h\"" dl_targets=dl)

  if test "$ac_cv_search_dlopen" != "none required" ; then
    dl_option=-ldl
    bigloo_user_lib="$bigloo_user_lib -ldl"
  fi
])
AC_SUBST(dl_option)
AC_SUBST(dl_targets)

if test -z "$cgen" ; then
  if test -f "${top_srcdir}/cgen.scm" ; then
    # we are building the common package
    cgen=./cgen${EXEEXT}
  elif test -f ${top_dir}/common/cgen.scm ; then
    # we are building entire bigloo-lib package at once
    cgen=../common/cgen${EXEEXT}
  else
    # we are building bigloo-lib subpackage other then common, working
    # cgen must already be installed in the system
    AC_PATH_PROG(cgen, cgen)
  fi
fi

if test -z "$cgen"; then
  AC_MSG_ERROR([cannot find cgen utility, you need to install
the bigloo-common package in order to compile other subpackages])
fi

dnl ***************************************************
dnl configure deprecation flags
dnl ***************************************************
AC_MSG_CHECKING(whether to disable deprecated stuff)
AC_ARG_WITH(deprecated,
 [  --with-deprecated       enable compilation of deprecated stuff [[default yes]]],,
 test -z "$with_deprecated" && with_deprecated=yes)

if test "$with_deprecated" = "yes"; then
  echo yes
else
  echo no
fi
AC_SUBST(with_deprecated)
