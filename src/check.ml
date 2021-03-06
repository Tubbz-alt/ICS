(* 
 * The MIT License (MIT)
 *
 * Copyright (c) 2020 SRI International
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)

module type VAR = sig
  type t

  val compare : t -> t -> int
  val pp : Format.formatter -> t -> unit
end

module type VALUE = sig
  type t

  val equal : t -> t -> bool
  val random : unit -> t
  val pp : Format.formatter -> t -> unit
end

module type TERM = sig
  type t
  type var
  type value

  val pp : Format.formatter -> t -> unit
  val iter : (var -> unit) -> t -> unit

  exception Partial

  val eval : (var -> value) -> t -> value
end

module Make
    (X : VAR)
    (V : VALUE)
    (T : TERM with type var = X.t and type value = V.t) =
struct
  let probe = ref 10

  module Map = Maps.Make (X) (V)

  exception Violation of string * T.t list * T.t

  let valid name rel ql p =
    let random () =
      let acc = Map.empty () in
      let add1 x =
        if not (Map.mem x acc) then Map.set x (V.random ()) acc
      in
      List.iter (T.iter add1) ql ;
      T.iter add1 p ;
      fun x ->
        try Map.find x acc
        with Not_found ->
          raise
            (Invalid_argument
               "Error: Partiality of randomly generated interpretation.")
    in
    let sat1 () =
      let rho = random () in
      let value = T.eval rho in
      try rel (List.map value ql) (value p) with T.Partial -> true
    in
    let rec every i =
      if i < 0 then true
      else
        let res = sat1 () in
        if not res then raise (Violation (name, ql, p)) ;
        res && every (i - 1)
    in
    every !probe

  let valid2 name rel q1 q2 p =
    let rel2 = function [v1; v2] -> rel v1 v2 | _ -> assert false in
    valid name rel2 [q1; q2] p

  let valid1 name rel q p =
    let rel1 = function [v] -> rel v | _ -> assert false in
    valid name rel1 [q] p

  let continue = ref false

  let term_to_string t =
    T.pp Format.str_formatter t ;
    Format.flush_str_formatter ()

  let handle exc =
    if not !continue then raise exc
    else
      match exc with
      | Violation (name, args, res) ->
          Format.eprintf "\nCheck.Violation: %s@?" name ;
          Format.eprintf "\nArgs: @?" ;
          List.iter
            (fun p -> Format.eprintf "\n   %s" (term_to_string p))
            args ;
          Format.eprintf "\nRes:   %s@?" (term_to_string res) ;
          false
      | exc ->
          Format.eprintf "\nCheck.Violation: %s@?" (Printexc.to_string exc) ;
          false

  let valid name rel pl p = try valid name rel pl p with exc -> handle exc

  let valid2 name rel p1 p2 p =
    try valid2 name rel p1 p2 p with exc -> handle exc

  let valid1 name rel p1 p =
    try valid1 name rel p1 p with exc -> handle exc
end
