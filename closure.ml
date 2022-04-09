open Sast
open Ast

module StringMap = Map.Make(String)

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
  | SFor(_)    -> raise (Failure "Not implemented10")
  | SWhile(_)  -> raise (Failure "Not implemented11")

and closure_expr envs expression = match expression with
    SLiteral(_)      -> []
  | SFliteral(_)     -> []
  | SBoolLit(_)      -> []
  | SId(s)           -> (match envs with 
    local :: _ -> if StringMap.mem s local || StringMap.mem s global
                            then []
                            else let typ = (try StringMap.find s
                                            with Not_found -> raise (Failure ("Unbound identifier " ^ s))) 
                                          in [(typ, s)]
    |       global :: [] -> 
    | raise (Failure "Wrong sized environments"))
  
  | SBinop((_, e1), _, (_, e2))   -> (union (closure_expr envs e1) (closure_expr envs e2))
  | SUnop(_, (_, e))         -> (closure_expr envs e)
  | SAssign(_)       -> raise (Failure "Not implemented4")
  | SAssignList(_)   -> raise (Failure "Not implemented5")
  | SCall(_)         -> raise (Failure "Not implemented6")
  | SRecordAccess(_) -> raise (Failure "Not implemented7")
  | SLambda(_)       -> raise (Failure "Not implemented8")
  | SNoexpr          -> []