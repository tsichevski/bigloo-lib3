dnl ***************************************************
dnl Configure MySQL interface.
dnl ***************************************************
AC_CHECK_PROG(mysqlconfig, mysql_config, yes)
if test "$mysqlconfig" = yes ; then
  # dnl The MySQL RPM includes the mysql_config utility, so we have to
  # check the availability of header filesw

  mysql_cflags=`mysql_config --cflags | sed "s|'||g"`
  tmp=$CFLAGS
  CFLAGS="$CFLAGS $mysql_cflags"
  AC_TRY_COMPILE([
#include <mysql.h>
      ],
      [],
      mysql=mysql)
  CFLAGS=$tmp

  if test -z "$mysql" ; then
    AC_MSG_WARN([No MySQL development support found, no MySQL support will be compiled])
  else
    mysql_libs=`mysql_config --libs`
    mysql_rpath="-rpath /usr/lib/mysql -rpath /usr/local/lib/mysql"
    mysql_includes='"mysql.h"'
  fi
fi
AC_SUBST(mysql)
AC_SUBST(mysql_cflags)
AC_SUBST(mysql_libs)
AC_SUBST(mysql_rpath)
AC_SUBST(mysql_includes)


dnl ***************************************************
dnl Configure PostgreSQL interface.
dnl ***************************************************

AC_ARG_WITH(postgresql,
 [  --with-postgresql       try to compile PostgreSQL library [[default yes]]],,
 test -z "$with_postgresql" && with_postgresql=yes)

if test "$with_postgresql" = "yes"; then

  AC_PATH_PROG(pg_config, pg_config, , $PATH:/usr/local/pgsql/bin)
  if test -n "$pg_config" ; then
    pgsql=pgsql
    pgsql_libs="-L`$pg_config --libdir` -lpq"
    pgsql_cflags="-I`$pg_config --includedir`"
    pgsql_rpath="-rpath /usr/lib/pgsql -rpath /usr/local/pgsql/lib"
    pgsql_includes=\"libpq-fe.h\"
  else
    dnl FIXME: this should probably only work is postgresql was installed
    dnl with /usr prefix
    AC_CHECK_LIB(pq, PQsetdbLogin, pgsql=pgsql)
    if test -n "$pgsql" ; then
      tmp=$CFLAGS
      CFLAGS=`pg_config --cflags`
      AC_TRY_COMPILE([
          #include "libpq-fe.h"
          ],
          [],[],
          pgsql=
  	)
      CFLAGS=$tmp
  
      if test -z "$pgsql" ; then
        AC_MSG_WARN([No PostgreSQL development support found, no PostgreSQL support will be compiled])
      else
        pgsql_libs="-lpq"
        pgsql_cflags="-I/usr/include/pgsql"
        pgsql_includes=\"libpq-fe.h\"
      fi
    fi
  fi
fi
AC_SUBST(pgsql)
AC_SUBST(pgsql_cflags)
AC_SUBST(pgsql_libs)
AC_SUBST(pgsql_rpath)
AC_SUBST(pgsql_includes)

dnl ***************************************************
dnl Configure SQLite interface.
dnl ***************************************************
AC_ARG_WITH(sqlite,
 [  --with-sqlite           try to compile SQLITE library [[default yes]]],,
 test -z "$with_sqlite" && with_sqlite=yes)

if test "$with_sqlite" = "yes"; then
  AC_CHECK_LIB(sqlite3, sqlite3_open,
    sqlite=sqlite3
    sqlite_libs=-lsqlite3
    sqlite_includes=\"sqlite3.h\"
    )
  if test -z "$sqlite" ; then
    AC_CHECK_LIB(sqlite, sqlite_open,
      sqlite=sqlite
      sqlite_libs=-lsqlite
      sqlite_includes=\"sqlite.h\"
      )
  fi
fi

AC_MSG_CHECKING(whether to compile SQLITE interface)
if test -n "$sqlite" ; then
  echo yes
else
  echo no
fi

AC_SUBST(sqlite)
AC_SUBST(sqlite_libs)
AC_SUBST(sqlite_includes)

dnl ***************************************************
dnl configure ORACLE
dnl ***************************************************

if test -n "$ORACLE_HOME" ; then
  cflags="-I$ORACLE_HOME/rdbms/demo \
	-I$ORACLE_HOME/rdbms/public \
	-I $ORACLE_HOME/network/public"
  TMP=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $cflags"
  AC_CHECK_HEADERS("oci.h",
    oci_h_present=yes
    )
  if test "$oci_h_present" = "yes" ; then
      # On 64-bit platform we must check for libclntsh.so is no 32-bit
      AC_CHECK_LIB(clntsh, OCIStmtPrepare,
          oracle=oracle
          oracle_libs="-L$ORACLE_HOME/lib -lclntsh"
          oracle_rpath="-rpath $ORACLE_HOME/lib"
          oracle_includes=\"oci.h\"
          oracle_cflags=$cflags )
  fi

  CPPFLAGS=$TMP
fi
AC_SUBST(oracle)
AC_SUBST(oracle_libs)
AC_SUBST(oracle_rpath)
AC_SUBST(oracle_cflags)
AC_SUBST(oracle_includes)

