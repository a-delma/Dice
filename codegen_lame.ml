module L = Llvm
module A = Ast
open Sast 

module StringMap = Map.Make(String)

let translate (globals, functions, hello) = 
  let context    = L.global_context () in
  (* Add types to the context so we can use them in our LLVM code *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context 
  (* Create an LLVM module -- this is a "container" into which we'll 
     generate actual code *)
  and the_module = L.create_module context "Dice" in

  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | _       -> raise (Failure "TODO")
  in

  let main_decl =
    L.define_function "main" i32_t the_module
  in
  let builder = L.builder_at_end context (L.entry_block main_decl)
  in
  
  let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder in
    (L.build_add (L.const_int i32_t 0) (L.const_int i32_t 0) "test" builder);
  
  
    (* L.dump_module the_module; *)
  
    L.build_ret (L.const_int i32_t 0) builder;
  
  (* List.iter build_function_body functions; *)

  the_module