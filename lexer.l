%{

// https://stackoverflow.com/questions/1851829/how-to-use-yylval-with-strings-in-yacc
#include <stdlib.h>
#include <stdbool.h>
#include "y.tab.h"

%}

%option nounput
%option noyywrap

%%

;                               { return SEMICOLON; }
-                               { return T_MINUS; }
not                             { return T_NOT; }
program                         { return T_PROGRAM; }
return                          { return T_RETURN; }
begin                           { return T_BEGIN; }
end                             { return T_END; }
true                            { yylval.bool_val = 1; return T_BOOLEAN; }
false                           { yylval.bool_val = 2; return T_BOOLEAN; }
[a-zA-Z]([0-9a-zA-Z]+|['_])     { yylval.string_val = strdup(yytext); return T_IDENT; }
[0-9]+                          { yylval.int_val = atoi(yytext); return T_INTEGER; }
[[:blank:]]                     { /* ignorer les espaces */ }

.                               {}

%%