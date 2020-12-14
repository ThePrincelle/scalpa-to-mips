%{
    #include <stdio.h>
    #include "stdbool.h"
    #include "abstract_syntax_tree.h"

    extern int yylex();
    
    void yyerror(char*);

%}

%union
{
  bool bool_val;
  int int_val;
  char* string_val;
}

%start program
%token PROGRAM IDENT RETURN INTEGER BOOLEAN

%%

program : PROGRAM IDENT prog_instr {};

prog_instr : RETURN      {}
      | RETURN expr      {};

expr : cte {};

cte : INTEGER {}
    | BOOLEAN {};

  