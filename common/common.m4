AC_HEADER_SYS_WAIT

if test $ac_cv_header_sys_wait_h = yes; then
  have_syswait=yes
fi
AC_SUBST(have_syswait)

AC_CHECK_FUNC(strncasecmp, have_strncasecmp=yes)
AC_SUBST(have_strncasecmp)

dnl Checks for header files.
AC_CHECK_HEADER(features.h, common_headers="$common_headers \"features.h\"")
AC_CHECK_HEADER(strings.h, common_headers="$common_headers \"strings.h\"")
AC_CHECK_HEADER(iconv.h, common_headers="$common_headers \"iconv.h\"")
AC_CHECK_HEADER(sys/times.h, common_headers="$common_headers \"sys/times.h\"")
AC_CHECK_HEADER(sys/time.h, common_headers="$common_headers \"sys/time.h\"")
common_headers="$common_headers \"time.h\""
AC_SUBST(common_headers)

AC_CHECK_HEADERS(features.h strings.h iconv.h unistd.h sys/times.h dlfcn.h)

dnl ***************************************************
dnl  configure CURL                                    
dnl ***************************************************

AC_ARG_WITH(curl,
 [  --with-curl             try to add CURL support [[default yes]]],,
 test -z "$with_curl" && with_curl=yes)

if test "$enable_minimalistic" = "yes"; then
  with_curl=no
fi

if test "$with_curl" = "yes"; then
  AC_CHECK_PROG_VER(curlversion,curl-config,
    [--version],
    [libcurl \([1-9][.][0-9]\+[.][0-9]\+\)],
    [*],
    [with_curl=no])
fi

if test "$with_curl" = "yes"; then
  curl_target=curl
  common_headers="$common_headers \"curl/curl.h\""
  curl_libs=`curl-config --libs` 
  curl_cflags=`curl-config --cflags`
fi

AC_SUBST(curl_target)
AC_SUBST(curl_libs)
AC_SUBST(curl_cflags)
AC_SUBST(curlversion)

dnl ***************************************************
dnl configure command-line interfaces
dnl ***************************************************
AC_MSG_CHECKING(whether to build command-line stuff)
AC_ARG_WITH(commandline,
 [  --with-commandline      enable compilation of command-line stuff [[default no]]],,
 test -z "$with_commandline" && with_commandline=no)

if test "$enable_minimalistic" = "yes"; then
  with_commandline=no
fi

if test "$with_commandline" = "yes"; then
  echo yes
#  AC_MSG_CHECKING(whether to build readline module)
  commandline_targets=termios

  AC_CHECK_LIB(readline,readline,have_readline=yes,,-lcurses)

  if test "$have_readline" = "yes"; then
    commandline_targets="$commandline_targets readline history"
    commandline_libs="-lreadline -lcurses"
    common_headers="$common_headers \"readline/readline.h\""
    common_headers="$common_headers \"readline/history.h\""
    common_headers="$common_headers \"termios.h\""

    # TODO: check the readline version (the RL_READLINE_VERSION C
    # preprocessor directive) or check the new
    # readline/history stuff explicitly:
    #    AC_CHECK_LIB(readline,history_word_delimiters,
    #    history_has_word_delimiters=yes,,-lcurses)
  fi

else
  echo no
fi
AC_SUBST(commandline_libs)
AC_SUBST(commandline_targets)


dnl ***************************************************
dnl  configure gc-boehm (experimental)                 
dnl ***************************************************

AC_ARG_WITH(gc,
 [  --with-gc               try to add gc-boehm support [[default no]]],,
 test -z "$with_gc" && with_gc=no)

if test "$with_gc" = "yes"; then
    AC_TRY_COMPILE([
    #include <gc.h>
    ],
    GC_malloc(10);,
    gc_target=gc
    gc_cflags="\"gc.h\"",
    AC_MSG_WARN([You've requested compile gc-boehm support but no gc.h was found by compiler])
    )
fi


AC_SUBST(gc_target)
AC_SUBST(gc_cflags)
AC_SUBST(gcversion)

dnl ***************************************************
dnl  configure raw socket interface (experimental)     
dnl ***************************************************

AC_ARG_WITH(socket,
 [  --with-socket           try to add raw socket support [[default no]]],,
 test -z "$with_socket" && with_socket=no)

if test "$with_socket" = "yes"; then
  socket_target=socket
fi
AC_SUBST(socket_target)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T
AC_HEADER_TIME
AC_STRUCT_TM

dnl Checks for library functions.
AC_FUNC_MEMCMP
AC_FUNC_STRFTIME

#*-------------------------------------------------------------------*#
#*  have we working `mmap'?                                          *#
#*-------------------------------------------------------------------*#
AC_MSG_CHECKING(whether mmap works)
AC_FUNC_MMAP
if test $ac_cv_func_mmap_fixed_mapped = yes; then
  mmap_target=mmap
fi
AC_SUBST(mmap_target)

#*-------------------------------------------------------------------*#
#*  iconv                                                            *#
#*-------------------------------------------------------------------*#
AC_ARG_WITH(iconv,
 [  --with-iconv            detect and compile iconv module [[default yes]]],,
 test -z "$with_iconv" && with_iconv=yes)

if test "$with_iconv" = "yes"; then
  # xml2bigloo and http-charset require iconv
  AC_TRY_LINK([#include "iconv.h"],
    [iconv_open((const char*)0, (const char*)0)],,with_iconv=no)

  if test with_iconv != yes ; then
    oldLIBS="$LIBS"
    LIBS="$LIBS -liconv"
    AC_TRY_LINK([#include <iconv.h>],
      [iconv_open(NULL, NULL)],
      [iconv_libs="-liconv" with_iconv=yes])
    LIBS="$oldLIBS"
  fi

  if test "$with_iconv" = "yes"; then
    iconv_target=iconv
    bconv_target=bconv${EXEEXT}
    xml2bigloo_target=xml2bigloo${EXEEXT}
    http_charset_target=http-charset
  fi

  if test -n "$iconv_target"; then
    AC_MSG_CHECKING(whether the iconv() has const type proto)
    AC_TRY_COMPILE([#include <iconv.h>],
[int main(argc, argv)
int argc;char **argv;{
  iconv(iconv_open("",""),(const char**)0,0,(char**)0,0);
  return 0;}],
  AC_DEFINE(ICONV_CONST_ARG, 1, [Define if `iconv' second arg is `const char**' instead of `char **']) echo yes,
  echo no,
  echo cross)
  fi
fi

AC_SUBST(iconv_libs)
AC_SUBST(iconv_target)
AC_SUBST(bconv_target)
AC_SUBST(xml2bigloo_target)
AC_SUBST(http_charset_target)

AC_SEARCH_LIBS(crypt, crypt,
        [
  if test ! "$ac_cv_search_crypt" = "none required" ; then	\
    crypt_libs="$ac_cv_search_crypt";				\
  fi;								\
  crypt_target=crypt])
AC_SUBST(crypt_libs)
AC_SUBST(crypt_target)

AC_CHECK_FUNC(times, times_target=times)
AC_SUBST(times_target)

AC_CHECK_FUNCS(gettimeofday)
#*-------------------------------------------------------------------*#
#*  regexp                                                           *#
#*-------------------------------------------------------------------*#
AC_ARG_WITH(regex,
 [  --with-regex            compile regexp module [[default yes]]],,
 test -z "$with_regex" && with_regex=yes)
if test "$with_regex" = "yes"; then
  AC_MSG_CHECKING(whether the regcomp works)
  AC_TRY_RUN([
#include <stdio.h>
#include <regex.h>
int main(argc, argv)
	int argc;char **argv;{
  regex_t preg;regcomp(&preg, "q", REG_EXTENDED);
  return 0;}
  ],
  common_headers="$common_headers \"regex.h\""
  AC_DEFINE(HAVE_REGCOMP, 1, [Define if you have working regcomp]) regex_target="regex"; echo yes,
  echo no,
  AC_DEFINE(HAVE_REGCOMP, 1, [Define if you have working regcomp]) regex_target="regex"; echo cross)
fi
AC_SUBST(regex_target)

#*-------------------------------------------------------------------*#
#*  ipcs                                                             *#
#*-------------------------------------------------------------------*#
AC_ARG_WITH(ipcs,[  --with-ipcs             compile ipcs module [[default no]]])
if test "$with_ipcs" = "yes"; then
  AC_DEFINE(HAVE_IPCS, 1, [Define if you want the ipcs package to be compiled.]) ipcs_target=ipcs
fi
AC_SUBST(ipcs_target)


#*-------------------------------------------------------------------*#
#*  MzScheme compatibility                                           *#
#*-------------------------------------------------------------------*#
AC_MSG_CHECKING([to compile MzScheme compatibility module])
AC_ARG_WITH(mzcompat,
 [  --with-mzcompat         compile MzScheme compatibility module [[default no]]])

if test "$with_mzcompat" = "yes"; then
  mzcompat_target=mzcompat echo yes
else
 echo no
fi
AC_SUBST(mzcompat_target)

#*-------------------------------------------------------------------*#
#*  checking if ctime_r exists and for valid ctime_r call proto      *#
#*-------------------------------------------------------------------*#
AC_CHECK_FUNCS(ctime_r,
AC_DEFINE(HAVE_CTIME_R, 1, [Define if you have a working `ctime_r' call])
AC_MSG_CHECKING(whether ctime_r() accepts 3 arguments)
AC_TRY_COMPILE([#include <time.h>],
time_t t; char *buf; ctime_r(&t,buf,0);,
  echo yes
  AC_DEFINE(HAVE_LONG_CTIME_R_CALL, 1, [HAVE_LONG_CTIME_R_CALL]),
AC_TRY_COMPILE([#include <time.h>],
  [time_t t; char *buf; ctime_r(&t,buf);],
  echo no,
  critic_missing=t)))
#*-------------------------------------------------------------------*#
#*  checking if getpwuid_r exists, deduce valid getpwuid_r proto     *#
#*-------------------------------------------------------------------*#
AC_CHECK_FUNCS(getpwuid_r,
  AC_DEFINE(HAVE_GETPWUID_R, 1, [Define if you have a working `getpwuid_r' call.])
  AC_MSG_CHECKING(whether getpwuid_r() accepts 5 arguments)
  AC_TRY_COMPILE([#include <pwd.h>],
    [struct passwd resbuf; char buf[[1024]];
     struct passwd* result;
     getpwuid_r(0,&resbuf,buf,1024,&result);],
    echo yes
    AC_DEFINE(HAVE_LONG_GETPWUID_R_CALL, 1, [Define if getpwuid_r requires 5 arguments]),
    echo no
    AC_TRY_COMPILE([#include <pwd.h>],
    [struct passwd resbuf; char buf[[1024]];
     getpwuid_r(0,&resbuf,buf,1024);],
    ,
    AC_MSG_WARN([Bad getpwuid_r()]))))
#*-------------------------------------------------------------------*#
#*  checking if getpwnam_r exists, deduce valid getpwnam_r proto     *#
#*-------------------------------------------------------------------*#
AC_CHECK_FUNCS(getpwnam_r,
  AC_DEFINE(HAVE_GETPWNAM_R, 1, [Define if you have a working `getpwnam_r' call])
  AC_MSG_CHECKING(whether getpwnam_r() accepts 5 arguments)
  AC_TRY_COMPILE([#include <pwd.h>],
    [struct passwd resbuf; char buf[[1024]];
     struct passwd* result;
     getpwnam_r("root",&resbuf,buf,1024,&result);],
    echo yes
    AC_DEFINE(HAVE_LONG_GETPWNAM_R_CALL,
     1,
     [Define if `getpwnam_r' requires 5 arguments]),
    echo no
    AC_TRY_COMPILE([#include <pwd.h>],
      [struct passwd resbuf; char buf[[1024]];
       getpwnam_r("root",&resbuf,buf,1024);],
    ,
    AC_MSG_WARN([Bad getpwnam_r()]))))

#*-------------------------------------------------------------------*#
#*  checking if mkdir accepts second argument (not true for MinGW)   *#
#*-------------------------------------------------------------------*#
AC_MSG_CHECKING(whether mkdir() accepts 2 arguments)
AC_TRY_COMPILE([#include <sys/stat.h>
#include <sys/types.h>],
[mkdir("/",0666);],
echo yes
AC_DEFINE(MKDIR_ACCEPTS_MODE, 1, [Define if mkdir accepts second `mode' argument]),
echo no)
#*-------------------------------------------------------------------*#
#*  putenv/setenv                                                    *#
#*-------------------------------------------------------------------*#
AC_CHECK_FUNCS(setenv, enable_setenv=yes)
AC_SUBST(enable_setenv)

#*-------------------------------------------------------------------*#
#*  flock                                                            *#
#*-------------------------------------------------------------------*#
AC_CHECK_FUNCS(flock, enable_flock=yes)
AC_SUBST(enable_flock)

#*-------------------------------------------------------------------*#
#*  gettext                                                          *#
#*-------------------------------------------------------------------*#
AC_ARG_WITH(gettext,
 [  --with-gettext          gettext support [[default yes]]],,
 test -z "$with_gettext" && with_gettext=yes)
if test "$with_gettext" = "yes"; then
AC_CHECK_FUNCS(gettext,
  gettext_target=gettext
#  gettext_libs=-lintl
  common_headers="$common_headers \"libintl.h\""
  )
fi
AC_SUBST(gettext_target)
AC_SUBST(gettext_libs)

#*-------------------------------------------------------------------*#
#*  gdbm                                                             *#
#*-------------------------------------------------------------------*#
AC_MSG_CHECKING(whether to compile gdbm support)
AC_ARG_WITH(gdbm,
 [  --with-gdbm             gdbm support [[default no]]],,
 test -z "$with_gdbm" && with_gdbm=no)

if test "$enable_minimalistic" = "yes"; then
  with_gdbm=no
fi

if test "$with_gdbm" = "yes"; then
  echo yes
  AC_CHECK_HEADER(gdbm.h,,
    AC_MSG_WARN(No gdbm.h found)
    with_gdbm=no)
  AC_SEARCH_LIBS(gdbm_open, gdbm, ,
    AC_MSG_WARN(No gdbm library found)
    with_gdbm=no)

  if test "$with_gdbm" = "yes"; then
    gdbm_target=gdbm
    gdbm_libs=-lgdbm
    common_headers="$common_headers \"gdbm.h\""
  fi
else
  echo no
fi
AC_SUBST(gdbm_target)
AC_SUBST(gdbm_libs)

#*-------------------------------------------------------------------*#
#*  db                                                             *#
#*-------------------------------------------------------------------*#
AC_MSG_CHECKING(whether to compile db support)

AC_ARG_WITH(db,
 [  --with-db             db support [[default no]]],,
 test -z "$with_db" && with_db=no)

if test "$enable_minimalistic" = "yes"; then
  with_db=no
fi

if test "$with_db" = "yes"; then
  echo yes
  AC_CHECK_HEADER(db_185.h, ,
    AC_MSG_WARN([No db_185.h found])
    with_db=no)
  AC_SEARCH_LIBS(dbm_open, db, ,
    AC_MSG_WARN([No Berkeley DB 1.85 library found])
    with_db=no)

  if test "$with_db" = "yes"; then
    db_target=db
    db_libs=-ldb
    common_headers="$common_headers \"db_185.h\""
    CFLAGS="$CFLAGS -DDB_DBM_HSEARCH=1 "
  fi
else
  echo no
fi
AC_SUBST(db_target)
AC_SUBST(db_libs)

dnl ***************************************************
dnl Should regex-output be compiled?
dnl ***************************************************

AC_ARG_WITH(regex_output,
 [  --with-regex-output     compile regex-output [[default no]]])
AC_MSG_CHECKING(whether to compile compile regex-output)
if test "$with_regex_output" = "yes"; then
  regex_output_targets=regex-output
  echo yes
else
  echo no
fi
AC_SUBST(regex_output_targets)
common_libs="$common_libs $iconv_libs $crypt_libs $commandline_libs $gdbm_libs $db_libs $curl_libs"
AC_SUBST(common_libs)

dnl Bigloo has its own sleep procedure since 2.6a
AC_MSG_CHECKING([whether bigloo implements `sleep'])
$bigloo_executable -eval '(begin(sleep 1)(exit 0))' >/dev/null 2>&1

if test "$?" = 0 ; then
  bigloo_implements_sleep=yes
else
  bigloo_implements_sleep=no
fi
echo $bigloo_implements_sleep

AC_SUBST(bigloo_implements_sleep)

AC_STRUCT_TIMEZONE
