(***********************************************************************)
(*                                                                     *)
(*                         Caml Special Light                          *)
(*                                                                     *)
(*  Xavier Leroy and Pascal Cuoq, projet Cristal, INRIA Rocquencourt   *)
(*                                                                     *)
(*  Copyright 1995 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../../LICENSE.  *)
(*                                                                     *)
(***********************************************************************)

(* $Id: condition.ml,v 1.6 2001-12-07 13:40:18 xleroy Exp $ *)

type t
external create: unit -> t = "caml_condition_new"
external wait: t -> Mutex.t -> unit = "caml_condition_wait"
external signal: t -> unit = "caml_condition_signal"
external broadcast: t -> unit = "caml_condition_broadcast"
