
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

(*s Best type from both static and dynamic information. *)

val of_term : ctxt:(Term.t -> Number.t) -> Term.t -> Type.t

val of_linarith : ctxt:(Term.t -> Number.t) -> Sym.linarith -> Term.t list -> Type.t

(*s Type from static information only. *)

val of_term0 : Term.t -> Type.t
