(***********************************************************************)
(*                                                                     *)
(*                           Objective Caml                            *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* $Id: lexcmm.mli,v 1.4 1999-11-17 18:58:42 xleroy Exp $ *)

val token: Lexing.lexbuf -> Parsecmm.token

type error =
    Illegal_character
  | Unterminated_comment
  | Unterminated_string

exception Error of error

val report_error: Lexing.lexbuf -> error -> unit
