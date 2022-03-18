open Ast
open Sast

module StringMap = Map.Make(String)

(* TODO *)
let symbols = StringMap.add "putChar" (Arrow([], [Int], Void)) StringMap.empty

(* Return a variable from our local symbol table *)
let type_of_identifier s =
  try StringMap.find s symbols
  with Not_found -> raise (Failure ("Undeclared identifier " ^ s))

let types_are_equal typ1 typ2 =
  true (* TODO recursive type comparison. NO exception raising*) 

(* Return a semantically-checked expression, i.e., with a type *)
let rec expr = function
    Literal  l -> (Int, SLiteral l)
  | Fliteral l -> (Float, SFliteral l)
  | BoolLit l  -> (Bool, SBoolLit l)
  | Id s       -> (type_of_identifier s, SId s)
  | Unop(op, e) as ex -> 
    let (t, e') = expr e in
    let ty = match op with
      Neg when t = Int || t = Float -> t
    | Not when t = Bool -> Bool
    | _ -> raise (Failure ("Illegal unary operator " ^ 
                          string_of_uop op ^ string_of_typ t ^
                          " in " ^ string_of_expr ex))
    in (ty, SUnop(op, (t, e')))
  | Binop(e1, op, e2) as e -> 
    let (t1, e1') = expr e1 
    and (t2, e2') = expr e2 in
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
  | Assign(_) -> raise (Failure "NotImplemented")
    (*let lt = type_of_identifier var
    and (rt, e') = expr e in
    let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
      string_of_typ rt ^ " in " ^ string_of_expr ex
    in (check_assign lt rt err, SAssign(var, (rt, e')))*)
  | AssignList(l) -> raise (Failure "NotImplemented")  
  | Call(callable, args) as call -> 
    let (func_type, callable') = expr callable in
    let check_arg param_type arg = 
      let (arg_type, arg') = expr arg in 
      if (types_are_equal param_type arg_type) then (arg_type, arg') else
        raise (Failure ("Illegal argument found " ^ string_of_typ arg_type ^
        " expected " ^ string_of_typ param_type  ^ " in " ^ string_of_expr arg))
    in 
    (match func_type with
      Arrow((_, param_types, return_type)) ->
        let param_count = List.length param_types in
        if List.length args == param_count then
          let args' = List.map2 check_arg param_types args in
          (return_type, SCall((func_type, callable'), args'))
        else raise (Failure ("Expecting " ^ string_of_int param_count ^ " arguments in " ^ string_of_expr call))
      | _ -> raise (Failure ("Type " ^ string_of_typ func_type ^ " is not a function type"))
    )  
  | RecordAccess(_)  -> raise (Failure "NotImplemented")  
  | Lambda(_)        -> raise (Failure "NotImplemented")  
  | Noexpr           -> (Void, SNoexpr)

let check_bool_expr e = 
  let (t', e') = expr e
  and err = "Expected Boolean or Float expression in " ^ string_of_expr e
  in if (types_are_equal t' Bool) || (types_are_equal t' Float) 
     then raise (Failure err) else (t', e') 

(* Return a semantically-checked statement i.e. containing sexprs *)
let rec check_stmt = function
    Expr e -> SExpr (expr e)
  | If(p, b1, b2) -> SIf(check_bool_expr p, check_stmt b1, check_stmt b2)
  | For(e1, e2, e3, st) ->
SFor(expr e1, check_bool_expr e2, expr e3, check_stmt st)
  | While(p, s) -> SWhile(check_bool_expr p, check_stmt s)
  | Return e -> raise (Failure "NotImplemented")
    (*let (t, e') = expr e in
    if t = func.typ then SReturn (t, e') 
    else raise (
Failure ("return gives " ^ string_of_typ t ^ " expected " ^
    string_of_typ func.typ ^ " in " ^ string_of_expr e))
  (* A block is correct if each statement is correct and nothing
      follows any Return statement.  Nested blocks are flattened. *)*)
  | Block sl -> raise (Failure "NotImplemented")
      (*let rec check_stmt_list = function
          [Return _ as s] -> [check_stmt s]
        | Return _ :: _   -> raise (Failure "Nothing may follow a return")
        | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
        | s :: ss         -> check_stmt s :: check_stmt_list ss
        | []              -> []
      in SBlock(check_stmt_list sl)*)

let check (struct_decls, globals, stmts) =
  (struct_decls, globals, List.map check_stmt stmts)