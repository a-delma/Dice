module A = Ast
open Sast
open Pass

module StringMap = Map.Make(String)

let lambda_from_expr = function
    SLambda(l) -> [l]
  | _    -> []

let create_lambda_list = fold_tree lambda_from_expr (@) []

(* TODO look down if/else, and while cases to make sure every path has a return value*)
let is_return = function
    SReturn(_)  -> true
  | _           -> false 

let check_for_return (sl : sLambda) = 
  (match sl.st with 
      A.Void -> true
    | _    -> if fold_tree_with_stmt is_return (fun _ -> false) (||) false false (SBlock sl.sbody) 
              then true
              else raise (Failure ("Not every path returns a value in " ^ sl.sid)))
            
let return_pass (sls : sLambda list) = List.fold_right (fun l acc -> (check_for_return l) && acc) sls true