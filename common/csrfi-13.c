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

#include <string.h>

int string_contains(char* hay, int hay_len, char* needle, int needle_len)
{
  char* s1 = hay;
  char match_char = *needle;
  char* last_word = s1 + hay_len - needle_len;
  /* printf("s1 '%s' hay_len %d needle '%s' needle_len %d last_word %d\n", s1, hay_len, needle, needle_len, last_word); */
  while(s1 <= last_word)
    {
      char* first_found = memchr(s1, match_char, last_word - s1 + 1);
      /* printf("p %s and last_word %s\n", s1, last_word);
	 printf("match_char %c first_found %s\n", match_char, first_found);
      */
      if(!first_found)	
	return -1;
      if(!memcmp(first_found, needle, needle_len))
	return first_found - hay;
      s1 = first_found + 1;
    }
  return -1;
}

