%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "stdbool.h"
    #include "abstract_syntax_tree.h"

    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;
    
    void yyerror(char*);
    //void lex_free();
%}

%union
{
  int bool_val;
  int int_val;
  char* string_val;
}

%start program
%token TYPE_PROGRAM TYPE_IDENT TYPE_RETURN TYPE_INTEGER TYPE_BOOLEAN

%type <string_val> TYPE_IDENT TYPE_RETURN TYPE_PROGRAM prog_instr expr cte 
%type <bool_val> TYPE_BOOLEAN
%type <int_val> TYPE_INTEGER

%%

program : TYPE_PROGRAM TYPE_IDENT prog_instr {fprintf(yyout,"\t.text\n#\t%s\nmain:\n\t%s",$2,$3);};

prog_instr : TYPE_RETURN           {$$ = "syscall";}
           | TYPE_RETURN expr      {char buffer [100]; snprintf(buffer,100,"%s\n\tsyscall",$2); $$ = buffer;};

expr : cte                         {$$ = $1;};

cte : TYPE_INTEGER                 { char buffer [100]; snprintf(buffer,100,"li $a0 %d\n\tli $v0 1", $1); $$ = buffer;}
    | TYPE_BOOLEAN                 { char buffer [100]; snprintf(buffer,100,"li $a0 %d\n\tli $v0 1" , $1); $$ = buffer;};

%%

void yyerror (char *s) {
    fprintf(stderr, "[Yacc] error: %s\n", s);
}

int main(int argc, char* argv[])
{
  if (argc != 2) {
        fprintf(stderr, "usage: %s file\n", argv[0]);
      exit(1);
  }

  char* in_file = argv[1];
  int in_file_length = strlen(in_file);

  yyin = fopen(in_file, "r");

  if (yyin == NULL) {
      fprintf(stderr, "unable to open file %s\n", argv[1]);
      exit(1);
  }

  char* out_file = strdup(in_file);
  strcpy(&out_file[in_file_length-4],&out_file[in_file_length]);
  out_file= strcat(out_file,".s");
  
  yyout = fopen(out_file, "w+");
  yyparse();

  fclose(yyin);
  fclose(yyout);

  // Be clean.
  //lex_free();
  return 0;
}