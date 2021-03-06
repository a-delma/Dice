(*
 * Compiles .roll files into .ll files
 * Based on the Dice toplevel file
 * Author(s): Sasha Fedchin (file import logic)
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
  let usage_msg = "usage: ./toplevel.native [-a|-s|-l|-c] " ^
    "[-seed Natural] [file.roll]" in
  let filename = ref "" in
  let parsed   = ref [] in
  let _ = Arg.parse speclist (fun fn -> filename := fn) usage_msg in

  (* Given a path to a file returns the shortest path to the file*)
  let rec prune_path path = 
    let re = Str.regexp {|\(^\|/\)[^\./][^/]*/\.\./|} in
    let new_path = Str.global_replace re {|\1|} path in
    if new_path = path then path else prune_path new_path
  in

  let rec parse_file filename =
    if List.mem filename !parsed then ([], [], [], []) else
    let _ = parsed := filename::!parsed in
    let channel = if filename = "" then ref stdin else ref (open_in filename) in
    let lexbuf = Lexing.from_channel !channel in
    let (import_decls, _, _, _) as ast = Parser.program Scanner.token lexbuf in
    let dir = (Filename.dirname filename) in
    let import_files = List.map (fun (path) -> prune_path (dir ^ "/" ^ path)) 
                                import_decls in
    let asts = (List.map parse_file import_files) @ [ast] in
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
    | LLVM_IR -> print_string (Llvm.string_of_llmodule (Codegen.translate 
                                                            sast seed))
    | Compile -> let m = Codegen.translate sast seed in

    Llvm_analysis.assert_valid_module m;
	print_string (Llvm.string_of_llmodule m)
