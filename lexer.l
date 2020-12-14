%{

// https://stackoverflow.com/questions/1851829/how-to-use-yylval-with-strings-in-yacc
#include <stdlib.h>
#include <stdbool.h>
#include "y.tab.h"

extern int yylval;

%}

%option nounput
%option noyywrap

%%

program
return
true
false
[a-zA-Z_][0-9a-zA-Z_]* { yylval.string_val = yytext; return IDENT; }
[0-9]+  { yylval.int_val = atoi(yytext); }
[[:blank:]] { /* ignorer les espaces */ }

. {}