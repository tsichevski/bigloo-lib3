dnl ***************************************************
dnl Configure the Gd interface.
dnl ***************************************************

AC_CHECK_HEADERS(gd.h)
AC_ARG_WITH(gd,
 [  --with-gd               try to compile GD library [[default yes]]],,
 test -z "$with_gd" && with_gd=yes)
AC_MSG_CHECKING(whether to compile GD interface)
if test "$with_gd" = "yes"; then
  # FIXME: need a more prominent detection of whether GD was built with
  # REAL support of XPM, JPEG etc. For now GD always defines stubs
  # interfaces to uninstalled libraries, so we only can check whether
  # the GD release has corresponding support
  
  if test "$ac_cv_header_gd_h" = yes ; then
    echo yes
    gd="gd"
    AC_PATH_X
    AC_CHECK_LIB(gd, gdImageCreateFromGif, gd_supports_gif=yes, ,)
    AC_CHECK_LIB(gd, gdImageCreateFromPng, gd_supports_png=yes, ,-lpng -lm)
    AC_CHECK_LIB(gd, gdImageCreateFromGd2, gd_supports_gd2=yes, ,-lz -lm)
    AC_CHECK_LIB(gd, gdImageCreateFromJpeg, gd_supports_jpeg=yes, ,-ljpeg -lm)
    AC_CHECK_LIB(gd, gdImageCreateFromWBMP, gd_supports_wbmp=yes, ,-lm)
    AC_CHECK_LIB(gd, gdImageStringTTF, gd_supports_ttf=yes, ,-lttf)
    AC_CHECK_LIB(gd, gdImagePngCtx, gd_supports_io=yes, ,-lpng)
    AC_CHECK_LIB(gd, gdImageCreateFromXpm, gd_supports_xpm=yes, ,
        [-L$x_libraries -lXpm -lX11 -lm])
  
    gd_libs="-lm -lgd"
    if test -n "$gd_supports_gif" ; then
      gd_targets="$gd_targets gd-gif"
    fi
    if test -n "$gd_supports_png" ; then
      gd_targets="$gd_targets gd-png"
      gd_libs="$gd_libs -lpng -lm"
    fi
    if test -n "$gd_supports_ttf" ; then
      gd_targets="$gd_targets gd-ttf"
      gd_libs="$gd_libs -lttf"
  #    gd_includes="$gd_includes -I$freefont_prefix"
    fi
    if test -n "$gd_supports_xpm" ; then
      gd_targets="$gd_targets gd-xpm"
      gd_libs="$gd_libs -L$x_libraries -lXpm -lX11 -lm"
  #    gd_includes="$gd_includes -I$x_includes"
    fi
    if test -n "$gd_supports_gd2" ; then
      gd_targets="$gd_targets gd-gd2"
      gd_libs="$gd_libs -lz -lm"
    fi
    if test -n "$gd_supports_jpeg" ; then
      gd_targets="$gd_targets gd-jpeg"
      gd_libs="$gd_libs -ljpeg -lm"
    fi
    if test -n "$gd_supports_wbmp" ; then
      gd_targets="$gd_targets gd-wbmp"
      gd_libs="$gd_libs -lm"
    fi
    if test -n "$gd_supports_io" ; then
      gd_targets="$gd_targets gd-io"
    fi
  else
    echo no
  fi
else
  echo disabled
fi
AC_SUBST(gd)
AC_SUBST(gd_targets)
AC_SUBST(gd_includes)
AC_SUBST(gd_libs)

