
(*
 * Compiles .roll files into .ll files
 * Based on the MicroC toplevel file
 * Author(s): ?
 *)

type action = Ast | Sast | LLVM_IR | Compile

let () =
  let action = ref Compile in
  let seed = ref ~-1 in
  let set_action a () = action := a in
  let speclist = [
    ("-a", Arg.Unit (set_action Ast), "Print the AST");
    ("-s", Arg.Unit (set_action Sast), "Print the SAST");
    ("-l", Arg.Unit (set_action LLVM_IR), "Print the generated LLVM IR");
    ("-c", Arg.Unit (set_action Compile),
      "Check and print the generated LLVM IR (default)");
    ("-seed", Arg.Set_int seed, "Set the seed when program is compiled")
  ] in
  let usage_msg = "usage: ./toplevel.native [-a|-s|-l|-c] [-seed Natural] [file.roll]" in
  let filename = ref "" in
  let _ = Arg.parse speclist (fun fn -> filename := fn) usage_msg in

  let rec parse_file filename = 
    let channel = if filename = "" then ref stdin else ref (open_in filename) in
    let lexbuf = Lexing.from_channel !channel in
    let (import_decls, _, _, _) as ast = Parser.program Scanner.token lexbuf in
    let remove_last (l) = List.rev (List.tl (List.rev l)) in
    let dir = String.concat "/" (remove_last (String.split_on_char '/' filename)) ^ "/" in
    let dir = if dir = "/" then "" else dir in
    let import_files = List.map (fun (path) -> String.concat "" [dir; path]) import_decls in
    (* let _ = print_endline "ast parsed" in *)
    let asts = List.rev (ast::(List.map parse_file import_files)) in
    (* let _ = print_endline "asts parsed" in *)
    ([], List.concat (List.map (fun (_, x, _, _) -> x) asts), 
         List.concat (List.map (fun (_, _, x, _) -> x) asts), 
         List.concat (List.map (fun (_, _, _, x) -> x) asts))
  in

  let ast = parse_file !filename in
  match !action with
    Ast -> print_string (Ast.string_of_program ast)
    | _ -> let sast = Semant.check ast in
  match !action with
      Ast     -> ()
    | Sast    -> print_string (Sast.string_of_sprogram sast)
    | LLVM_IR -> print_string (Llvm.string_of_llmodule (Codegen.translate sast seed))
    | Compile -> let m = Codegen.translate sast seed in

    Llvm_analysis.assert_valid_module m;
	print_string (Llvm.string_of_llmodule m)
