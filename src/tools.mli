
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
 * Author: Jean-Christophe Filliatre, Harald Ruess
 i*)

(*s The purpose of the [Tools] module is to provide some functions and types,
  which are used througout the code of ICS. *)


(*s Procedures [f] without parameters can be registered as exit procedures
  by [add_to_exit f]. The registered exit procedures are then called by
  [do_at_exit()]. Exit procedures are usually used for displaying some
  statistics. *)

val add_at_exit : (unit -> unit) -> unit
val do_at_exit : unit -> unit


(*s [add_to_reset f] registers [f] as a reset procedure, which are then
  called, one-by-one, by [do_at_reset()]. *)

val add_at_reset : (unit -> unit) -> unit
val do_at_reset : unit -> unit




(*s [utime f a] returns not only the result of applying [f] to [a]
  but also the time required to compute the function. *)

val utime : ('a -> 'b) -> 'a -> 'b * float
    

    (*s [profile str f] profiles function [f], and
      registers an exit function which outputs the number of calls
      of this function, and the total time spent in this function;
      the argument [str] is usually just the name of the function.*)
val profile : string -> ('a -> 'b) -> ('a -> 'b)


(*s Given a pretty printing function [f] for type ['a],
  [pp_to_string f a] redirects the output of [f(a)] to a string. *)

val pp_to_string : (Format.formatter -> 'a -> unit) -> 'a -> string


(*s Type for comparison. More readable than the convential [-1], [0], and [1]
  results of comparisons. *)

type cmp = Less | Equal | Greater


(*s Mapping over list of terms. Avoids unnecessary consing. *)

val mapl : ('a -> 'a) -> 'a list -> 'a list


(*s Printing a list. *)

val ppl : string * string * string 
            -> (Format.formatter -> 'a -> unit)
               -> Format.formatter -> 'a list -> unit 
