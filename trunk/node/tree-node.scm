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

(module
 tree-node
 (use node)
 (import dl-node)
 (library common)
 (export
  (class tree-node::dl-node
	 (gi::bstring read-only)
	 (atts::pair-nil(default '()))
	 (children::pair-nil(default '()))
	 )
  )
 (include "common.sch")
 )

(define-method (node-atts::pair-nil self::tree-node)
  (tree-node-atts self))

(define-method (node-atts-set!::pair-nil self::tree-node atts::pair-nil)
  (tree-node-atts-set! self atts))

(define-method (node-children::pair-nil self::tree-node)
  (tree-node-children self))

(define-method (node-children-set! self::tree-node children::pair-nil)
  (tree-node-children-set! self children))

(define-method (node-rdn self::tree-node)
  (tree-node-gi self))
