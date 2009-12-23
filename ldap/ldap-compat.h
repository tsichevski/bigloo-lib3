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

#include "lber.h"
#include "ldap.h"
#include "sys/time.h"

#ifndef LDAP_INT_H
#  define LDAP_INT_H
#endif

#ifndef LDAP_OPT_SUCCESS
#  define LDAP_OPT_SUCCESS	0
#endif

#ifndef LDAP_OPT_API_INFO

#  define LDAP_OPT_DEREF				0x0002
#  define LDAP_OPT_SIZELIMIT			0x0003
#  define LDAP_OPT_TIMELIMIT			0x0004
#  define LDAP_OPT_HOST_NAME			0x0030
#  define	LDAP_OPT_ERROR_NUMBER		0x0031
#  define LDAP_OPT_ERROR_STRING		0x0032
#  define	LDAP_OPT_ERROR		(-1)
#endif /* LDAP_OPT_API_INFO */
