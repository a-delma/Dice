open Sast
open Ast

module StringMap = Map.Make(String)

(* A very generalized higher order function to compute things about an sast.
eval_expr and eval_stmt evaluate one sx or sstmt and will often be a pattern matching function with a large wildcard.
zipper merges values together.
empty is whatever the idea of nothing is for your operations.
the root_stmt will often remain uncurried, it's how we actually accept the root of the tree.
see below for an example which checks if the sast has a binary operation *)
let fold_tree_with_stmt (eval_stmt : sstmt -> 'a) 
              (eval_expr : sx -> 'a) 
              (zipper : 'a -> 'a -> 'a) 
              (empty : 'a)      
              (compute_sublambdas : bool)
              (root_stmt : sstmt)     = 
  
  let rec fold_stmt stmt = zipper (eval_stmt stmt) (match stmt with
    SBlock(sl)          -> collect_stmt sl
  | SExpr(e)            -> collect_expr [e]
  | SReturn(e)          -> collect_expr [e]
  | SIf(e, s1, s2)      -> zipper (collect_expr [e]) (collect_stmt [s1; s2])
  | SFor(e1, e2, e3, s) -> zipper (collect_expr [e1; e2; e3]) (fold_stmt s)
  | SWhile(p, s)        -> zipper (collect_expr [p]) (fold_stmt s))

  and fold_expr ex = zipper (eval_expr ex) (match ex with
      SBinop(e1, _, e2)   -> (collect_expr [e1; e2])
    | SUnop(_, e)         -> (collect_expr [e])
    | SAssign(e1, e2)     -> (collect_expr [e1; e2])
    (* To be tested *)
    | SAssignList(_, ses) -> collect_expr (snd (List.split ses))
    | SCall(e, args)      -> collect_expr (e::args)
    | SRecordAccess(e, _) -> collect_expr [e]
    | SLambda(l)          -> if compute_sublambdas 
                             then fold_stmt (SBlock l.sbody)
                             else empty
    | _                   -> empty)

  and collect_expr = function
  (_, e)::es -> zipper (fold_expr e) (collect_expr es)
  | [] -> empty

  and collect_stmt = function
  stmt::stmts -> zipper (fold_stmt stmt) (collect_stmt stmts)
  | [] -> empty

  in fold_stmt root_stmt

let fold_tree (eval_expr : sx -> 'a) 
              (zipper : 'a -> 'a -> 'a) 
              (empty : 'a)      
              (root_stmt : sstmt) = 
  let throwout_stmt _ = empty in
  fold_tree_with_stmt throwout_stmt eval_expr zipper empty true root_stmt
(* 
An example of how you might use fold_tree. is_binop is eval, bool is 'a,
    || is the zipper, and empty is false.

let is_binop = function 
  SBinop(e1, _, e2) -> true
  | _  -> false

let has_binop = fold_tree is_binop (||) false 

let binop_check block = if has_binop block 
                        then prerr_endline "has a binary operation"
                        else prerr_endline "doesn't have a binary operation" *)

