open Sast
open Ast
open Pass

module StringMap = Map.Make(String)

let rec contains element list = match list with
    (head::tail) -> (head = element) || (contains element tail)
  | []           -> false

and union l1 l2 = (match l1 with
    (head::tail) -> if (contains head l2) then 
                       union tail l2 else
                       union tail (head::l2)
  | []           -> l2)

and collect_closure_expr envs es = match es with
  (_, e)::es' -> union (closure_expr envs e) (collect_closure_expr envs es')
| [] -> []

and closure_stmt envs statement = match statement with
    SBlock(sl)  -> let closure_with_env = fun s -> closure_stmt envs s in 
                   List.fold_left union [] (List.map closure_with_env sl)
  | SExpr((_, e))   -> closure_expr envs e
  | SReturn((_, e)) -> closure_expr envs e
  | SIf((_, e), s1, s2) -> (union (union (closure_stmt envs s1) 
                                         (closure_stmt envs s2)) 
                                  (closure_expr envs e)) 
  | SFor(e1, e2, e3, s) -> union (collect_closure_expr envs [e1; e2; e3]) (closure_stmt envs s)
  | SWhile((_, p), s)  -> union (closure_expr envs p) (closure_stmt envs s)

(* Returns a tuple with the first element indicating if it is a global/local or not, and 
   second element indicating the type no matter where it is.
   Errors if not found *)
and location_and_type envs s = (match envs with 
  local :: prev_and_global -> if StringMap.mem s local
                              then (true, StringMap.find s local)
                              else let rec inclusion envlist = match envlist with
                                    global :: [] -> if StringMap.mem s global
                                      then (true, StringMap.find s global)
                                      else raise (Failure ("Unbound Identifier " ^ s))
                                  | prev :: rest -> if StringMap.mem s prev
                                                                then (false, StringMap.find s prev)
                                                                else inclusion rest
                                  
                                  | _ -> raise (Failure "Wrong sized environments")
                                  in inclusion prev_and_global
  | _ -> raise (Failure "Wrong sized environments"))
and closure_expr envs expression = match expression with
    SLiteral(_)      -> []
  | SFliteral(_)     -> []
  | SBoolLit(_)      -> []
  | SId(s)           -> let (loc, typ) = location_and_type envs s in
                        if loc
                        then []
                        else [(typ, s)]
  | SBinop((_, e1), _, (_, e2))   -> (union (closure_expr envs e1) (closure_expr envs e2))
  | SUnop(_, (_, e))         -> (closure_expr envs e)
  | SAssign(e1, e2)       -> (match e1 with
    (_, SId(s)) -> let (loc, _) = location_and_type envs s in
                   if loc
                   then collect_closure_expr envs (e1::[e2])
                   else raise (Failure ("Attempt to reassign to \"" ^ s ^ "\" from closure"))
    | _ -> collect_closure_expr envs (e1::[e2]))
  | SAssignList(_)   -> raise (Failure "Not implemented5")
  | SCall(e, args) -> collect_closure_expr envs (e::args)
                       (* For each argument, compute closure for expression.  Then, combine the closures with union *)
                       (* Cannot currently test against ID calls other than putChar *)
  | SRecordAccess(_) -> raise (Failure "Not implemented7")
  | SLambda(l) -> let (locals::_) = envs in 
  (*Returns the list l_super minus any elements that are in the StringMap m_sub*)
                  let rec diff l_super m_sub = (match l_super with
                      ((t, s)::tail) -> (try if t = StringMap.find s m_sub
                                             then diff tail m_sub
                                             else raise (Failure "Shadowing variable with different type, not expected") 
                                         with Not_found -> (t, s)::(diff tail m_sub))
                      | _     -> [])
                  in diff l.sclosure locals
  | SNoexpr          -> []
