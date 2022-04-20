open Sast
open Ast
open Pass

module StringMap = Map.Make(String)

let closure_stmt envs root_stmt = 

let rec contains element list = match list with
    (head::tail) -> (head = element) || (contains element tail)
  | []           -> false
(* zipper *)
and union l1 l2 = (match l1 with
    (head::tail) -> if   (contains head l2)  
                    then union tail l2 
                    else union tail (head::l2)
  | []           -> l2)


(* Returns a tuple with the first element indicating if it is a global/local or not, and 
   second element indicating the type no matter where it is.
   Errors if not found *)
and location_and_type s = (match envs with 
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
and eval = function
  | SId(s)           -> let (loc, typ) = location_and_type s in
                        if loc
                        then []
                        else [(typ, s)]
  | SAssign(e1, _)       -> (match e1 with
    (_, SId(s)) -> let (loc, _) = location_and_type s in
                   if loc
                   then []
                   else raise (Failure ("Attempt to reassign to \"" ^ s ^ "\" from closure"))
    | _ -> [])
  | SLambda(l) -> let (locals::_) = envs in 
  (*Returns the list l_super minus any elements that are in the StringMap m_sub*)
                  let rec diff l_super m_sub = (match l_super with
                      ((t, s)::tail) -> (try if t = StringMap.find s m_sub
                                             then diff tail m_sub
                                             else raise (Failure "Shadowing variable with different type, not expected") 
                                         with Not_found -> (t, s)::(diff tail m_sub))
                      | _     -> [])
                  in diff l.sclosure locals
  | _          -> []

in fold_tree eval union [] root_stmt