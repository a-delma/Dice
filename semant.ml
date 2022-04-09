open Sast
open Ast
open Closure

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

    in let _ = List.fold_left check_it [] (List.sort name_compare to_check) 
        in to_check
  in 
  
  let rec conv_type env = function 
      | Int -> SInt
      | Bool -> SBool
      | Float -> SFloat
      | Void -> SVoid
      | Arrow (param_types, ret_type) -> 
          let sparams = 
            List.map (fun (ty) -> conv_type env ty) param_types in
          let ret_stype = conv_type env ret_type in
            SArrow(sparams, ret_stype)
      | TypVar (name) -> try SStruct(name, StringMap.find name env) 
          with _ -> raise (Failure (name ^ " is not a defined type."))
  in
    let create_struct env (sname, binds) = 
      match StringMap.find_opt sname env with
      | None -> let sbinds = List.map (fun (typ) -> conv_type env typ) (List.map fst binds) 
        in StringMap.add sname sbinds env
      | Some _ -> raise (Failure ("Struct: " ^ sname ^ " is already defined"))
    in
    let struct_env = List.fold_left create_struct StringMap.empty struct_decls in
    let _ = List.map (fun ((ty, _)) -> conv_type struct_env ty) globals in 

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
    | Id s       -> (type_of_identifier s envs, SId s)
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
        | RecordAccess(_, _) -> raise (Failure "NotImplementedStructStuff")
        | _ -> raise (Failure "Illegal left side, should be ID or Struct Field"))
    | AssignList(_) -> raise (Failure "NotImplemented")  
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
    | RecordAccess(_)  -> raise (Failure "NotImplemented")  
    | Lambda l         ->
      let func_type = Arrow(List.map fst l.formals, l.t) in
      let locals'   = check_binds l.locals in
      let formals'  = check_binds l.formals in
      (* TODO: Add "self" to locals BEFORE constructing local_env and check it is not in formals *)
      let local_env = List.fold_left 
                      (fun m (ty, name) -> StringMap.add name ty m)
                      (StringMap.add "self" func_type StringMap.empty)
                      (formals' @ locals') in (* Does this concatenation mean we can't check for shadowing? *)
      let body      = (match (check_stmt (local_env::envs) (Block l.body)) with
          SBlock(sl) -> sl
        | _          -> raise (Failure "Block didn't become a block?")) (* TODO: Why does microc has this? *)  
      in (func_type, SLambda({st=l.t; 
                    sid="TODO"; 
                    sformals=l.formals; 
                    slocals=l.locals; 
                    sclosure=closure_stmt (local_env::envs) (SBlock (body)); (* TODO: Compute closure! *)
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
    (* A block is correct if each statement is correct and nothing
        follows any Return statement.  Nested blocks are flattened. *)
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
  (struct_decls, globals', List.map (fun stmt -> check_stmt [global_env] stmt)
                                    stmts)
