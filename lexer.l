%{
// https://stackoverflow.com/questions/1851829/how-to-use-yylval-with-strings-in-yacc
#include <stdlib.h>
#include <stdbool.h>
#include "symbols_tab.h"
#include "variables_tab.h"
#include "pile.h"
#include "parser.tab.h"
%}

%option nounput
%option noyywrap

%%

\(                              { return T_PAROUV; }
\)                              { return T_PARFER; }
\[                              { return T_BRAOUV; }
\]                              { return T_BRAFER; }

\;                              { return SEMICOLON; }
\:                              { return D_POINT; }
\,                              { return COMMA; }
".."                            { return PP; }

\-                              { return T_MINUS; }
\+                              { return T_PLUS;  }
\*                              { return T_MULT;  }
\/                              { return T_DIV;   }
\^                              { return T_POW;   }

"<="                            { return T_LE; }
">="                            { return T_GE; }
"<>"                            { return T_NE; }
\<                              { return T_LT; }
\>                              { return T_GT; }
\=                              { return T_EQ; }
":="                            { return ASSIGN; }

"and"                           { return T_AND; }
"or"                            { return T_OR;  }
"xor"                           { return T_XOR; }
"not"                           { return T_NOT; }

program                         { return T_PROGRAM; }
return                          { return T_RETURN; }
write                           { return T_WRITE; }
begin                           { return T_BEGIN; }
end                             { return T_END; }
var                             { return T_VAR; }

array                           { return T_ARRAY; }
integer                         { return T_INTEGER; }
int                             { return T_INT; }
unit                            { return T_UNIT; }
bool                            { return T_BOOL; }
of                              { return T_OF; }

true                            { yylval.string_val = "1"; return T_BOOLEAN; }
false                           { yylval.string_val = "0"; return T_BOOLEAN; }

[a-zA-Z]((['_]?[0-9a-zA-Z])+)?  { yylval.string_val = strdup(yytext); return T_IDENT; }
"-"?[0-9]+                      { yylval.string_val = strdup(yytext); return T_INTEGER; }
\"[a-zA-Z]+\"                   { yylval.string_val = strdup(yytext); return T_STRING; }

[[:blank:]]                     { /* ignorer les espaces */ }

.                               {}

%%
