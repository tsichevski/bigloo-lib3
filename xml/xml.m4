m4_include([libxml2.m4])
m4_include([libxslt.m4])

AM_PATH_XML2
AM_PATH_XSLT

if test -n "$XML_CONFIG" ; then
   AC_ERROR([Cannot find the libxml2 package])
fi

bigloo_xml_includes='"libxml/tree.h" "libxml/parser.h"'

if test -n "$XSLT_CONFIG" ; then
   xslt_target="xslt xsltutils transform"
   bigloo_xml_libs="$XSLT_LIBS"
   bigloo_xml_cflags="$XSLT_CFLAGS"
   bigloo_xml_includes="$bigloo_xml_includes \"libxslt/transform.h\""
else
   bigloo_xml_libs="$XML_LIBS"
   bigloo_xml_cflags="$XML_CFLAGS XML_CPPFLAGS"
fi
AC_SUBST(xslt_target)
AC_SUBST(bigloo_xml_libs)
AC_SUBST(bigloo_xml_cflags)
AC_SUBST(bigloo_xml_includes)
