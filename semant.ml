open Sast
open Ast
open Closure
open Lambda

module StringMap = Map.Make(String)


(* The main function that takes in a program data type checks all the features
   and returns the SAST program equivalent. *)
let check (_, struct_decls, globals, stmts) =
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

    (* creates an additional map of field to index for accessing values *)
    let struct_indices = 
      let map_func struc =
        let fold_func key _ (acc, index) = 
          (StringMap.add key index acc, index + 1) 
        in let (new_indices, _) = StringMap.fold fold_func struc (StringMap.empty, 0) in 
      new_indices 
    in StringMap.map map_func struct_env in

  let lookup_field_type typ name = match typ with 
      TypVar(typname) -> 
        let binds = (try StringMap.find typname struct_env 
                      with _ -> raise (Failure ("Undefined struct " ^ typname)))
        in (try StringMap.find name binds 
            with _ -> raise (Failure ("Struct " ^ typname ^ " does not have field " ^ name))) 
    | _ -> raise (Failure ("Type " ^ string_of_typ typ ^ " is not a struct type"))
  in

  let is_not_primitive = function 
                  Arrow(_,_)  -> true
                | TypVar(_)   -> true 
                | _           -> false in  

  (**** Checking Global Variables ****)
  let globals = [(Arrow([Int], Void),  "putChar" ); 
                 (Arrow([],    Float), "uni"    );
                 (Arrow([Int], Void),  "setSeed");
                 (Arrow([Int], Void),  "self");
                 (Arrow([Float], Void),"printFloat");
                 (Arrow([Int], Float), "intToFloat");
                 (Arrow([Int], Bool), "intToBool");
                 (Arrow([Float], Int), "floatToInt");
                 (Arrow([Float], Bool), "floatToBool");
                 (Arrow([Bool], Float), "boolToFloat");
                 (Arrow([Bool], Int), "boolToInt");] @ globals in
  let globals' = check_binds globals in 
  let global_env = (List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
                                  StringMap.empty 
                                  globals')
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
      let nullComparison = (t1 = Void && is_not_primitive t2) || (t2 = Void && is_not_primitive t1) in
      let same = t1 = t2 in
      let bothNum = ((t1 = Int)||(t1 = Float))&&((t2 = Int)||(t2 = Float)) in
      (* Determine expression type based on operator and operand types *)
      let ty = match op with
        Add | Sub | Mult | Div     when same && t1 = Int                       -> Int
      | Add | Sub | Mult | Div     when bothNum                                -> Float
      | Equal | Neq                when same || bothNum || nullComparison      -> Bool
      | Less | Leq | Greater | Geq when bothNum                                -> Bool
      | And | Or when same && t1 = Bool -> Bool
      | _ -> raise (
        Failure ("Illegal binary operator " ^
                  string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                  string_of_typ t2 ^ " in " ^ string_of_expr e)) in
          let finalSB = if same
                        then (ty, SBinop((t1, e1'), op, (t2, e2')))
                        else if nullComparison
                             then if t1 = Void
                                  then (ty, SBinop((t2, SNullPointerCast(t2, (Void, e1'))), op, (t2, e2')))
                                  else (ty, SBinop((t1, e1'), op, (t1, SNullPointerCast(t1, (Void, e2')))))
                             else if t1 = Int
                                  then (ty, SBinop((Float, SCall((Arrow([Int], Float), SId "intToFloat"), [(t1, e1')])), op, (t2, e2')))
                                  else if t2 = Int 
                                       then (ty, SBinop((t1, e1'), op, (Float, SCall((Arrow([Int], Float), SId "intToFloat"), [(t2, e2')]))))
                                       else if t1 = Bool
                                            then (ty, SBinop((t1, e1'), op, (Bool, SCall((Arrow([Float], Bool), SId "floatToBool"), [(t2, e2')]))))
                                            else (ty, SBinop((Bool, SCall((Arrow([Float], Bool), SId "floatToBool"), [(t1, e1')])), op, (t2, e2')))
          in finalSB
    | Assign(le, re) -> (match le with 
        Id(_) | RecordAccess(_, _) ->
          let (lt, lse) = expr envs le in
          let (rt, rse) = expr envs re in
          if lt = rt
            then (rt, SAssign((lt ,lse), (rt, rse)))
            else if (rt = Void && (is_not_primitive lt))
            then (lt, SAssign((lt ,lse), (lt, SNullPointerCast(lt, (rt, rse)))))
            else raise (Failure ("Expected equal types but found " ^ string_of_typ lt ^ " != " ^ string_of_typ rt))
      | _ -> raise (Failure "Illegal left side, should be ID or Struct Field"))
    | AssignList(typ, assigns) -> 
      let get_checked_bind = function 
        (name, e) -> let (sexpr_type, sx) as sexpr = expr envs e in
                     let field_type = lookup_field_type typ name in
                     if (field_type = sexpr_type)
                     then (name, sexpr)
                     else if (sexpr_type = Void && is_not_primitive field_type) 
                     then (name, (field_type, SNullPointerCast(field_type, (sexpr_type, sx))))
                     else raise (Failure ("Field " ^ name ^ " of type " ^ 
                                          string_of_typ typ ^ " has type " ^ 
                                          string_of_typ field_type ^ " but expression " ^ 
                                          string_of_expr e ^ " has type " ^ 
                                          string_of_typ sexpr_type)) 
      in let sbinds = List.map get_checked_bind assigns
      in (typ, SAssignList(typ, sbinds)) 
    | Call(callable, args) as call -> 
      let (func_type, callable') = expr envs callable in
      let check_arg param_type arg = 
        let (arg_type, arg') = expr envs arg in 
        if (param_type = arg_type) 
        then (arg_type, arg') 
        else if (arg_type = Void && is_not_primitive param_type)
        then (param_type, SNullPointerCast(param_type, (arg_type, arg')))  
        else raise (Failure ("Illegal argument found " ^ string_of_typ arg_type ^
                             " expected " ^ string_of_typ param_type  ^ " in " ^ 
                             string_of_expr arg))
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
      let locals'   = check_binds l.locals @ l.formals @ [(func_type, "self")]in
      let local_env = (List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
                      StringMap.empty 
                      locals') in (* TODO: Does this concatenation mean we can't check for shadowing? *)
                                 (* TODO: It does. I think we should change LRM to reflect that. *)
      let body      = (match (check_stmt (local_env::envs) (Block l.body)) with
          SBlock(sl) -> sl
        | _          -> raise (Failure "Block didn't become a block?")) (* TODO: Why does microc has this? *)  
      in let newId = !lambdaId
      in let _ = lambdaId := newId + 1 
      in (func_type, SLambda({st=l.t; 
                    sid="lambda" ^ (string_of_int newId); 
                    sformals=(func_type, "self")::l.formals; (* TODO: rename main here? *)
                    slocals=l.locals; 
                    sclosure=closure_stmt (local_env::envs) (SBlock (body)); 
                    sbody=body}))
    | Null           -> (Void, SNull)
    | Noexpr         -> (Void, SNoexpr)

    and check_bool_expr envs e = 
    let (t', e') = expr envs e
    and err = "Expected Boolean or Float expression in " ^ string_of_expr e
    in if not ((t' = Bool) || (t' = Float)) (* TODO: use custom equality function? *) 
      then raise (Failure err)
      else if t' = Float
           then (Bool, SCall((Arrow([Float], Bool), SId "floatToBool"), [(t', e')]))
           else (t', e') 

  (* Return a semantically-checked statement i.e. containing sexprs *)
  and check_stmt envs statement = match statement with
      Expr e -> SExpr (expr envs e)
    | If(p, b1, b2) -> SIf(check_bool_expr envs p, check_stmt envs b1, check_stmt envs b2)
    | For(e1, e2, e3, st) ->
        SFor(expr envs e1, check_bool_expr envs e2, expr envs e3, check_stmt envs st)
    | While(p, s) -> SWhile(check_bool_expr envs p, check_stmt envs s)
    | Return e -> 
    (* TODO check for returning nothing (walk the AST and check that something returns the type we expect) *)
      let (t, e')   = expr envs e in
      let func_type = match (type_of_identifier "self" envs) with
        Arrow(_, return_type) -> return_type
      | _ -> raise (Failure "Return in nonfunction-type")
      in
      if t = func_type 
      then SReturn (t, e') 
      else if (t = Void && is_not_primitive func_type)
      then SReturn (func_type, SNullPointerCast(func_type, (t, e')))
      else raise (Failure ("Return yields type " ^ string_of_typ t ^ " while " ^
                          string_of_typ func_type ^ " expected in return " ^ string_of_expr e))
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
                sformals=[(Arrow([], Int), "self")]; 
                slocals=[]; 
                sclosure=[];
                sbody=sstmts}
  in let lambdas = create_lambda_list (SBlock sstmts)
  in let _ = return_pass lambdas
  in ((struct_env, struct_indices), globals', main::lambdas)