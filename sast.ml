(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sLambdaBody = {
    styp : typ; (* Function type *)
    spolytype : bind list; (* Type Variables *)
    sformals : bind list; (* Parameters *)
    sbody : sstmt list;
  }
  
and sexpr = typ * sx
and sx =
    SLiteral of int
  | SFliteral of string
  | SBoolLit of bool
  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SAssign of sexpr * sexpr
  | SAssignList of (string * sexpr) list
  | SCall of sexpr * sexpr list
  | SRecordAccess of sexpr * string
  | SLambda of string list * typ * bind list * bind list * sstmt list
  | SNoexpr

and sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SFor of sexpr * sexpr * sexpr * sstmt
  | SWhile of sexpr * sstmt
  (* | SStruct of sexpr *)

type sfunc_decl = {
  styp : typ;
  sfname : string;
  sformals : bind list;
  slocals : bind list;
  sbody : sstmt list;
}

type sprogram = struct_decl list * bind list * sstmt list

(* Pretty-printing functions *)

let rec string_of_sexpr(sexpression) = match (snd sexpression) with
    SLiteral(l) -> string_of_int l
  | SFliteral(l) -> l
  | SBoolLit(true) -> "true"
  | SBoolLit(false) -> "false"
  | SId(s) -> s
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SAssign(e1, e2) -> string_of_sexpr e1 ^ " = " ^ string_of_sexpr e2
  | SAssignList(l) -> "{" ^
      String.concat ", " (List.map string_of_sfield_assign l) ^ "}"
  | SCall(e1, e2) ->
      string_of_sexpr e1 ^ "(" ^ String.concat ", " (List.map string_of_sexpr e2) ^ ")"
  | SRecordAccess(e, s) -> string_of_sexpr e ^ "." ^ s
  | SLambda(tps, t, f, v, s) ->
      "lambda " ^ string_of_typ_list tps "<" ">" ^ "(" ^ String.concat ", " (List.map string_of_typ_var_pair f) ^
      ") -> " ^ string_of_typ t ^ " " ^ "{\n" ^
      String.concat "" (List.map string_of_vdecl v) ^
      String.concat "" (List.map string_of_sstmt s) ^
      "}"
  | SNoexpr -> ""


and string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  | SIf(e, s, SBlock([])) -> "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SFor(e1, e2, e3, s) ->
      "for (" ^ string_of_sexpr e1  ^ " ; " ^ string_of_sexpr e2 ^ " ; " ^
      string_of_sexpr e3  ^ ") " ^ string_of_sstmt s
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s

and string_of_sfield_assign (id, e) = id ^ ": " ^ string_of_sexpr e

let string_of_sprogram (structs, vars, stmts) =
  String.concat "" ((List.map string_of_sdecl structs) @
                    (List.map string_of_vdecl vars) @
                    (List.map string_of_sstmt stmts))