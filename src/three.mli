(*
 * The contents of this file are subject to the ICS(TM) Community Research
 * License Version 2.0 (the ``License''); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.icansolve.com/license.html.  Software distributed under the
 * License is distributed on an ``AS IS'' basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing rights and limitations under the License.  The Licensed Software
 * is Copyright (c) SRI International 2003, 2004.  All rights reserved.
 * ``ICS'' is a trademark of SRI International, a California nonprofit public
 * benefit corporation.
 *)

(** Three-valued datatype. 

  @author Harald Ruess
*)

(** There is an implicit partial ordering  with [Yes < X] and [No < X]. *)
type t = 
  | Yes
  | No
  | X

val is_sub : t -> t -> bool
  (** [is_sub u v] holds if either [u = v] or [u < v]. *)

val inter : t -> t -> t option
  (** [inter u v] evaluates to [Some(w)] if both [is_sub w u] 
    and [is_sub w v]; otherwise [None] is returned. *)

val union : t -> t -> t
  (** [union u v] evaluates to [w] if both [is_sub u w] 
    and [is_sub v w] holds. *)

val is_disjoint : t -> t -> bool
  (** [is_disjoint u v] holds iff the [inter u v] is [None]. *)

val pp : Format.formatter -> t -> unit
  (** Pretty-printing *)
