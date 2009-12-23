; -*-Scheme-*-

;************************************************************************/
;*                                                                      */
;* Copyright (c) 2003-2009 Vladimir Tsichevski <tsichevski@gmail.com>   */
;*                                                                      */
;* This file is part of bigloo-lib (http://bigloo-lib.sourceforge.net)  */
;*                                                                      */
;* This library is free software; you can redistribute it and/or        */
;* modify it under the terms of the GNU Lesser General Public           */
;* License as published by the Free Software Foundation; either         */
;* version 2 of the License, or (at your option) any later version.     */
;*                                                                      */
;* This library is distributed in the hope that it will be useful,      */
;* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    */
;* Lesser General Public License for more details.                      */
;*                                                                      */
;* You should have received a copy of the GNU Lesser General Public     */
;* License along with this library; if not, write to the Free Software  */
;* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 */
;* USA                                                                  */
;*                                                                      */
;************************************************************************/
;* */
(module
 md5
 (include "common.sch")
 (extern
  (include "md5.h"))

 (export
  (md5::bstring data::bstring #!optional start end)
  )
 )

(define (md5::bstring data::bstring #!optional start end)
  (with-optional-range
   "md5" data start end
   (let*((result(make-string 16))
	 (data::string data)
	 (start::int start)
	 (data::string
	  (pragma::string "$1 + $2"
			  data start))
	 (len::int (-fx end start))
	 (cresult::string result))
     (pragma "{
MD5_CTX ctx;
MD5Init(&ctx);
MD5Update(&ctx, $1, $2);
MD5Final($3, &ctx);
}"
	     data
	     len
	     cresult)
     result)))
