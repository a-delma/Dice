open Sast
open Ast

module StringMap = Map.Make(String)

let rec collect_lambda_expr es = match es with
  (_, e)::es' -> (lambda_from_expr e) @ (collect_lambda_expr es')
| [] -> []

and collect_lambda_stmt stmts = match stmts with
  stmt::stmts' -> (lambda_from_stmt stmt) @ (collect_lambda_stmt stmts')
| [] -> []

and lambda_from_stmt statement = match statement with
    SBlock(sl)  -> collect_lambda_stmt sl
  | SExpr((_, e))   -> lambda_from_expr e
  | SReturn((_, e)) -> lambda_from_expr e
  | SIf((_, e), s1, s2) -> lambda_from_expr e @ collect_lambda_stmt [s1; s2]
  | SFor(e1, e2, e3, s) -> (collect_lambda_expr [e1; e2; e3]) @ (lambda_from_stmt s)
  | SWhile((_, p), s)  -> (lambda_from_expr p) @ (lambda_from_stmt s)

and lambda_from_expr expression = match expression with
    SLiteral(_)      -> []
  | SFliteral(_)     -> []
  | SBoolLit(_)      -> []
  | SId(_)           -> []
  | SBinop(e1, _, e2)   -> collect_lambda_expr [e1; e2]
  | SUnop(_, (_, e))         ->  (lambda_from_expr e)
  | SAssign(e1, e2)       -> collect_lambda_expr [e1; e2]
  (* To be tested *)
  | SAssignList(_, ses)   -> collect_lambda_expr (snd (List.split ses))
  | SCall(e, args) -> collect_lambda_expr (e::args)
  | SRecordAccess((_, e), _) -> lambda_from_expr e
  | SLambda(l) -> [l] @ lambda_from_stmt (SBlock l.sbody)
  | SNoexpr    -> []
