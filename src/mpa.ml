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

(** Multi-precision arithmetic using the [gmp] library. *)

open Gmp41

module Z = struct

  type t = Z.t

  let of_int = Z.from_int
  let zero = of_int 0
  let one = of_int 1
  let two = of_int 2
  let add = Z.add
  let sub = Z.sub
  let succ a = add a one
  let mult = Z.mul
  let divexact = Z.divexact
  let gcd = Z.gcd
  let lcm a b = Z.divexact (Z.mul a b) (Z.gcd a b)
  let pow = Z.pow_ui_ui 

  let rec expt x n =  
    if n = 0 then one 
    else 
      mult x (expt x (n - 1))
		 
  let compare = Z.cmp
  let equal x y = Z.cmp x y == 0
  let lt x y = Z.cmp x y < 0
  let le x y = Z.cmp x y <= 0
  let gt x y = Z.cmp x y > 0
  let ge x y = Z.cmp x y >= 0
		  
  let to_string z = Z.string_from z

  let to_int = Z.int_from
 
  let pp fmt x = 
    Format.fprintf fmt "%s" (Z.string_from x)
end

module Q = struct
  
  type t = Q.t

  let of_int n = Q.from_ints n 1
  let of_ints = Q.from_ints

  let zero = of_int 0
  let one = of_int 1
  let two = of_int 2
  let negone = of_int (-1)

  let add = Q.add
  let sub = Q.sub
  let minus = Q.neg
  let mult = Q.mul
  let div = Q.div
  let inv = Q.inv

  let rec expt a n =
    if Q.equal a zero then zero
    else if n < 0 then
      Q.inv (expt a (-n))
    else if n = 0 then 
      one
    else if n = 1 then
      a
    else 
      mult a (expt a (n - 1))

  let floor x = Gmp41.Z.fdiv_q (Q.get_num x) (Q.get_den x)

  let ceil x  = Gmp41.Z.cdiv_q (Q.get_num x) (Q.get_den x)

  let frac x = sub x (Q.from_z (floor x))
  let def x = sub (Q.from_z (ceil x)) x

  let compare = Q.cmp
  let equal = Q.equal
  let is_zero x = Q.equal zero x
  let is_one x = Q.equal one x
  let is_negone x = Q.equal (Q.neg one) x
  let lt x y = Q.cmp x y < 0
  let le x y = Q.cmp x y <= 0
  let gt x y = Q.cmp x y > 0
  let ge x y = Q.cmp x y >= 0

  let is_pos x = gt x zero
  let is_neg x = lt x zero
  let is_nonneg x = ge x zero
  let is_nonpos x = le x zero

  let min x y = if le x y then x else y
  let max x y = if le x y then y else x

  let abs q = 
    if is_neg q then mult negone q else q

  type cmp = Equal | Greater | Less

  let cmp x y =
    let b = compare x y in
    if b == 0 then Equal else if b > 0 then Greater else Less

  let denominator = Q.get_den
  let numerator = Q.get_num

  let is_integer q = (Gmp41.Z.cmp_si (Q.get_den q) 1) = 0
  let to_z = Q.get_num
  let of_z = Q.from_z

  let hash q =
     Z.to_int (Z.add (Q.get_den q) (Q.get_num q)) land 0x3FFFFFF
  

  let to_string q = 
    let d = Q.get_den q in
    if Gmp41.Z.cmp_si d 1 == 0 then
      Gmp41.Z.string_from (Q.get_num q)
    else
      (Gmp41.Z.string_from (Q.get_num q)) ^ "/" ^ (Gmp41.Z.string_from d)

  exception ZeroDivision

  let of_string s =
    try
      let k = String.index s '/' in
      let l = String.length s in
      let n = Gmp41.Z.from_string (String.sub s 0 k) in
      let d = Gmp41.Z.from_string (String.sub s (succ k) (l - k - 1)) in
	if Z.equal d Z.zero then
	  raise ZeroDivision;
	Q.from_zs n d
    with 
	Not_found ->
	  Q.from_z (Gmp41.Z.from_string s)

  let pp fmt x = Format.fprintf fmt "%s" (to_string x)

  type q = t

  module Hash = Hashtbl.Make(
    struct
      type t = q
      let equal = equal
      let hash = hash
    end)

end
