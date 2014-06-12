(***********************************************************************)
(*                                                                     *)
(*                         Caml Special Light                          *)
(*                                                                     *)
(*          Xavier Leroy and Pascal Cuoq, INRIA Rocquencourt           *)
(*                                                                     *)
(*  Copyright 1995 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../../LICENSE.  *)
(*                                                                     *)
(***********************************************************************)

(* $Id: mutex.ml,v 1.4 2001-12-07 13:40:19 xleroy Exp $ *)

type t
external create: unit -> t = "caml_mutex_new"
external lock: t -> unit = "caml_mutex_lock"
external try_lock: t -> bool = "caml_mutex_try_lock"
external unlock: t -> unit = "caml_mutex_unlock"
