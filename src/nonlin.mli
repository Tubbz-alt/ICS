
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

(*i*)
open Mpa
open Term
(*i*)

(*s Module [Nonlin]: Constructors, recognizers, and accessors for
 nonlinear arithmetic terms. *)

(*s Recognizers. *)

val is_mult : Term.t -> bool
val is_expt : Term.t -> bool

(*s Constructors for building up nonlinear arithmetic terms. *)

val mk_mult : Term.t * Term.t -> Term.t
val mk_multl : Term.t list -> Term.t
val mk_expt : Term.t -> Term.t -> Term.t

(*s Destructors. *)

val d_mult : Term.t -> Term.t list option
val d_expt : Term.t -> (Term.t * Term.t) option