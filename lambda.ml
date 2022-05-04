
(* Checks and functions that traverse the whole tree, 
   heavily relies on pass.ml
   create_lambda_list generates a list of lambda expressions, 
   return_pass guarantess all paths of lambdas return a value
 * Author(s): Ezra Szanton
 * 
 *)

module A = Ast
open Sast
open Pass

module StringMap = Map.Make(String)

let lambda_from_expr = function
    SLambda(l) -> [l]
  | _    -> []

let create_lambda_list = fold_tree lambda_from_expr (@) []

(* Returns a tuple, first value means should you disregard my subexpressions, 
                    second value means should you treat this as a return    *)
let rec is_return = function
    SIf(_, s1, s2) -> (true, snd (check_stmt_for_return s1) && snd(check_stmt_for_return s2))
  | SWhile(_,_)    -> (true, false)
  | SReturn(_)     -> (false, true)
  | _              -> (false, false) 

and zipper (disregard_subexpression, root_has_return) (_, subexpression_has_return) =
    if disregard_subexpression
    then (false, root_has_return)
    else (false, root_has_return || subexpression_has_return)

and check_stmt_for_return stmt = fold_tree_with_stmt is_return (fun _ -> (false, false)) zipper (false, false) false stmt 

and check_for_return (sl : sLambda) = 
  (match sl.st with 
      A.Void -> true
    | _    -> let (_, has_return) = check_stmt_for_return (SBlock sl.sbody) in
                if has_return
                then true
                else raise (Failure ("Not every path returns a value in " ^ sl.sid)))
            
and return_pass (sls : sLambda list) = List.fold_right (fun l acc -> (check_for_return l) && acc) sls true