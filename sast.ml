(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

module StringMap = Map.Make(String)


type sLambda = {
    st       : typ;         (* Return type *)
    sid      : string;      (* A unique ID *)
    sformals : bind list;   (* Parameters  *)
    slocals  : bind list; 
    sclosure : bind list;
    sbody    : sstmt list;
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
  | SAssignList of typ * (string * sexpr) list
  | SCall of sexpr * sexpr list
  | SRecordAccess of sexpr * string
  | SLambda of sLambda
  | SNoexpr

and sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SFor of sexpr * sexpr * sexpr * sstmt
  | SWhile of sexpr * sstmt



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
  | SAssignList(_, l) -> "{" ^
      String.concat ", " (List.map string_of_sfield_assign l) ^ "}"
  | SCall(e1, e2) ->
      string_of_sexpr e1 ^ "(" ^ String.concat ", " (List.map string_of_sexpr e2) ^ ")"
  | SRecordAccess(e, s) -> string_of_sexpr e ^ "." ^ s
  | SLambda l->
      "lambda " ^ "(" ^ String.concat ", " (List.map string_of_typ_var_pair l.sformals) ^
      ") -> " ^ string_of_typ l.st ^ " " ^ "{\n" ^
      String.concat "" (List.map string_of_vdecl l.slocals) ^
      String.concat "" (List.map string_of_sstmt l.sbody) ^ "Closure: " ^
      String.concat "" (List.map string_of_vdecl l.sclosure) ^
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

and string_of_bind (name, typ) = (string_of_typ typ) ^ " " ^ name ^ ";\n" 

and string_of_senv (_, indices) =
    let fold_func key data acc =
        let indices = List.fold_left 
            (fun str (field, index) -> str ^ "\t" ^ (string_of_int index ^ " : " ^ field ^ ";\n") ) "" (StringMap.bindings data) in
        let struct_string = "struct " ^ key ^ " {\n" ^ indices ^ "};\n" 
    in
    struct_string::acc in
    List.rev (StringMap.fold fold_func indices []) 


and string_of_slambda sl = 
      "id: " ^ sl.sid ^
      ", return type: " ^ string_of_typ sl.st (* TODO: Different printings? *)
      

let string_of_sprogram (structs, vars, lambdas) =
  String.concat "" ((string_of_senv structs) @
                    (List.map string_of_vdecl vars) @ 
                    (match lambdas with
                        (main::ls) -> (List.map string_of_sstmt main.sbody) @
                                      ["\nLambdas: \n"; 
                                       String.concat "\n" 
                                       (List.map string_of_slambda ls); "\n"]
                      | []         -> []))