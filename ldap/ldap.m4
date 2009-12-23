dnl ***************************************************
dnl Configure LDAP interface
dnl build nothing in ldap/ if LDAP client not suported
dnl on this system
dnl ***************************************************
AC_ARG_WITH(ldap,
 [  --with-ldap             try to compile LDAP library [[default yes]]],,
 test -z "$with_ldap" && with_ldap=yes)
AC_MSG_CHECKING(whether to compile LDAP interface)
if test "$with_ldap" = "yes"; then
  echo yes
  AC_CHECK_HEADERS(ldap.h, ldap=ldap)

  oldLIBS=$LIBS
  LIBS=
  AC_CHECK_LIB(ldap,ldap_open,,ldap="")

  if test -z "$ldap" ; then
    AC_MSG_CHECKING(whether the lber library present)
    AC_CHECK_LIB(lber,ber_init,ldap=ldap,,-lldap)
  fi

  dnl TODO: need to try libbind on some platforms
  AC_CHECK_LIB(resolv, dn_expand,,ldap="",-lresolv)
  if test -n "$ldap" ; then
    ldap_libs="$LIBS"
echo ldap_libs $ldap_libs
    
    AC_CHECK_LIB(ldap,ldap_modrdn2_s, AC_DEFINE(HAVE_LDAP_MODRDN2, 1, [Define if you have ldap_modrdn2_s]))

    AC_MSG_CHECKING(whether ldap_modrdn_s accepts 4 arguments)
    AC_TRY_COMPILE([
    #include <lber.h>
    #include <ldap.h>
    ],
    ldap_modrdn_s((LDAP*)0,(char*)0,(char*)0, 1);,
    AC_DEFINE(HAVE_LONG_LDAP_MODRDN, 1, [Define if ldap_modrdn takes 4 arguments])
    echo yes,
    echo no
    )

    dnl upcoming releases of OpenLDAP will support
    dnl ldap_get_option() and ldap_set_option()
    dnl till when, we just emulate it
    AC_TRY_COMPILE([
    #include <lber.h>
    #include <ldap.h>
    ],
    ldap_get_option((LDAP*)0,0,0);,
    AC_DEFINE(HAVE_LDAP_GET_OPTION, 1, [Define if you have ldap_get_option() and ldap_set_option()]))

    AC_CHECK_LIB(ldap,ldap_disable_cache, ldap_have_cache_funcs=yes)

  fi
  LIBS="$oldLIBS"
  
else
  echo no
fi
AC_SUBST(ldap)
AC_SUBST(ldap_have_cache_funcs)
AC_SUBST(ldap_libs)

