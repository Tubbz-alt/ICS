
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
open Sym
open Term
open Mpa
open Status
(*i*) 

(*s Known disequalities; [x |-> {y,z}] is interpreted as [x <> y & x <> z].
  The function is closed in that forall [x], [y] such that [x |-> {...,y,...} ]
  then also [y |-> {....,x,....}] *)

type t = Set.t Map.t

let empty = Map.empty

let deq_of s = s
 

(*s All terms known to be disequal to [a]. *)

let deq s a =
  try Map.find a s with Not_found -> Set.empty


(*s Check if two terms are known to be disequal. *)

let is_diseq s a b =
  Set.mem b (deq s a)


(*s Adding a disequality over uninterpreted terms. *)

let rec add (x,y) s =
  let xd = deq s x in
  let yd = deq s y in
  let xd' = Set.add y xd in
  let yd' = Set.add x yd in
  match xd == xd', yd == yd' with
    | true, true -> s
    | true, false -> Map.add y yd' s
    | false, true -> Map.add x xd' s
    | false, false -> Map.add x xd' (Map.add y yd' s)


(*s Propagating an equality between uninterpreted terms. *)

let merge (a, b) s =
  let da = deq s a and db = deq s b in
  if Set.mem a db || Set.mem b da then
    raise Exc.Inconsistent
  else
    let dab = Set.union da db in
    if db == dab then
      Map.remove a s
    else
      let s' = Map.remove a s in
      Map.add b dab s'


(*s Removing disequalities for [a] by recursively 
 removing [a |-> {...,x,...}] and all [x |-> ...]. 
 Also infer constraints [a in ((-inf..q) | (q..inf))]. *)

and remove a c (s, derived) =
  Term.Set.fold 
    (fun x (acc,derived) ->
       (Map.remove x acc, Atom.mk_in c x :: derived))
    (deq s a)
    (Map.remove a s, derived)


(*s Instantiation. *)

let inst f s =
  Map.fold
    (fun x ys ->
       let x' = f x in
       let ys' = Set.fold (fun y -> Set.add (f y)) ys Set.empty in
       Map.add x' ys')
    s
    Map.empty
