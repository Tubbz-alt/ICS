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

(** Hashconsed names. *)

type t = string * int

module StringHash = Hashtbl.Make(
  struct
    type t = string
    let equal = (=)
    let hash = Hashtbl.hash_param 4 4
  end)

let current = ref 0
let table = StringHash.create 117

(* don't reset, since there are some global variables.
let _ = Tools.add_at_reset (fun () -> current := 0)
let _ = Tools.add_at_reset (fun () -> StringHash.clear table)
*)

let of_string str =
  try
    StringHash.find table str
  with
      Not_found ->
	let n = (str, !current) in
	  incr current;
          StringHash.add table str n; n

let eq (s, i) (t, j) =
  assert(if s == t then s = t else not(s = t));
  (s == t)

let to_string (s, _) = s


let pp fmt (s, _) =
  Format.fprintf fmt "%s" s

let compare (s, i) (t, j) =
  assert(if i == j then s = t else not(s = t));
  if i < j then -1
  else if i == j then 0
  else 1


let hash (_, i) = i

module Set = Set.Make(
  struct
    type t = string * int
    let compare = compare
  end)

module Map = Map.Make(
  struct
    type t = string * int
    let compare = compare
  end)

module Hash = Hashtbl.Make(
  struct
    type t = string * int
    let equal = eq
    let hash = hash
  end)
