(*
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
 *)

(** {i Signs} are elements in [{F, Zero, Pos, Neg, Nonneg, Nonpos, T}].
  The denotation of a sign [s], denoted by {v D(s) v},  is a subset of
  the set of real numbers defined as follows:
  - [D(F)] is the empty set,
  - [D(Zero)] is the singleton set containing [0],
  - [D(Pos)] is the set of positive real numbers,
  - [D(Neg)] is the set of negative real numbers,
  - [D(Nonneg)] is the set of non-negative real numbers,
  - [D(Nonpos)] is the set of non-positive real numbers,
  - [D(T)] is the real number line

  @author Harald Ruess
*)

type t = F | Zero | Pos | Neg | Nonneg | Nonpos | T

val pp : t Pretty.printer
  (** Pretty-printing of constraints. *)

val of_q : Mpa.Q.t -> t
  (** [D(of_q q)] is the singleton set containing [q]. *)


(** {6 Relations} *)

val eq : t -> t -> bool
  (** [eq c d] holds iff [D(c)] equals [D(d)]. *)

val mem : Mpa.Q.t -> t -> bool
  (** [mem q c] holds iff [q] is in [D(c)]. *)

val sub : t -> t -> bool
  (** [sub c d] iff [D(c)] is a subset of [D(d)]. *)

val disjoint : t -> t -> bool
  (** [disjoint c d] iff [D(c)] is disjoint from [D(d)]. *)

val complementable : t -> bool
  (** [complementable c] holds iff [is_zero c] does not hold. In this
    case, the complement can be formed. *)
  

(** {6 Connectives} *)

val inter : t -> t -> t
  (** [D(inter c d)] equals [D(c)] intersected with [D(d)]. *)

val complement : t -> t
  (** For all complementable constraints [c], that is {!Sign.complementable}
    holds for [c],  [D(complement c)] equals [Real - D(c)] if [dom c] is 
    {!Dom.Real} and [Int - D(c)] if [dom c] is {!Dom.Int}. Otherwise [Invalid_argument]
    is raised. *)


(** {6 Abstract sign interpretation} *)

val num : Mpa.Q.t -> t
  (** [D(num q)] is the singleton [{q}]. *)

val add : t -> t -> t
  (** [D(add c d)] is [{x + y | x in D(c), y in D(d)}]. *)

val addl : t list -> t
  (** [D(add [c1;...;cn])] is [{x1+ ... + xn | xi in D(ci)}]. *)

val multq : Mpa.Q.t -> t -> t
  (** [D(multq q c)] is [{q*x | x in D(c)}]. *)

val mult : t -> t -> t
  (** [D(mult c d)] is a superset of [{x * y | x in D(c), y in D(d)}]. *)

val multl : t list -> t
  (** [D(mult [c1;...;cn])] is a superset of [{x1* ... *xn | xi in D(ci)}]. *)

val expt : int -> t -> t
  (** [D(expt n c)] is a superset of [{x^n | x in D(c)}]. *)

val div : t -> t -> t
  (** For [d] with [D(d)] not containing [0],
    [D(div c d)] is the set [{x / y | x in D(c), y in D(d)}]. *)

val of_term : (Term.t -> t) -> Term.t -> t
  (** [of_term lookup a] yields an abstract sign interpretation of term [a]. 
    Signs of nonarithmetic subterms of [a] are obtained as [lookup a].  Lookup
    is assumed to raise [Not_found] if there is no such constraint for [a].
    If [a] is not interpreted as a real number in the context [lookup], then
    [Not_found] is raised. *)
