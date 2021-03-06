(***********************************************************************)
(*                             ocamlbuild                              *)
(*                                                                     *)
(*  Nicolas Pouillard, Berke Durak, projet Gallium, INRIA Rocquencourt *)
(*                                                                     *)
(*  Copyright 2007 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* $Id: report.mli,v 1.1 2007-02-07 08:59:14 ertai Exp $ *)
(* Original author: Berke Durak *)
(* Report *)

val print_backtrace_analyze : Format.formatter -> Solver.backtrace -> unit

val print_backtrace : Format.formatter -> Solver.backtrace -> unit
