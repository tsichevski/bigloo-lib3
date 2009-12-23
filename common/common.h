/************************************************************************/
/*                                                                      */
/* Copyright (c) 2003 Vladimir Tsichevski <wowa1@online.ru>             */
/*                                                                      */
/* This file is part of bigloo-lib (http://bigloo-lib.sourceforge.net)  */
/*                                                                      */
/* This program is free software; you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published    */
/* the Free Software Foundation; either version 2, or (at your option   */
/* any later version.                                                   */
/*                                                                      */
/* This program is distributed in the hope that it will be useful,      */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        */
/* GNU General Public License for more details.                         */
/*                                                                      */
/* You should have received a copy of the GNU General Public License    */
/* along with this program; see the file COPYING.  If not, write to     */
/* the Free Software Foundation, 59 Temple Place - Suite 330,           */
/* Boston, MA 02111-1307, USA.                                          */
/*                                                                      */
/************************************************************************/

/* #define _GNU_SOURCE */

#ifdef HAVE_FEATURES_H
#  include "features.h"
#endif

#ifdef HAVE_ICONV_H
#  include "iconv.h"
#endif

#ifdef HAVE_REGCOMP
#  include "regex.h"
#endif

#if TIME_WITH_SYS_TIME
# include <sys/time.h>
# include <time.h>
#else
# if HAVE_SYS_TIME_H
#  include <sys/time.h>
# else
#  include <time.h>
# endif
#endif

#ifdef HAVE_CTIME_R
#ifdef HAVE_LONG_CTIME_R_CALL
#  define CTIME_R(a, b, c) ctime_r((a),(b),(c))
#else
#  define CTIME_R(a, b, c) ctime_r((a),(b))
#endif
#endif

#ifdef HAVE_GETPWNAM_R
#ifdef HAVE_LONG_GETPWNAM_R_CALL
#  define GETPWNAM_R(a, b, c, d, e) getpwnam_r((a),(b),(c),(d),(e))
#else
#  define GETPWNAM_R(a, b, c, d, e) (getpwnam_r((a),(b),(c),(d))==NULL)
#endif
#endif

#ifdef HAVE_GETPWUID_R
#ifdef HAVE_LONG_GETPWUID_R_CALL
#  define GETPWUID_R(a, b, c, d, e) getpwuid_r((a),(b),(c),(d),(e))
#else
#  define GETPWUID_R(a, b, c, d, e) (getpwuid_r((a),(b),(c),(d))==NULL)
#endif
#endif

#ifdef HAVE_SYS_TIMES_H
#  include "sys/times.h"
#endif

#ifdef HAVE_MMAP
#  include "sys/mman.h"

#ifndef MAP_DENYWRITE
#  define MAP_DENYWRITE 0
#endif

#ifndef MAP_EXECUTABLE
#  define MAP_EXECUTABLE 0
#endif

#ifndef MAP_ANONYMOUS
#  define MAP_ANONYMOUS 0
#endif

#endif /* HAVE_MMAP */

/* #ifdef HAVE_GETTEXT */
/* #  include <libintl.h> */
/* #  define _(String) gettext(String) */
/* #else */
/* #  define _ (String) String */
/* #  define N_ (String) String */
/* #  define textdomain(Domain) */
/* #  define bindtextdomain(Package, Directory) */
/* #endif */

#ifdef HAVE_DLFCN_H
#  include "dlfcn.h"
#endif


