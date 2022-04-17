(* Code generation: translate takes a semantically checked AST and
produces LLVM IR *)

module L = Llvm
module A = Ast
open Sast 

module StringMap = Map.Make(String)

(* Code Generation from the SAST. Returns an LLVM module if successful,
   throws an exception if something is wrong. *)
let translate (struct_decls, globals, lambdas) =
  let context    = L.global_context ()
  (* Add types to the context so we can use them in our LLVM code *)
  in let     i32_t      = L.i32_type    context
  in let     i1_t       = L.i1_type     context
  in let     float_t    = L.double_type context
  in let     void_t     = L.void_type   context 
  in let     void_ptr_t = L.pointer_type (L.i8_type context)
  in let     func_ptr_t = L.pointer_type (L.var_arg_function_type void_t [| |])
  in let     node_struct = L.named_struct_type context "Node_"
  in let     func_struct = L.named_struct_type context "Function_"  
  in let     node_struct_ptr = L.pointer_type node_struct
  in let     func_struct_ptr = L.pointer_type func_struct in
  let _ = L.struct_set_body func_struct [| (func_ptr_t); (L.pointer_type node_struct) |] false in
  let _ = L.struct_set_body node_struct [| (void_ptr_t); (L.pointer_type node_struct) |] false 

  in let the_module = L.create_module context "DICE" in

  let rec ltype_name = function
    | A.Int                 -> "int"
    | A.Bool                -> "bool"
    | A.Float               -> "double"
    | A.Void                -> "void"
    | A.Arrow(args, ret) -> 
      "map_" ^ (String.concat "_and_" (List.map ltype_name args)) ^ "_to_" ^ ltype_name ret
    | _                     -> raise (Failure "Not implemented")  
  in

  let struct_dict = 
    let make_empty name _ = L.named_struct_type context name in
    StringMap.mapi make_empty struct_decls
  in


  (* Convert Dice types to LLVM types *)
  let rec ltype_of_typ = function
      A.Int   -> i32_t 
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | A.Arrow(args, ret) as arrow -> L.pointer_type(L.function_type (ltype_of_typ ret) 
                                        (Array.of_list (func_struct_ptr::(List.map ltype_of_typ args))))
    | A.TypVar (name) -> try StringMap.find name struct_dict
      with _ -> raise (Failure (name ^ " is not a valid struct type"))
  in

  let make_struct_body name type_dict =
    let (_, types) = List.split (StringMap.bindings type_dict) in
    let ltypes_list = List.map ltype_of_typ types in
    let ltypes = Array.of_list ltypes_list in
    L.struct_set_body (StringMap.find name struct_dict) ltypes false
    (* let test_func = L.function_type (L.void_type context) [| (StringMap.find name struct_dict) |] in
    let _ = L.declare_function "test_func" test_func the_module in () *)
  in

  let _ = StringMap.mapi make_struct_body struct_decls in
  

  let getnode_func = L.declare_function 
                     "get_node" 
                     (L.function_type void_ptr_t [| node_struct_ptr ; i32_t |]) the_module in

  let append_func = L.declare_function 
                     "append_to_list" 
                     (L.function_type node_struct_ptr [| node_struct_ptr ; void_ptr_t |]) the_module in

  let getnull_func = L.declare_function 
                     "get_null_list" 
                     (L.function_type node_struct_ptr [| |]) the_module in

  let malloc_func  = L.declare_function 
                     "malloc_" 
                     (L.function_type void_ptr_t [| i32_t |]) the_module in
  
  let putchar_struct = (L.declare_global func_struct "putchar_" the_module) in
               let _ = L.set_externally_initialized true putchar_struct     in
  
  let init_func = L.declare_function
                  "initialize"
                  (L.function_type void_t [||]) the_module in 

(* Returns the size of the type t cast to an i32 (it would be i64 otherwise) *)
  let size (t : L.lltype) = (L.const_bitcast (L.size_of t) i32_t) in
(* Returns a pointer to a new heap allocated variable of type t *)
  let malloc (t : L.lltype) (malloc_b : L.llbuilder) = 
      L.build_call malloc_func [|(size t)|] "heap_ptr" malloc_b in
  
  (* Declare each global variable; remember its value in a map *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n) = 
      let init = match t with
          A.Float -> L.const_float (ltype_of_typ t) 0.0
        | A.Arrow(_,_) -> L.const_named_struct func_struct [||]
        | _ -> L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in
  let global_vars = StringMap.add "putChar" putchar_struct global_vars in
  

  (* Define each function (arguments and return type) so we can 
   * define it's body and call it later *)
  let function_decls =
    let function_decl m lambda =
      let name = lambda.sid in
      let formals_list = 
        (List.map (fun (t,_) -> ltype_of_typ t) lambda.sformals) in
      let formals_types = if name = "main" 
                        then (Array.of_list formals_list)
                        else (Array.of_list (func_struct_ptr::formals_list))
      in let ftype = L.function_type (ltype_of_typ lambda.st) formals_types in
      StringMap.add name (L.define_function name ftype the_module, lambda) m in
      List.fold_left function_decl StringMap.empty lambdas in

  (* Fill in the body of the given function *)
  let build_function_body lambda =

    let (the_function, _) = StringMap.find lambda.sid function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let _ = if lambda.sid = "main"
            then ignore(L.build_call init_func [||] "" builder)
          (* TODO possibly add another case if lambdas require it *)
      in
    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p = 
        let () = L.set_value_name n p in
	      let local = L.build_alloca (ltype_of_typ t) n builder in
        let _  = L.build_store p local builder in
	      StringMap.add n local m 
      in

      (* Allocate space for any locally declared variables and add the
       * resulting registers to our map *)
      let add_local m (t, n) =
	    let local_var = L.build_alloca (ltype_of_typ t) n builder
	      in StringMap.add n local_var m 
      in

      let formals = List.fold_left2 add_formal StringMap.empty lambda.sformals
          (Array.to_list (L.params the_function)) in  
      List.fold_left add_local formals lambda.slocals
    in

    (* Return the value for a variable or formal argument. First check
     * locals, then globals *)
    let lookup n  = try StringMap.find n local_vars
                    with Not_found -> 
                      (try StringMap.find n global_vars
                      with Not_found -> raise (Failure ("Cannot find variable " ^ n)))
    in

    (* Construct code for an expression; return its value *)
    let rec expr builder ((typ, e) : sexpr) = match e with
        SLiteral i -> L.const_int i32_t i
      | SBoolLit b -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      | SNoexpr -> L.const_int i32_t 0
      | SId s -> (match typ with (* TODO: should depend on whether it is local, global, or in closure*)
          A.Arrow(_, _) -> (lookup s)
        | _             -> L.build_load (lookup s) s builder)
      | SAssign((t, le), rse) -> 
          (match le with 
          SId(s)-> 
            (* If the right side is a global function, it must be loaded *)
                  let rse' = 
                    (match t with 
                      Arrow(_,_) -> L.build_load (expr builder rse) "tmp" builder 
                    | _          -> expr builder rse) in
                  let le'  = (lookup s) in
                  (* Returns the evaluation of the left side, a bit weird but it
                      has the least edge cases I think (Ezra) *)
                  let _ = L.build_store rse' le' builder in expr builder (t, le)
          (* TODO to implement record access where a function can 
             return a record and then get it's field we'll need to 
             incorperate expr builder le somehow as well *)
          | SRecordAccess(_, _) -> raise (Failure "CodeGen NotImplemented Struct Stuff")
          | _ -> raise (Failure "Illegal left side, should be ID or Struct Field"))
      | SBinop (e1, op, e2) ->
        let (t, _) = e1
        and e1' = expr builder e1
        and e2' = expr builder e2 in
        if t = A.Float then (match op with 
          A.Add     -> L.build_fadd
        | A.Sub     -> L.build_fsub
        | A.Mult    -> L.build_fmul
        | A.Div     -> L.build_fdiv 
        | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
        | A.Neq     -> L.build_fcmp L.Fcmp.One
        | A.Less    -> L.build_fcmp L.Fcmp.Olt
        | A.Leq     -> L.build_fcmp L.Fcmp.Ole
        | A.Greater -> L.build_fcmp L.Fcmp.Ogt
        | A.Geq     -> L.build_fcmp L.Fcmp.Oge
        | A.And | A.Or -> raise 
        (Failure "internal error: semant should have rejected and/or on float")
            ) e1' e2' "tmp" builder 
        else (match op with
        | A.Add     -> L.build_add
        | A.Sub     -> L.build_sub
        | A.Mult    -> L.build_mul
        | A.Div     -> L.build_sdiv
        | A.And     -> L.build_and
        | A.Or      -> L.build_or
        | A.Equal   -> L.build_icmp L.Icmp.Eq
        | A.Neq     -> L.build_icmp L.Icmp.Ne
        | A.Less    -> L.build_icmp L.Icmp.Slt
        | A.Leq     -> L.build_icmp L.Icmp.Sle
        | A.Greater -> L.build_icmp L.Icmp.Sgt
        | A.Geq     -> L.build_icmp L.Icmp.Sge
        ) e1' e2' "tmp" builder
          | SUnop(op, e) ->
        let (t, _) = e in
              let e' = expr builder e in
        (match op with
          A.Neg when t = A.Float -> L.build_fneg 
        | A.Neg                  -> L.build_neg
        | A.Not                  -> L.build_not) e' "tmp" builder
    | SAssignList _ -> raise (Failure "NotImplemented1")
    | SCall ((ty, callable), args) -> 
      let function_struct = expr builder (ty, callable) in
      (* Extremely worth reading if you're confused about gep https://www.llvm.org/docs/GetElementPtr.html *)
      let ptr = L.build_struct_gep function_struct 0 "ptr" builder in
      let func_opq = L.build_load ptr "func_opq" builder in
      let func =  L.build_pointercast func_opq (ltype_of_typ ty) "func" builder in
      (* If the func has a null return type, we can't set it to anything (hence the empty string) *)
      (match ty with 
        Arrow(_, Void) -> L.build_call func (Array.of_list (function_struct::(List.map (expr builder) args))) "" builder
      | _              -> L.build_call func (Array.of_list (function_struct::(List.map (expr builder) args))) "result" builder)
    | SRecordAccess(_, _) -> raise (Failure "NotImplemented2")
    | SLambda (_) -> raise (Failure "NotImplemented3")
    in
    
    (* Invoke "instr builder" if the current block doesn't already
       have a terminator (e.g., a branch). *)
    let add_terminal builder instr =
                           (* The current block where we're inserting instr *)
      match L.block_terminator (L.insertion_block builder) with
	      Some _ -> ()
      | None -> ignore (instr builder) in
	
    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)
    (* Imperative nature of statement processing entails imperative OCaml *)
    let rec stmt builder = function
	      SBlock sl -> List.fold_left stmt builder sl
        (* Generate code for this expression, return resulting builder *)
      | SExpr e -> let _ = expr builder e in builder 
      | SReturn e -> 
        let _ = match lambda.st with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder 
                              (* Build return statement *)
                            | _ -> L.build_ret (expr builder e) builder 
                     in builder
      (* The order that we create and add the basic blocks for an If statement
      doesnt 'really' matter (seemingly). What hooks them up in the right order
      are the build_br functions used at the end of the then and else blocks (if
      they don't already have a terminator) and the build_cond_br function at
      the end, which adds jump instructions to the "then" and "else" basic blocks *)
      | SIf (predicate, then_stmt, else_stmt) ->
         let bool_val = expr builder predicate in
         (* Add "merge" basic block to our function's list of blocks *)
	       let merge_bb = L.append_block context "merge" the_function in
         (* Partial function used to generate branch to merge block *) 
         let branch_instr = L.build_br merge_bb in

         (* Same for "then" basic block *)
	       let then_bb = L.append_block context "then" the_function in
         (* Position builder in "then" block and build the statement *)
         let then_builder = stmt (L.builder_at_end context then_bb) then_stmt in
         (* Add a branch to the "then" block (to the merge block) 
           if a terminator doesn't already exist for the "then" block *)
	       let () = add_terminal then_builder branch_instr in

         (* Identical to stuff we did for "then" *)
	       let else_bb = L.append_block context "else" the_function in
         let else_builder = stmt (L.builder_at_end context else_bb) else_stmt in
	       let () = add_terminal else_builder branch_instr in

         (* Generate initial branch instruction perform the selection of "then"
         or "else". Note we're using the builder we had access to at the start
         of this alternative. *)
	       let _ = L.build_cond_br bool_val then_bb else_bb builder in
         (* Move to the merge block for further instruction building *)
	       L.builder_at_end context merge_bb

      | SWhile (predicate, body) ->
          (* First create basic block for condition instructions -- this will
          serve as destination in the case of a loop *)
        let pred_bb = L.append_block context "while" the_function in
          (* In current block, branch to predicate to execute the condition *)
	      let _ = L.build_br pred_bb builder in

          (* Create the body's block, generate the code for it, and add a branch
          back to the predicate block (we always jump back at the end of a while
          loop's body, unless we returned or something) *)
	        let body_bb = L.append_block context "while_body" the_function in
          let while_builder = stmt (L.builder_at_end context body_bb) body in
	        let () = add_terminal while_builder (L.build_br pred_bb) in

          (* Generate the predicate code in the predicate block *)
          let pred_builder = L.builder_at_end context pred_bb in
          let bool_val = expr pred_builder predicate in

          (* Hook everything up *)
          let merge_bb = L.append_block context "merge" the_function in
          let _ = L.build_cond_br bool_val body_bb merge_bb pred_builder in
          L.builder_at_end context merge_bb

      (* Implement for loops as while loops! *)
      | SFor (e1, e2, e3, body) -> stmt builder
	    ( SBlock [SExpr e1 ; SWhile (e2, SBlock [body ; SExpr e3]) ] )
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (SBlock lambda.sbody) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match lambda.st with
        A.Void -> L.build_ret_void
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body lambdas;
  the_module
