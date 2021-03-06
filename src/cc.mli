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

(** {i Equality over uninterpreted function symbols.}

    Open inference system for online processing of equalities over
    uninterpreted functions. Term applications are of the form [f(x)] with
    [f] an uninterpreted function symbol and [x] a variable.

    Nested terms such as [f(g(x))] are represented as [f(v)] after
    introducing an {i alias variable} [v] for [g(x)].

    The equality theory [U] is defined by means of the
    {i congruence closure} axiom: [x = y => f(x) = f(y)].

    @author Harald Ruess *)

(** {i Term variables.} Used as an input signature to {!Cc.Apply} and
    {!Cc.Make}. *)
module type VAR = sig
  (** Representation of term variables. *)
  type t

  val equal : t -> t -> bool
  (** Equality on term variables. *)

  val compare : t -> t -> int
  (** Total comparison function with [compare x y] equals [0] iff
      [equal x y] holds and [compare x y] is negative iff [compare y x] is
      positive. *)

  val hash : t -> int
  (** Nonnegative hash value. *)

  val pp : Format.formatter -> t -> unit
  (** Printing a variable on the specified formatter. *)

  val fresh : unit -> t
  (** Create a {i fresh} variable. Note that this notion of freshness
      depends on the application context. *)
end

(** {i Uninterpreted function symbols.} Used as an input signature to
    {!Cc.Apply} and {!Cc.Make}. *)
module type FUNSYM = sig
  (** Representation of uninterpreted function symbols. *)
  type t

  val equal : t -> t -> bool
  (** Equality on uninterpreted function symbols. *)

  val compare : t -> t -> int
  (** Total comparison function with [compare f g] equals [0] iff
      [equal f g] holds and [compare f g] is negative iff [compare g f] is
      positive. *)

  val hash : t -> int
  (** Nonnegative hash value. *)

  val pp : Format.formatter -> t -> unit
  (** Printing a variable on the specified formatter. *)
end

(** {i Flat monadic term application.} Signature for representating
    {i flat}, {i monadic} applications of the form [f(x)] with [f] a
    function symbol of type [funsym] and [x] a variable of type [var]. *)
module type APPLY = sig
  (** Representation of uninterpreted function symbols. *)
  type funsym

  (** Representation of term variables. *)
  type var

  (** Representation of application of the form [f(x)] with [f] a function
      symbol and [x] a term variable. *)
  type t = private {funsym: funsym; arg: var}

  val funsym : t -> funsym
  val arg : t -> var

  val pp : Format.formatter -> t -> unit
  (** Printing a term application in the form [f(x)] on the specified
      formatter. *)

  val equal : t -> t -> bool
  (** Term applications [f(x)] and [g(y)] are equal iff the function symbols
      [f], [g] are equal and the variables [x], [y] are equal. *)

  val compare : t -> t -> int
  (** Total comparison function with [compare s t] equals [0] iff
      [equal s t] holds and [compare s t] is negative iff [compare t s] is
      positive. *)

  val hash : t -> int
  (** Nonnegative hash values. *)

  val make : funsym -> var -> t
  (** [make f x] creates a monadic term application [f(x)]. *)
end

(** {i Flat, monadic term application.} Representation of {i flat},
    {i monadic} term applications of the form [f(x)] with [f] a function
    symbol of type [Funsym.t] and [x] a variable of type [Var.t]. *)
module Apply (Var : VAR) (Funsym : FUNSYM) :
  APPLY with type var = Var.t and type funsym = Funsym.t

(** {i Interface for congruence closure} inference system is a variable
    paritioning [V] with a finite set of variable equalities [E] and
    disequalites [D]. The variable equalities generate an equivalence
    relation with [x =V y] iff [V |= x = y]. *)
module type INTERFACE = sig
  (** Representation type of variables. *)
  type var

  val find : var -> var
  (** [find x] return canonical representative of the equivalence class
      containing [x]. *)

  val canonical : var -> bool
  (** [canonical x] holds iff [x] is the canonical representative of its
      equivalence class. *)

  val equal : var -> var -> bool
  (** [equal x y] iff [V |= x = y]. *)

  val diseq : var -> var -> bool
  (** [diseq x y] iff [V |= x <> y]. *)

  val union : var -> var -> unit
  (** [union x y] adds an equality [x = y] to [V]. *)
end

(** {i Congruence closure inference system}.

    Configurations are pairs [(V, U)] with

    - [V] the variable parition given by the interface,
    - and [U] is a map with bindings [u |-> f(x)].

    Logically a binding [u |-> f(x)] is interpreted as the equality
    [u = f(x)].

    The inference system works by updating a {i current configuration}
    through {i equivalence-preserving} transformations. *)
module type INFSYS = sig
  (** Representation of variables. *)
  type var

  (** Representation of function symbols. *)
  type funsym

  (** Representation of unary application [f(x)]. *)
  type apply

  (** Representation of configurations. *)
  type t

  val empty : t
  (** The empty [U] configuration with no bindings. *)

  val current : unit -> t
  (** Returns the current [U] configuration. *)

  val initialize : t -> unit
  (** [initialize s] initializes the current [U] configuration of the
      inference system with configuration [s]. *)

  val reset : unit -> unit
  (** [reset()] is synonymous with [initialize empty]. *)

  (** Representation of bindings [u |-> f(x)]. *)
  module Find : Maps.S with type key = var and type value = apply

  val context : unit -> Find.t
  (** [context()] returns the current [U] configuration as a [Find.t] map. *)

  val unchanged : unit -> bool
  (** [unchanged()] holds if the initial [U], that is, the argument of last
      [initialize] is equal to the current configuration. *)

  val is_empty : unit -> bool
  (** [is_empty()] holds iff the current [U] configuration is empty. *)

  val congruence_closed : unit -> bool
  (** A configuration [(V, U)] is {i congruence-closed} if for all
      [u |-> f(x)] and [v |-> g(y)] with [V |= x = y] it is the case that
      [V |= u = v]. *)

  val lookup : var -> apply
  (** In a congruence-closed configuration, [lookup x] returns the term
      application [f(y)] if there is [u |-> f(y')] in [U] with [x =V u] and
      [y =V y']. Otherwise, [Not_found] is raised. This function is linear
      in the size of [U]. *)

  val inv : funsym -> var -> var
  (** In a congruence-closed configuration, [inv f x] returns [u'] if there
      is a binding [u |-> f(x')] with [u =V u'] and [x =V x'] and [u'] is
      [V]-canonical; otherwise [inv] raises [Not_found]. This function is
      linear in the number of variables [x'] occuring in the codomain of a
      binding and [x =V x']. *)

  val dom : var -> bool
  (** [dom u] holds iff there is a binding [u |-> f(x)] in [U]. *)

  val diseq : var -> var -> bool
  (** In a congruence-closed configuration [(V, U)], [diseq x y] holds iff
      [V, U |= x <> y]. *)

  val alias : funsym -> var -> var
  (** [alias f x] returns [u'] if there is [u |-> f(x')] in [U] with
      [u = u'] and [x = x'] in V; otherwise, the current [U] configuration
      is extended with such a binding, where [u] is a fresh variable.

      For completeness, [alias] should only be called in
      {i congruence-closed} contexts. In particular, [close] needs to be
      called often enough to satisfy this requirement.

      Equalities such as [f(x) = g(y)] are typically added to the
      configuration [(V, U)] by merging in [V] the [U]-aliases for [f(x)]
      and [g(y)]. For example, the following sequence of calls accomplishes
      this.

      {[
        let u = alias f x in
        let v = alias g y in
        V.union x y
      ]} *)

  val close : var -> var -> unit
  (** For terms [x], [y] with [V |= x = y], [y] is canonical in [V], and [x]
      is not canonical, [close x y] propagates newly derived variable
      equalities [x =V y] to [U].

      If [close x y] is called for each pair [x], [y] of variables with
      [x =V y], then [(V, U)] is {i congruence-closed}, that is, predicate
      [congruence_closed] holds. *)
end

(** Construct a {i closed congruence closure} inference system from an
    implementation [Var] of variables, [Funsym] of uninterpreted function
    symbols, [Apply] of flat, monadic term applications, and [V] a variable
    partitioning inference system. *)
module Make
    (Var : VAR)
    (Funsym : FUNSYM)
    (Apply : APPLY with type var = Var.t and type funsym = Funsym.t)
    (_ : INTERFACE with type var = Var.t) :
  INFSYS
    with type var = Var.t
     and type funsym = Funsym.t
     and type apply = Apply.t
