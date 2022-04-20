open Sast
open Ast
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
            if fold_tree_with_stmt is_return (fun e -> true) (||) false false (SBlock sl.sbody) 
            then true
            else raise (Failure ("Expected return in " ^ sl.sid ^ " but found none."))

let return_pass (sls : sLambda list) = List.fold_right (fun l acc -> (check_for_return l) && acc) sls true