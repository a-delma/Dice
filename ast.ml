
(* Abstract Syntax Tree and functions for printing it
 * Based on the MicroC ast file
 * Author(s): 
 * 
 *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or

type uop = Neg | Not

type typ = Int | Bool | Float | Void 
               | Arrow of typ list * typ
               | TypVar of string 
               (* | Struct of string * typ list *)

  
type bind = typ * string

type lambda = {
    t       : typ;         (* Return type *)
    formals : bind list;   (* Parameters  *)
    locals  : bind list; 
    body    : stmt list;
}

and expr =
    Literal of int
  | Fliteral of string
  | BoolLit of bool
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of expr * expr
  | AssignList of typ * ((string * expr) list)
  | Call of expr * expr list
  | RecordAccess of expr * string
  | Lambda of lambda
  | Null
  | Noexpr

and stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt
  (* | Struct of expr *)

type struct_decl = string * bind list

type program = string list * struct_decl list * bind list * stmt list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let rec string_of_typ = function
    Int               -> "Int"
  | Bool              -> "Bool"
  | Float             -> "Float"
  | Void              -> "Void"
  | Arrow  (fst, snd) ->
    "[" ^ String.concat ", " (List.map string_of_typ fst) ^ "]" ^
    " -> " ^ string_of_typ snd
  | TypVar tv         -> tv
  (* | Struct (s, l)    ->
    "Struct " ^ s ^ string_of_typ_list (List.map string_of_typ l) "{" "}" *)
and string_of_typ_list ls open_brac close_brac = 
  match ls with
   [] -> ""
 | ls -> open_brac ^ String.concat ", " ls ^ close_brac

let string_of_typ_var_pair (t, id) = string_of_typ t ^ " " ^ id

let string_of_vdecl decl = string_of_typ_var_pair decl ^ ";\n"

let string_of_typarams = function 
    [] -> ""
  | tps -> "<" ^ String.concat ", "  tps ^ ">"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | Fliteral(l) -> l
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(e1, e2) -> string_of_expr e1 ^ " = " ^ string_of_expr e2
  | AssignList(t, l) -> string_of_typ t ^ "{" ^
      String.concat ", " (List.map string_of_field_assign l) ^ "}"
  | Call(e1, e2) ->
      string_of_expr e1 ^ "(" ^ String.concat ", " (List.map string_of_expr e2) ^ ")"
  | RecordAccess(e, s) -> string_of_expr e ^ "." ^ s
  | Lambda l ->
      "lambda " ^ "(" ^ String.concat ", " (List.map string_of_typ_var_pair l.formals) ^
      ") -> " ^ string_of_typ l.t ^ " " ^ "{\n" ^
      String.concat "" (List.map string_of_vdecl l.locals) ^
      String.concat "" (List.map string_of_stmt l.body) ^
      "}"
  | Null -> "null"
  | Noexpr -> ""


and string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

and string_of_field_assign (id, e) = id ^ ": " ^ string_of_expr e

let string_of_sdecl (name, vdecls) = "struct" ^ 
    name ^ " {\n" ^
    String.concat "" (List.map string_of_vdecl vdecls) ^ "};\n"

let string_of_program (_, structs, vars, stmts) =
  String.concat "" ((List.map string_of_sdecl structs) @
                    (List.map string_of_vdecl vars) @
                    (List.map string_of_stmt stmts))
