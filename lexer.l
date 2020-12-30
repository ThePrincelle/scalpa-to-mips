%{
// https://stackoverflow.com/questions/1851829/how-to-use-yylval-with-strings-in-yacc
#include <stdlib.h>
#include <stdbool.h>
#include "symbols_tab.h"
#include "pile.h"
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
true                            { yylval.string_val = "1"; return T_BOOLEAN; }
false                           { yylval.string_val = "2"; return T_BOOLEAN; }
[a-zA-Z]([0-9a-zA-Z]+|['_])     { yylval.string_val = strdup(yytext); return T_IDENT; }
[0-9]+                          { yylval.string_val = strdup(yytext); return T_INTEGER; }
[a-zA-Z]                        { yylval.string_val = strdup(yytext); return T_STRING; }
[[:blank:]]                     { /* ignorer les espaces */ }

.                               {}

%%