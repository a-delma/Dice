(* Code generation: translate takes a semantically checked AST and
produces LLVM IR *)

module L = Llvm
module A = Ast
open Sast

module StringMap = Map.Make(String)

(* Code Generation from the SAST. Returns an LLVM module if successful,
   throws an exception if something is wrong. *)
let translate ((struct_decls, struct_indices), globals, lambdas) =
  let context    = L.global_context ()
  (* Add types to the context so we can use them in our LLVM code *)
  in let     i32_t      = L.i32_type    context
  in let     i1_t       = L.i1_type     context
  in let     float_t    = L.float_type context
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

  let struct_dict = 
    let make_empty name _ = L.named_struct_type context name in
    StringMap.mapi make_empty struct_decls
  in


  (* Convert Dice types to LLVM types *)
  let ltype_of_typ = function
      A.Int   -> i32_t 
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | A.Arrow(_) -> func_struct_ptr
    | A.TypVar (name) -> try L.pointer_type (StringMap.find name struct_dict)
      with _ -> raise (Failure (name ^ " is not a valid struct type"))
    in    

  let ltype_of_func_type = function
      A.Arrow(args, ret) -> L.pointer_type(L.function_type (ltype_of_typ ret) 
                            (Array.of_list (func_struct_ptr::(List.map ltype_of_typ args))))
    | _                  -> raise (Failure "Invalid function cast")                 
  in

  let make_struct_body name type_dict =
    let (_, types) = List.split (StringMap.bindings type_dict) in
    let ltypes_list = List.map ltype_of_typ types in (* TODO: might need to call a different type convertion fucntion*)
    let ltypes = Array.of_list ltypes_list in
    L.struct_set_body (StringMap.find name struct_dict) ltypes false
  in

  let _ = StringMap.mapi make_struct_body struct_decls in
  
  let lookup_index typ name = match typ with
    | A.TypVar(st_name) -> 
      let index_map = StringMap.find st_name struct_indices in
      StringMap.find name index_map
    | _ -> raise (Failure "indexing non struct type") 
    in

  let getnode_func = L.declare_function 
                     "get_node" 
                     (L.function_type void_ptr_t [| node_struct_ptr ; i32_t |]) the_module in

  let append_func = L.declare_function 
                     "append_to_list" 
                     (L.function_type node_struct_ptr [| node_struct_ptr ; void_ptr_t |]) the_module in

  let malloc_func  = L.declare_function 
                     "malloc_" 
                     (L.function_type void_ptr_t [| i32_t |]) the_module in
  
  let putchar_struct = (L.declare_global func_struct_ptr "putchar_" the_module) in
               let _ = L.set_externally_initialized true putchar_struct     in

  let print_float_struct = (L.declare_global func_struct_ptr "print_float_" the_module) in
               let _ = L.set_externally_initialized true print_float_struct in

  let uni_struct = (L.declare_global func_struct_ptr "uni_" the_module) in
               let _ = L.set_externally_initialized true uni_struct     in

  let set_seed_struct = (L.declare_global func_struct_ptr "set_seed_" the_module) in
               let _ = L.set_externally_initialized true uni_struct     in
               
  let int_to_float_struct = (L.declare_global func_struct_ptr "int_to_float_" the_module) in
               let _ = L.set_externally_initialized true int_to_float_struct     in

  let float_to_int_struct = (L.declare_global func_struct_ptr "float_to_int_" the_module) in
               let _ = L.set_externally_initialized true float_to_int_struct     in
  
  let init_func = L.declare_function
                  "initialize"
                  (L.function_type void_t [||]) the_module in 

  let init t = match t with
    | A.Float -> L.const_float (ltype_of_typ t) 0.0
    | A.Arrow(_,_) -> L.const_null func_struct_ptr
    | A.TypVar(name) -> L.const_named_struct (ltype_of_typ (A.TypVar name)) [||]
    | _ -> L.const_int (ltype_of_typ t) 0
  in

  (* Declare each global variable; remember its value in a map *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n) = 
      let init_value = init t
      in StringMap.add n (L.define_global n init_value the_module) m in
    List.fold_left global_var StringMap.empty globals in
  let global_vars = StringMap.add "putChar" putchar_struct global_vars in
  let global_vars = StringMap.add "uni" uni_struct global_vars in
  let global_vars = StringMap.add "setSeed" set_seed_struct global_vars in
  let global_vars = StringMap.add "intToFloat" int_to_float_struct global_vars in
  let global_vars = StringMap.add "floatToInt" float_to_int_struct global_vars in
  let global_vars = StringMap.add "printFloat" print_float_struct global_vars in

  
  (* Define each function (arguments and return type) so we can 
   * define it's body and call it later *)
  let function_decls =
    let function_decl m lambda =
      let name = lambda.sid in
      let formals_list = 
        (List.map (fun (t,_) -> ltype_of_typ t) lambda.sformals) in
      let formals_array = Array.of_list formals_list
      in let ftype = L.function_type (ltype_of_typ lambda.st) formals_array in
      StringMap.add name (L.define_function name ftype the_module, lambda) m in
      List.fold_left function_decl StringMap.empty lambdas in

  (* Fill in the body of the given function *)
  let build_function_body lambda =

    let (the_function, _) = StringMap.find lambda.sid function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let _ = if lambda.sid = "main"
            then ignore(L.build_call init_func [||] "" builder) (* TODO: What is this for? *)
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
    let closure = 
      if lambda.sid = "main"
      then StringMap.empty else
      let function_ptr = (Array.get (L.params the_function) 0) in
      (* let function_val = L.build_load function_ptr "function" builder in *)
      let closure_ptr  = L.build_struct_gep function_ptr 1 "closure_ptr" builder in
      let loaded_closure_ptr = L.build_load closure_ptr "loaded_closure_ptr" builder in
      let add_closure (m,i) (t, n) =
        let void_ptr = L.build_call getnode_func [|loaded_closure_ptr; L.const_int i32_t i|] "node_" builder in
        let arg_ptr = L.build_pointercast void_ptr (L.pointer_type (ltype_of_typ t)) "arg_ptr" builder in
        let value = L.build_load arg_ptr "arg" builder in
      (* let closure_elem = L.build_alloca (ltype_of_typ t) n builder *)
        (StringMap.add n value m, i + 1)
    in
      fst (List.fold_left add_closure (StringMap.empty, 0) lambda.sclosure)
    in
    (* Return the value for a variable or formal argument. First check
     * locals, then globals *)
    let lookup n  = try (StringMap.find n local_vars, true)
                    with Not_found -> (try (StringMap.find n closure, false)
                                      with Not_found -> (try (StringMap.find n global_vars, true)
                                                         with Not_found -> raise (Failure ("Cannot find variable " ^ n))))          
    in

    let malloc (t : L.lltype) (malloc_b : L.llbuilder) = 
        let    opaque_size  = L.build_gep (L.const_null (L.pointer_type (L.pointer_type t))) [|L.const_int i32_t 1|] "opaque_size" malloc_b
        in let size         = L.build_pointercast opaque_size (i32_t) "size_" malloc_b
        in let opaque_value = L.build_call malloc_func [|size|] "opaque_value" malloc_b
        in L.build_pointercast opaque_value (L.pointer_type t) "value_" malloc_b
    in
    (* Construct code for an expression; return its value *)
    let rec expr builder ((_, e) : sexpr) = match e with
        SLiteral i -> L.const_int i32_t i
      | SBoolLit b -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      | SNoexpr -> L.const_int i32_t 0
      | SId s -> (match (lookup s) with
        | (v, true) -> L.build_load v s builder
        | (v, false) -> v)
      | SAssign((t, le), rse) -> 
          let rse' = (match (fst rse) with 
          (* TODO rework this to actually create the llvm code for the function*)
            A.Void -> let _ = expr builder rse in (L.const_null (ltype_of_typ t))
          | _      -> expr builder rse) in
          (match le with 
          SId(s)-> 
            let le', _  = (lookup s) in
            (* TODO include the null case for struct fields as well *)
            let _ = L.build_store rse' le' builder in expr builder (t, le)
          | SRecordAccess((ty, exp), field) ->
            let llstruct = expr builder (ty, exp) in
            let index = lookup_index ty field in
            let elm_ptr = L.build_struct_gep llstruct index (field ^ "_ptr") builder in
            let _ = L.build_store rse' elm_ptr builder in
            rse'
          | _ -> raise (Failure "Illegal left side, should be ID or Struct Field"))
      | SBinop (e1, op, e2) ->
        let (lt, _) = e1
        and (rt, _) = e2
        and e1' = expr builder e1
        and e2' = expr builder e2 in
          (* TODO implement not equal as well *)
        (match op with 
          A.Equal  when lt = A.Void -> L.build_is_null e2' "null_cmp" builder 
        | A.Neq    when lt = A.Void -> L.build_is_not_null e2' "null_cmp" builder 
        | A.Equal  when rt = A.Void -> L.build_is_null e1' "null_cmp" builder 
        | A.Neq    when rt = A.Void -> L.build_is_not_null e1' "null_cmp" builder 
        | _ -> if lt = A.Float then (match op with 
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
            ) e1' e2' "tmp" builder)
    | SUnop(op, e) ->
            let (t, _) = e in
                  let e' = expr builder e in
            (match op with
              A.Neg when t = A.Float -> L.build_fneg 
            | A.Neg                  -> L.build_neg
            | A.Not                  -> L.build_not) e' "tmp" builder
    | SAssignList (ty, binds) ->
      let pty = ltype_of_typ ty in
      let lty = L.element_type pty in (* getting the type of the struct *)
      let names, values = (List.split binds) in

      (* ordering the values to be placed in the struct *)
      let indices = List.map (lookup_index ty) names in
      let llvalues = List.map (expr builder) values in

      let sort_fun (_,s1) (_,s2) = s1 - s2 in
      let order_values_pairs = List.sort sort_fun (List.combine llvalues indices) in
      (* let ordered_values = (fst (List.split order_values_pairs)) in *)
      
      (* creating default values to make an empty struct *)
      let name = match ty with 
        | A.TypVar (n) -> n
        | _ -> raise (Failure "Building of non struct type") in
      let types = (snd (List.split (StringMap.bindings (StringMap.find name struct_decls)))) in
      let init_values = List.map init types in
      let array_of_inits = Array.of_list init_values in
      let init_struct = L.const_named_struct lty array_of_inits in
      let add_elem acc (value, index) = L.build_insertvalue acc value index "building_struct" builder in
      let lstruct = List.fold_left add_elem init_struct order_values_pairs in
      let str_ptr = malloc lty builder in
      let _ = L.build_store lstruct str_ptr builder in
      str_ptr
      (* SCall of null should be an error *)
    | SCall ((ty, callable), args) -> 
      let function_struct = expr builder (ty, callable) in
      (* Extremely worth reading if you're confused about gep https://www.llvm.org/docs/GetElementPtr.html *)
      let ptr = L.build_struct_gep function_struct 0 "ptr" builder in
      let func_opq = L.build_load ptr "func_opq" builder in
      let func =  L.build_pointercast func_opq (ltype_of_func_type ty) "func" builder in
      (* If the func has a null return type, we can't set it to anything (hence the empty string) *)
      (match ty with 
        A.Arrow(_, A.Void) -> L.build_call func (Array.of_list (function_struct::(List.map (expr builder) args))) "" builder
      | _              -> L.build_call func (Array.of_list (function_struct::(List.map (expr builder) args))) "result" builder)
    | SRecordAccess((ty, exp), field) -> 
      let llstruct = expr builder (ty, exp) in
      let index = lookup_index ty field in 
      let elm_ptr = L.build_struct_gep llstruct index field builder 
      in L.build_load elm_ptr field builder
    | SNull -> L.undef void_t
    | SLambda (l) -> 
      let add_argument closure (ty, id) = 
        let llvalue = expr builder (ty, SId id)
        in let malloc_arg = malloc (ltype_of_typ ty) builder
        in let _ = L.build_store llvalue malloc_arg builder
        in let opaque_arg = L.build_pointercast malloc_arg void_ptr_t "ptr_" builder
        in L.build_call append_func [|closure; opaque_arg|] "new_closure" builder
      in let function_struct = malloc func_struct builder 
      in let closure_struct = L.const_null node_struct_ptr
      in let full_closure = List.fold_left add_argument closure_struct l.sclosure
      in let closure_ptr = L.build_struct_gep function_struct 1 "ptr_" builder 
      in let _ = L.build_store full_closure closure_ptr builder
      in let func_ptr = L.build_struct_gep function_struct 0 "ptr_" builder 
      in let func_opaque = L.build_pointercast (fst (StringMap.find l.sid function_decls) )
                                                func_ptr_t "func_opaque" builder
      in let _ = L.build_store func_opaque func_ptr builder
      in function_struct
    (* TODO SNoexpr to get rid of pattern matching warning? *)

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
