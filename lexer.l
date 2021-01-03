%{
// https://stackoverflow.com/questions/1851829/how-to-use-yylval-with-strings-in-yacc
#include <stdlib.h>
#include <stdbool.h>
#include "symbols_tab.h"
#include "variables_tab.h"
#include "pile.h"
#include "parser.tab.h"

bool comment = false;
bool new_line = false;

#define process(token) { if (!comment) { return token; } else {  if(new_line) { fprintf(yyout,"\n\t# "); new_line = false;} fprintf(yyout,"%s", strdup(yytext)); } }
%}

%option nounput
%option noyywrap

%%

\(                              { process(T_PAROUV); }
\)                              { process(T_PARFER); }
\[                              { process(T_BRAOUV); }
\]                              { process(T_BRAFER); }

\;                              { process(SEMICOLON); }
\:                              { process(D_POINT); }
\,                              { process(COMMA); }
".."                            { process(PP); }

\-                              { process(T_MINUS); }
\+                              { process(T_PLUS);  }
\*                              { process(T_MULT);  }
\/                              { process(T_DIV);   }
\^                              { process(T_POW);   }

"<="                            { process(T_LE); }
">="                            { process(T_GE); }
"<>"                            { process(T_NE); }
\<                              { process(T_LT); }
\>                              { process(T_GT); }
\=                              { process(T_EQ); }
":="                            { process(ASSIGN); }

"and"                           { process(T_AND); }
"or"                            { process(T_OR);  }
"xor"                           { process(T_XOR); }
"not"                           { process(T_NOT); }

program                         { process(T_PROGRAM); }
return                          { process(T_RETURN); }
write                           { process(T_WRITE); }
read                            { process(T_READ); }
begin                           { process(T_BEGIN); }
end                             { process(T_END); }
var                             { process(T_VAR); }

array                           { process(T_ARRAY); }
integer                         { process(T_INTEGER); }
int                             { process(T_INT); }
unit                            { process(T_UNIT); }
bool                            { process(T_BOOL); }
of                              { process(T_OF); }

true                            { if(!comment){ yylval.string_val = "1"; } process(T_BOOLEAN);  }
false                           { if(!comment){ yylval.string_val = "0";  } process(T_BOOLEAN); }

[a-zA-Z]((['_]?[0-9a-zA-Z])+)?  { if(!comment){ yylval.string_val = strdup(yytext); } process(T_IDENT);}
"-"?[0-9]+                      { if(!comment){ yylval.string_val = strdup(yytext); } process(T_INTEGER); }
\"[a-zA-Z]+\"                   { if(!comment){ yylval.string_val = strdup(yytext); } process(T_STRING); }

"(*"                            {if(!comment){comment = true; }}
"*)"                            {if(comment){comment = false; } else perror("Syntax error (no comment to close)");}

[[:blank:]]                     { if(comment) { fprintf(yyout,"%s", strdup(yytext));} }

\n                              { new_line = true; }

.                               { if(comment) { fprintf(yyout,"%s", strdup(yytext));} }

%%
