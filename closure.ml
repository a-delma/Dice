open Sast
open Ast

let rec contains element list = match list with
    (head::tail) -> (head = element) || (contains element tail)
  | []           -> false

and union l1 l2 = (match l1 with
    (head::tail) -> if (contains head l2) then 
                       union tail l2 else
                       union tail (head::l2)
  | []           -> l2)

and closure_stmt envs statement = match statement with
    SBlock(sl)  -> let closure_with_env = fun s -> closure_stmt envs s in 
                   List.fold_left union [] (List.map closure_with_env sl)
  | SExpr((_, e))   -> closure_expr envs e
  | SReturn((_, e)) -> closure_expr envs e
  | SIf((_, e), s1, s2) -> (union (union (closure_stmt envs s1) 
                                         (closure_stmt envs s2)) 
                                  (closure_expr envs e)) 
  | SFor(_)    -> raise (Failure "Not implemented")
  | SWhile(_)  -> raise (Failure "Not implemented")

and closure_expr envs expression = match expression with
    SLiteral(_)      -> []
  | SFliteral(_)     -> []
  | SBoolLit(_)      -> []
  | SId(_)           -> raise (Failure "Not implemented")
  | SBinop(_)        -> raise (Failure "Not implemented")
  | SUnop(_)         -> raise (Failure "Not implemented")
  | SAssign(_)       -> raise (Failure "Not implemented")
  | SAssignList(_)   -> raise (Failure "Not implemented")
  | SCall(_)         -> raise (Failure "Not implemented")
  | SRecordAccess(_) -> raise (Failure "Not implemented")
  | SLambda(_)       -> raise (Failure "Not implemented")
  | SNoexpr          -> []