
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
i*)

type entry = 
  | Def of Term.t
  | Arity of int
  | Type of Number.t
  | State of Shostak.t

and t = entry Name.Map.t

let lookup = Name.Map.find

let empty = Name.Map.empty

let add n e s =
  if Name.Map.mem n s then
    raise (Invalid_argument "Name already in table")
  else 
    Name.Map.add n e s

let remove = Name.Map.remove

let filter p s = 
  Name.Map.fold 
    (fun n e acc -> 
       if p n e then Name.Map.add n e acc else acc)
    s
    Name.Map.empty

let state = filter (fun _ e -> match e with State _ -> true | _ -> false)
let def   = filter (fun _ e -> match e with Def _ -> true | _ -> false)
let arity = filter (fun _ e -> match e with Arity  _ -> true | _ -> false)
let typ   = filter (fun _ e -> match e with Type  _ -> true | _ -> false)

let rec pp fmt s =
  Name.pp_map pp_entry fmt s
 
and pp_entry fmt e =
  let pr = Format.fprintf fmt in
  match e with
    | Def(x) -> pr "@[def("; Pretty.term fmt x; pr ")@]"
    | Arity(a) -> pr "@[sig("; Format.fprintf fmt "%d" a; pr ")@]"
    | Type(c) -> pr "@[type("; Number.pp fmt c; pr ")@]"

    | State(s) -> pr "@[state("; Shostak.pp fmt s; pr ")@]"