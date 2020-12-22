%{

// https://stackoverflow.com/questions/1851829/how-to-use-yylval-with-strings-in-yacc
#include <stdlib.h>
#include <stdbool.h>
#include "y.tab.h"

%}

%option nounput
%option noyywrap

%%

program { yylval.string_val = yytext; return TYPE_PROGRAM; }
return { yylval.string_val = yytext; return TYPE_RETURN; }
true { yylval.bool_val = 1; return TYPE_BOOLEAN; }
false { yylval.bool_val = 2; return TYPE_BOOLEAN; }
[a-zA-Z]([0-9a-zA-Z]+|['_]) { yylval.string_val = yytext; return TYPE_IDENT; }
[0-9]+  { yylval.int_val = atoi(yytext); }
[[:blank:]] { /* ignorer les espaces */ }

. {}
%%