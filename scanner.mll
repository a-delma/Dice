(* Ocamllex scanner for Dice *)
(* Author(s): Andrew DelMastro, Diego Griese, Ezra Szanton, Sasha Fedchin *)

{ open Parser }

let digit = ['0' - '9']
let digits = digit+

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "//"     { comment lexbuf }           (* Comments *)
| "/*"     { multiComment lexbuf}
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['      { LSQURE }
| ']'      { RSQURE }
| '.'      { DOT }
| ';'      { SEMI }
| ':'      { COLON }
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '='      { ASSIGN }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| "!"      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "Int"    { INT }
| "Bool"   { BOOL }
| "Float"  { FLOAT }
| "Void"   { VOID }
| "->"     { ARROW }
| "true"   { BLIT(true)  }
| "false"  { BLIT(false) }
| "struct" { STRUCT }
| "lambda" { LAMBDA }
| "import" { IMPORT }
| "null"   { NULL }
| "new"    { NEW }
| digits as lxm { LITERAL(int_of_string lxm) }
| digits '.'  digit* as lxm { FLIT(lxm) }
| ['a'-'z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| ['A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { TYPVAR(lxm) }
| '"' ([^ ' ' ';' '"'] | '\ ')* '"' as lxm { FILENAME(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }
and comment = parse
  ['\r' '\n'] { token lexbuf }
| eof         { EOF }
| _           { comment lexbuf }

and multiComment = parse
  "*/" { token lexbuf }
| eof  {  raise (Failure("Multiline comment not closed")) }
| _    { multiComment lexbuf }
