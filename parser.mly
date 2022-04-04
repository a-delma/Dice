/* Ocamlyacc parser for MicroC */

%{ open Ast %}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA PLUS MINUS TIMES DIVIDE ASSIGN COLON
%token NOT EQ NEQ LT LEQ GT GEQ AND OR DOT
%token RETURN IF ELSE FOR WHILE INT BOOL FLOAT VOID
%token LSQURE RSQURE
%token LAMBDA
%token ARROW STRUCT /* Not sure about precedence or associativity*/
%token <int> LITERAL
%token <bool> BLIT
%token <string> ID FLIT TYPVAR
%token EOF


%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN
%left DOT
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE
%left ARROW /* Menhir says the precedence is never used */
%right NOT
%nonassoc LPAREN

%%
program:
  sdecl_opt vdecl_opt stmt_opt EOF {$1, $2, $3}

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    typ ID                   { [($1,$2)]     }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }

// typaram_list_opt:
//     /* nothing */ { [] }
//   |  LT typaram_list GT  { $2 }

// typaram_list:
//     TYPVAR                    { [$1]     }
//   | typaram_list COMMA TYPVAR { $3 :: $1 }

typ_list:
    /* nothing */      { []       }
  | typ                { [$1]     }
  | typ_list COMMA typ { $3 :: $1 }

typ:
    INT                              { Int   }
  | BOOL                             { Bool  }
  | FLOAT                            { Float }
  | VOID                             { Void  }
  | LSQURE typ_list RSQURE ARROW typ
                                     { Arrow(List.rev $2, $5) }
  | TYPVAR                           { TypVar $1 }
  // | TYPVAR LT typ_list GT            { PolyTyp($1, $3)}

vdecl_opt:
    /* nothing */ { []          }
  | vdecl_list    { List.rev $1 }

vdecl_list:
  | vdecl_list vdecl { $2 :: $1 }
  | vdecl            { [$1]     }

vdecl:
   typ ID SEMI { ($1, $2) }

sdecl_opt:
    /* nothing */ { []          }
  | sdecl_list    { List.rev $1 }

sdecl_list:
  | sdecl_list sdecl { $2 :: $1 }
  | sdecl            { [$1]     }

sdecl:
   STRUCT TYPVAR LBRACE vdecl_list RBRACE SEMI { ( $2, $4) }

stmt_opt:
    /* nothing */ { []          }
  | stmt_list     { List.rev $1 }

stmt_list:
  | stmt           { [$1]     }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI                               { Expr $1               }
  | RETURN expr_opt SEMI                    { Return $2             }
  | LBRACE stmt_opt RBRACE                  { Block(List.rev $2)    }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7)        }
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
                                            { For($3, $5, $7, $9)   }
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5)         }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1     }

expr:
    LITERAL          { Literal($1)            }
  | FLIT             { Fliteral($1)           }
  | BLIT             { BoolLit($1)            }
  | ID               { Id($1)                 }
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr EQ     expr { Binop($1, Equal, $3)   }
  | expr NEQ    expr { Binop($1, Neq,   $3)   }
  | expr LT     expr { Binop($1, Less,  $3)   }
  | expr LEQ    expr { Binop($1, Leq,   $3)   }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | MINUS expr %prec NOT { Unop(Neg, $2)      }
  | NOT expr         { Unop(Not, $2)          }
  | expr ASSIGN expr { Assign($1, $3)         }
  | LBRACE assign_list RBRACE {AssignList(List.rev $2)}
  | expr DOT ID      { RecordAccess($1, $3)   } 
  | expr LPAREN args_opt RPAREN
                     { Call($1, $3)           }
  | LPAREN expr RPAREN { $2                   }
  | LAMBDA LPAREN formals_opt RPAREN ARROW typ LBRACE vdecl_opt stmt_opt RBRACE
                     { Lambda({formals=$3; t=$6; locals=$8; body=$9})     }

assign_list:
    ID COLON expr                   { [($1, $3)]   }
  | assign_list COMMA ID COLON expr { ($3, $5)::$1 }

args_opt:
    /* nothing */ { []          }
  | args_list     { List.rev $1 }

args_list:
    expr                 { [$1]     }
  | args_list COMMA expr { $3 :: $1 }
