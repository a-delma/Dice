open Sast
open Ast
open Closure
open Lambda

module StringMap = Map.Make(String)


(* The main function that takes in a program data type checks all the features
   and returns the SAST program equivalent. *)
let check (struct_decls, globals, stmts) =
(* Check if a certain kind of binding has void type or is a duplicate
    of another, previously checked binding *)
  let check_binds (to_check : bind list) = 
    let name_compare (_, n1) (_, n2) = compare n1 n2 in
    let check_it checked binding = 
        let void_err = "illegal void " ^ snd binding
        and dup_err = "duplicate " ^ snd binding
      in match binding with
        (* No void bindings *)
        (Void, _) -> raise (Failure void_err)
      | (_, n1) -> match checked with
                    (* No duplicate bindings *)
                      ((_, n2) :: _) when n1 = n2 -> raise (Failure dup_err)
                    | _ -> binding :: checked
    in let rec rename_main bindings = match bindings with
        ((t, "main") :: tail) -> (t, "main_") :: rename_main tail
      | list                  -> list
    in let _ = List.fold_left check_it [] (List.sort name_compare to_check) 
        in rename_main to_check
  in 

  let lambdaId = ref 0 in

  let rec check_type env ty = match ty with 
    | Arrow (param_types, ret_type) -> 
        let _ = List.map (check_type env) param_types in
        let _ = check_type env ret_type in ty
    (* Tries to find the struct in the env *)
    | TypVar (name) -> (try StringMap.find name env; ty
        with _ -> raise (Failure (name ^ " is not a defined type.")))
    | Int | Bool | Float | Void -> ty
    
    in
    (* Function to take an sdecl and adds the struct to the environment *)
    let create_struct env (sname, binds) = 
      match StringMap.is_empty (StringMap.find sname env) with
      | true ->  
          let bind_name env' (ty, name) = StringMap.add name (check_type env ty) env' in
          let types = List.fold_left bind_name StringMap.empty binds in
        StringMap.add sname types env
      | _ -> raise (Failure ("Struct: " ^ sname ^ " is already defined"))
    in
    (* Adding the struct names first so they can refer to each other *)
    let empty_structs = List.fold_left 
      (fun env (sname, _) -> StringMap.add sname StringMap.empty env) 
      StringMap.empty struct_decls
    in
    let struct_env = List.fold_left create_struct empty_structs struct_decls in


    (* Takes in a list of type (string * type) and returns the first struct
       with the matching (string -> type) bindings *)
    let struct_from_list binds =
      (* converts the assignment list into a stringmap *)
      let bind_map = List.fold_left 
        (fun env (name, typ) -> StringMap.add name typ env)  StringMap.empty binds in
      (* Function to compare each struct with the given struct *)
      let comp _ types = StringMap.equal (=) bind_map types in
      let filtered_structs = StringMap.filter comp struct_env in
        (* If there were no structs that matched, it will fail *)
        if StringMap.cardinal filtered_structs = 0
          then
            let string_of_bind (name, typ) = (string_of_typ typ) ^ " " ^ name ^ "" in
            let msg = String.concat ", " (List.map string_of_bind binds)in
            raise (Failure ("No struct with types: " ^ msg))
        else 
      TypVar (fst (StringMap.find_first (fun _ -> true) filtered_structs))
  in

  (**** Checking Global Variables ****)
  
  let globals' = check_binds globals in (* TODO: Add putChar and self to globals BEFORE building global_env *)
  let global_env = StringMap.add "putChar" (Arrow([Int], Void)) 
                  (StringMap.add "self"    Void 
                  (List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
                                  StringMap.empty 
                                  globals'))
  in
  (* Return a variable from our symbol table *)
  let rec type_of_identifier s envs = match envs with
      (inner::outer) -> (try StringMap.find s inner
                        with Not_found -> type_of_identifier s outer)
    | []             -> raise (Failure ("Undeclared identifier " ^ s))
  in
  (* Return a semantically-checked expression, i.e., with a type *)
  let rec expr envs expression = match expression with
      Literal  l -> (Int, SLiteral l)
    | Fliteral l -> (Float, SFliteral l)
    | BoolLit l  -> (Bool, SBoolLit l)
    | Id name       -> 
      let sname = if (name = "main") then "main_" else name in 
      (type_of_identifier sname envs, SId sname)
    | Unop(op, e) as ex -> 
      let (t, e') = expr envs e in
      let ty = match op with
        Neg when t = Int || t = Float -> t
      | Not when t = Bool -> Bool
      | _ -> raise (Failure ("Illegal unary operator " ^ 
                            string_of_uop op ^ string_of_typ t ^
                            " in " ^ string_of_expr ex))
      in (ty, SUnop(op, (t, e')))
    | Binop(e1, op, e2) as e -> 
      let (t1, e1') = expr envs e1 
      and (t2, e2') = expr envs e2 in
      (* All binary operators require operands of the same type *)
      (* TODO: DO we want to change this? *)
      let same = t1 = t2 in
      (* Determine expression type based on operator and operand types *)
      let ty = match op with
        Add | Sub | Mult | Div when same && t1 = Int   -> Int
      | Add | Sub | Mult | Div when same && t1 = Float -> Float
      | Equal | Neq            when same               -> Bool
      | Less | Leq | Greater | Geq
                when same && (t1 = Int || t1 = Float) -> Bool
      | And | Or when same && t1 = Bool -> Bool
      | _ -> raise (
        Failure ("Illegal binary operator " ^
                  string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                  string_of_typ t2 ^ " in " ^ string_of_expr e))
      in (ty, SBinop((t1, e1'), op, (t2, e2')))
    | Assign(le, re) -> (match le with 
        Id(s)-> let (lt, _) = expr envs le in
                let (rt, sx) = expr envs re in 
                if lt = rt (* TODO: use custom equality function? *) 
                  then (rt, SAssign((lt ,SId(s)), (rt, sx)))
                  else raise (Failure ("Expected equal types but found " ^ string_of_typ lt ^ " != " ^ string_of_typ rt))
        | RecordAccess (_, _) -> 
          let (lt, lsexper) = expr envs le in
          let (rt, sx) = expr envs re in
          if lt = rt (* TODO: use custom equality function? *) 
            then (rt, SAssign((lt ,lsexper), (rt, sx)))
            else raise (Failure ("Expected equal types but found " ^ string_of_typ lt ^ " != " ^ string_of_typ rt))
          (* (ltyp, SAssign((ltyp, lsexper), (ltyp, lsexper))) *)
        | _ -> raise (Failure "Illegal left side, should be ID or Struct Field"))
    | AssignList(assigns) -> 
      let names, exprs = List.split assigns in
      let sexpers = List.map (expr envs) exprs in
      let typ = struct_from_list (List.combine names (List.map fst sexpers)) in
      (typ, SAssignList(List.combine names sexpers))  
    | Call(callable, args) as call -> 
      let (func_type, callable') = expr envs callable in
      let check_arg param_type arg = 
        let (arg_type, arg') = expr envs arg in 
        if (param_type = arg_type) then (arg_type, arg') else (* TODO: use custom equality function? *) 
          raise (Failure ("Illegal argument found " ^ string_of_typ arg_type ^
          " expected " ^ string_of_typ param_type  ^ " in " ^ string_of_expr arg))
      in 
      (match func_type with
        Arrow((param_types, return_type)) ->
          let param_count = List.length param_types in
          if List.length args == param_count then
            let args' = List.map2 check_arg param_types args in
            (return_type, SCall((func_type, callable'), args'))
          else raise (Failure ("Expecting " ^ string_of_int param_count ^ " arguments in " ^ string_of_expr call))
        | _ -> raise (Failure ("Type " ^ string_of_typ func_type ^ " is not a function type"))
      )  
    | RecordAccess(struct_expr, field)  -> 
      let (ev_expr_ty, ev_expr_sx) = expr envs struct_expr in
      let field_ty = (match ev_expr_ty with
        TypVar name -> 
          let this_stuct = try StringMap.find name struct_env 
                           with _ -> raise (Failure (name ^ " is not a valid struct type.")) in
          let this_ty    = try StringMap.find field this_stuct 
                          with _ -> raise (Failure (field ^ " is not a field of type " ^ name)) in
            this_ty
        | _ -> raise (Failure ("Invalid struct access on type " ^ (string_of_typ ev_expr_ty))))
      in (field_ty, SRecordAccess ((ev_expr_ty, ev_expr_sx), field))
    | Lambda l         -> 
      let func_type = Arrow(List.map fst l.formals, l.t) in
      let locals'   = check_binds l.locals @ l.formals in
      (* TODO: Add "self" to locals BEFORE constructing local_env and check it is not in formals *)
      let local_env = List.fold_left 
                      (fun m (ty, name) -> StringMap.add name ty m)
                      (StringMap.add "self" func_type StringMap.empty)
                      locals' in (* TODO: Does this concatenation mean we can't check for shadowing? *)
                                 (* TODO: It does. I think we should change LRM to reflect that. *)
      let body      = (match (check_stmt (local_env::envs) (Block l.body)) with
          SBlock(sl) -> sl
        | _          -> raise (Failure "Block didn't become a block?")) (* TODO: Why does microc has this? *)  
      in let newId = !lambdaId
      in let _ = lambdaId := newId + 1 
      in (func_type, SLambda({st=l.t; 
                    sid="lambda" ^ (string_of_int newId); 
                    sformals=l.formals; (* TODO: rename main here? *)
                    slocals=l.locals; 
                    sclosure=closure_stmt (local_env::envs) (SBlock (body)); 
                    sbody=body}))
    | Noexpr         -> (Void, SNoexpr)

  and check_bool_expr envs e = 
    let (t', e') = expr envs e
    and err = "Expected Boolean or Float expression in " ^ string_of_expr e
    in if not ((t' = Bool) || (t' = Float)) (* TODO: use custom equality function? *) 
      then raise (Failure err) else (t', e') 

  (* Return a semantically-checked statement i.e. containing sexprs *)
  and check_stmt envs statement = match statement with
      Expr e -> SExpr (expr envs e)
    | If(p, b1, b2) -> SIf(check_bool_expr envs p, check_stmt envs b1, check_stmt envs b2)
    | For(e1, e2, e3, st) ->
        SFor(expr envs e1, check_bool_expr envs e2, expr envs e3, check_stmt envs st)
    | While(p, s) -> SWhile(check_bool_expr envs p, check_stmt envs s)
    | Return e -> 
      let (t, e')   = expr envs e in
      let func_type = match (type_of_identifier "self" envs) with
        Arrow(_, return_type) -> return_type
      | _ -> raise (Failure "Return in nonfunction-type")
      in
      if t = func_type then SReturn (t, e') 
      else raise (Failure ("Return yields type " ^ string_of_typ t ^ " while " ^
                          string_of_typ func_type ^ " expected in " ^ string_of_expr e))
    | Block sl -> 
        let rec check_stmt_list = function
            [Return _ as s] -> [check_stmt envs s]
          | Return _ :: _   -> raise (Failure "Nothing may follow a return")
          (* TODO: does flattening works differently in Dice because of lambdas? *)
          | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
          | s :: ss         -> check_stmt envs s :: check_stmt_list ss
          | []              -> []
        in SBlock(check_stmt_list sl)
      in
      (* Body of check *)
  let sstmts = List.map (fun stmt -> check_stmt [global_env] stmt) stmts in
  let main   = {st=Int; 
                sid="main"; 
                sformals=[]; 
                slocals=[]; 
                sclosure=[];
                sbody=sstmts}
  in (struct_env, globals', main::lambda_from_stmt (SBlock sstmts))
