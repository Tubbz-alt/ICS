
(*i
 * The contents of this file are subject to the ICS(TM) Community Research
 * License Version 1.0 (the ``License''); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.icansolve.com/license.html.  Software distributed under the
 * License is distributed on an ``AS IS'' basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing rights and limitations under the License.  The Licensed Software
 * is Copyright (c) SRI International 2001, 2002.  All rights reserved.
 * ``ICS'' is a trademark of SRI International, a California nonprofit public
 * benefit corporation.
 * 
 * Author: Harald Ruess
 i*)

type t = 
  | Equal of equal
  | Diseq of diseq
  | Cnstrnt of cnstrnt

and justification = rule * t list

and equal = Term.t * Term.t * justification option
and diseq = Term.t * Term.t * justification option
and cnstrnt = Term.t * Cnstrnt.t * justification option

and rule = string 

let mk_equal x y j =
  assert(Term.is_var x && Term.is_var y);
  let (x, y) = Term.orient (x, y) in
  (x, y, j)

let mk_diseq x y j =
  assert(Term.is_var x && Term.is_var y);
  let (x, y) = Term.orient (x,y) in
  (x, y, j)

let mk_cnstrnt x c j =
  assert(Term.is_var x);
  (x, c, j)

let d_equal e = e
let d_diseq d = d
let d_cnstrnt c = c

let of_equal e = Equal(e)
let of_diseq d = Diseq(d)
let of_cnstrnt c = Cnstrnt(c)

let pp fmt = function
  | Equal(x, y, _) ->  Pretty.infix Term.pp "=" Term.pp fmt (x, y)
  | Diseq(x, y, _) ->  Pretty.infix Term.pp "<>" Term.pp fmt (x, y)
  | Cnstrnt(x, i, _) ->  Pretty.infix Term.pp "in" Cnstrnt.pp fmt (x, i)

