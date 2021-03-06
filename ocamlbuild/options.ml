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

(* $Id: options.ml,v 1.16 2008-07-25 14:49:03 ertai Exp $ *)
(* Original author: Nicolas Pouillard *)

let version = "ocamlbuild "^(Sys.ocaml_version);;

type command_spec = Command.spec

open My_std
open Arg
open Format
open Command

let entry = ref None
let build_dir = ref "_build"
let include_dirs = ref []
let exclude_dirs = ref []
let nothing_should_be_rebuilt = ref false
let sanitize = ref true
let sanitization_script = ref "sanitize.sh"
let hygiene = ref true
let ignore_auto = ref true
let plugin = ref true
let just_plugin = ref false
let native_plugin = ref true
let make_links = ref true
let nostdlib = ref false
let use_menhir = ref false
let catch_errors = ref true

let mk_virtual_solvers =
  let dir = Ocamlbuild_where.bindir in
  List.iter begin fun cmd ->
    let opt = cmd ^ ".opt" in
    let a_opt = A opt in
    let a_cmd = A cmd in
    let search_in_path = memo Command.search_in_path in
    let solver () =
      if sys_file_exists !dir then
        let long = filename_concat !dir cmd in
        let long_opt = long ^ ".opt" in
        if sys_file_exists long_opt then A long_opt
        else if sys_file_exists long then A long
        else try let _ = search_in_path opt in a_opt
        with Not_found -> a_cmd
      else
        try let _ = search_in_path opt in a_opt
        with Not_found -> a_cmd
    in Command.setup_virtual_command_solver (String.uppercase cmd) solver
  end

let () =
  mk_virtual_solvers
    ["ocamlc"; "ocamlopt"; "ocamldep"; "ocamldoc";
    "ocamlyacc"; "menhir"; "ocamllex"; "ocamlmklib"; "ocamlmktop"]
let ocamlc = ref (V"OCAMLC")
let ocamlopt = ref (V"OCAMLOPT")
let ocamldep = ref (V"OCAMLDEP")
let ocamldoc = ref (V"OCAMLDOC")
let ocamlyacc = ref N
let ocamllex = ref (V"OCAMLLEX")
let ocamlmklib = ref (V"OCAMLMKLIB")
let ocamlmktop = ref (V"OCAMLMKTOP")
let ocamlrun = ref N
let program_to_execute = ref false
let must_clean = ref false
let show_documentation = ref false
let recursive = ref false
let ext_lib = ref "a"
let ext_obj = ref "o"
let ext_dll = ref "so"

let targets_internal = ref []
let ocaml_libs_internal = ref []
let ocaml_lflags_internal = ref []
let ocaml_cflags_internal = ref []
let ocaml_ppflags_internal = ref []
let ocaml_yaccflags_internal = ref []
let ocaml_lexflags_internal = ref []
let program_args_internal = ref []
let ignore_list_internal = ref []
let tags_internal = ref [["quiet"]]
let tag_lines_internal = ref []
let show_tags_internal = ref []
let log_file_internal = ref "_log"

let my_include_dirs = ref [[Filename.current_dir_name]]
let my_exclude_dirs = ref [[".svn"; "CVS"]]

let dummy = "*invalid-dummy-string*";; (* Dummy string for delimiting the latest argument *)

(* The JoCaml support will be in a plugin when the plugin system will support
 * multiple/installed plugins *)
let use_jocaml () =
  ocamlc := A "jocamlc";
  ocamlopt := A "jocamlopt";
  ocamldep := A "jocamldep";
  ocamlyacc := A "jocamlyacc";
  ocamllex := A "jocamllex";
  ocamlmklib := A "jocamlmklib";
  ocamlmktop := A "jocamlmktop";
  ocamlrun := A "jocamlrun";
;;

let add_to rxs x =
  let xs = Lexers.comma_or_blank_sep_strings (Lexing.from_string x) in
  rxs := xs :: !rxs
let add_to' rxs x =
  if x <> dummy then
    rxs := [x] :: !rxs
  else
    ()
let set_cmd rcmd = String (fun s -> rcmd := Sh s)
let set_build_dir s = make_links := false; build_dir := s
let spec =
  Arg.align
  [
   "-version", Unit (fun () -> print_endline version; raise Exit_OK), " Display the version";
   "-quiet", Unit (fun () -> Log.level := 0), " Make as quiet as possible";
   "-verbose", Int (fun i -> Log.level := i + 2), "<level> Set the verbosity level";
   "-documentation", Set show_documentation, " Show rules and flags";
   "-log", Set_string log_file_internal, "<file> Set log file";
   "-no-log", Unit (fun () -> log_file_internal := ""), " No log file";
   "-clean", Set must_clean, " Remove build directory and other files, then exit"; 
   "-r", Set recursive, " Traverse directories by default (true: traverse)"; 

   "-I", String (add_to' my_include_dirs), "<path> Add to include directories";
   "-Is", String (add_to my_include_dirs), "<path,...> (same as above, but accepts a (comma or blank)-separated list)";
   "-X", String (add_to' my_exclude_dirs), "<path> Directory to ignore";
   "-Xs", String (add_to my_exclude_dirs), "<path,...> (idem)";

   "-lib", String (add_to' ocaml_libs_internal), "<flag> Link to this ocaml library";
   "-libs", String (add_to ocaml_libs_internal), "<flag,...> (idem)";
   "-lflag", String (add_to' ocaml_lflags_internal), "<flag> Add to ocamlc link flags";
   "-lflags", String (add_to ocaml_lflags_internal), "<flag,...> (idem)";
   "-cflag", String (add_to' ocaml_cflags_internal), "<flag> Add to ocamlc compile flags";
   "-cflags", String (add_to ocaml_cflags_internal), "<flag,...> (idem)";
   "-yaccflag", String (add_to' ocaml_yaccflags_internal), "<flag> Add to ocamlyacc flags";
   "-yaccflags", String (add_to ocaml_yaccflags_internal), "<flag,...> (idem)";
   "-lexflag", String (add_to' ocaml_lexflags_internal), "<flag> Add to ocamllex flags";
   "-lexflags", String (add_to ocaml_lexflags_internal), "<flag,...> (idem)";
   "-ppflag", String (add_to' ocaml_ppflags_internal), "<flag> Add to ocaml preprocessing flags";
   "-pp", String (add_to ocaml_ppflags_internal), "<flag,...> (idem)";
   "-tag", String (add_to' tags_internal), "<tag> Add to default tags";
   "-tags", String (add_to tags_internal), "<tag,...> (idem)";
   "-tag-line", String (add_to' tag_lines_internal), "<tag> Use this line of tags (as in _tags)";
   "-show-tags", String (add_to' show_tags_internal), "<path> Show tags that applies on that pathname";

   "-ignore", String (add_to ignore_list_internal), "<module,...> Don't try to build these modules";
   "-no-links", Clear make_links, " Don't make links of produced final targets";
   "-no-skip", Clear ignore_auto, " Don't skip modules that are requested by ocamldep but cannot be built";
   "-no-hygiene", Clear hygiene, " Don't apply sanity-check rules";
   "-no-plugin", Clear plugin, " Don't build myocamlbuild.ml";
   "-no-stdlib", Set nostdlib, " Don't ignore stdlib modules";
   "-dont-catch-errors", Clear catch_errors, " Don't catch and display exceptions (useful to display the call stack)";
   "-just-plugin", Set just_plugin, " Just build myocamlbuild.ml";
   "-byte-plugin", Clear native_plugin, " Don't use a native plugin but bytecode";
   "-sanitization-script", Set_string sanitization_script, " Change the file name for the generated sanitization script";
   "-no-sanitize", Clear sanitize, " Do not generate sanitization script";
   "-nothing-should-be-rebuilt", Set nothing_should_be_rebuilt, " Fail if something needs to be rebuilt";
   "-classic-display", Set Log.classic_display, " Display executed commands the old-fashioned way";
   "-use-menhir", Set use_menhir, " Use menhir instead of ocamlyacc";
   "-use-jocaml", Unit use_jocaml, " Use jocaml compilers instead of ocaml ones";

   "-j", Set_int Command.jobs, "<N> Allow N jobs at once (0 for unlimited)";

   "-build-dir", String set_build_dir, "<path> Set build directory (implies no-links)";
   "-install-lib-dir", Set_string Ocamlbuild_where.libdir, "<path> Set the install library directory";
   "-install-bin-dir", Set_string Ocamlbuild_where.bindir, "<path> Set the install binary directory";
   "-where", Unit (fun () -> print_endline !Ocamlbuild_where.libdir; raise Exit_OK), " Display the install library directory";

   "-ocamlc", set_cmd ocamlc, "<command> Set the OCaml bytecode compiler";
   "-ocamlopt", set_cmd ocamlopt, "<command> Set the OCaml native compiler";
   "-ocamldep", set_cmd ocamldep, "<command> Set the OCaml dependency tool";
   "-ocamlyacc", set_cmd ocamlyacc, "<command> Set the ocamlyacc tool";
   "-menhir", set_cmd ocamlyacc, "<command> Set the menhir tool (use it after -use-menhir)";
   "-ocamllex", set_cmd ocamllex, "<command> Set the ocamllex tool";
   (* Not set since we perhaps want to replace ocamlmklib *)
   (* "-ocamlmklib", set_cmd ocamlmklib, "<command> Set the ocamlmklib tool"; *)
   "-ocamlmktop", set_cmd ocamlmktop, "<command> Set the ocamlmktop tool";
   "-ocamlrun", set_cmd ocamlrun, "<command> Set the ocamlrun tool";

   "--", Rest (fun x -> program_to_execute := true; add_to' program_args_internal x),
   " Stop argument processing, remaining arguments are given to the user program";
  ]

let targets = ref []
let ocaml_libs = ref []
let ocaml_lflags = ref []
let ocaml_cflags = ref []
let ocaml_ppflags = ref []
let ocaml_yaccflags = ref []
let ocaml_lexflags = ref []
let program_args = ref []
let ignore_list = ref []
let tags = ref []
let tag_lines = ref []
let show_tags = ref []

let init () =
  let anon_fun = add_to' targets_internal in
  let usage_msg = sprintf "Usage %s [options] <target>" Sys.argv.(0) in
  let argv' = Array.concat [Sys.argv; [|dummy|]] in
  parse_argv argv' spec anon_fun usage_msg;
  Shell.mkdir_p !build_dir;

  let () =
    let log = !log_file_internal in
    if log = "" then Log.init None
    else if not (Filename.is_implicit log) then
      failwith
        (sprintf "Bad log file name: the file name must be implicit (not %S)" log)
    else
      let log = filename_concat !build_dir log in
      Shell.mkdir_p (Filename.dirname log);
      Shell.rm_f log;
      let log = if !Log.level > 0 then Some log else None in
      Log.init log
  in

  let reorder x y = x := !x @ (List.concat (List.rev !y)) in
  reorder targets targets_internal;
  reorder ocaml_libs ocaml_libs_internal;
  reorder ocaml_cflags ocaml_cflags_internal;
  reorder ocaml_lflags ocaml_lflags_internal;
  reorder ocaml_ppflags ocaml_ppflags_internal;
  reorder ocaml_yaccflags ocaml_yaccflags_internal;
  reorder ocaml_lexflags ocaml_lexflags_internal;
  reorder program_args program_args_internal;
  reorder tags tags_internal;
  reorder tag_lines tag_lines_internal;
  reorder ignore_list ignore_list_internal;
  reorder show_tags show_tags_internal;

  let check_dir dir =
    if Filename.is_implicit dir then
      sys_file_exists dir
    else
      failwith
        (sprintf "Included or excluded directories must be implicit (not %S)" dir)
  in
  let dir_reorder my dir =
    let d = !dir in
    reorder dir my;
    dir := List.filter check_dir (!dir @ d)
  in
  dir_reorder my_include_dirs include_dirs;
  dir_reorder my_exclude_dirs exclude_dirs;

  ignore_list := List.map String.capitalize !ignore_list
;;
