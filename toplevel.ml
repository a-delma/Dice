open Ast

exception ParseErr of string

let () =
  let usage_msg = "usage: ./microc.native [file.mc]" in
  let channel = ref stdin in
  Arg.parse [] (fun file -> channel := open_in file) usage_msg;
  let lexbuf = Lexing.from_channel !channel in
  let ast = try Parser.program Scanner.token lexbuf with _ -> ([], [], []) in
  print_string (Ast.string_of_program ast)