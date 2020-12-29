%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "stdbool.h"
    #include "abstract_syntax_tree.h"

    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;
    enum type {int_val, bool_val, string_val};
   
    void yyerror(char*);
    //void lex_free();
%}

%union
{
  int bool_val;
  int int_val;
  char* string_val;
  struct 
  {
    int val;
    int type;
  } var;
}

%start program
%token T_PROGRAM T_IDENT T_RETURN T_INTEGER T_BOOLEAN T_BEGIN T_END SEMICOLON T_MINUS T_NOT

%type <string_val> T_IDENT T_RETURN T_PROGRAM T_BEGIN T_END SEMICOLON T_MINUS T_NOT prog_instr sequence 
%type <bool_val> T_BOOLEAN 
%type <int_val> T_INTEGER
%type <var> cte expr
%%

program : T_PROGRAM T_IDENT prog_instr {fprintf(yyout,"\t.text\n#\t%s\nmain:\n\t%s",$2,$3);};

prog_instr : T_RETURN               {$$ = "";}
           | T_RETURN expr          {char buffer [100];
                                     if ($2.type == int_val || $2.type == bool_val)
                                     {
                                      snprintf(buffer,100,"li $a0 %d\n\tli $v0 1\n\tsyscall",$2.val);
                                     }
                                     $$ = buffer;
                                    }
           | T_BEGIN sequence T_END {$$ = $2;}
           | T_BEGIN T_END          {$$ = "";};

sequence : prog_instr SEMICOLON sequence {
                                    char buffer [100];
                                    snprintf(buffer,100,"%s\n\t%s",$1,$3);
                                    $$ = buffer;
                                   }
         | prog_instr SEMICOLON          {
                                    char buffer [100];
                                    snprintf(buffer,100,"%s",$1);
                                    $$ = buffer;
                                   }
         | prog_instr              { $$ = $1 ;};

expr : cte                      {$$ = $1;};

cte : T_INTEGER                 {$$.val = $1; $$.type = int_val;}
    | T_BOOLEAN                 {$$.val = $1; $$.type = bool_val;};
  
opu : T_NOT                     {}
    | T_MINUS                   {};

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

  // Erase content of file
  fclose(fopen(out_file, "w+"));
  
  yyout = fopen(out_file, "w");
  yyparse();

  fclose(yyin);
  fclose(yyout);

  // Be clean.
  //lex_free();
  return 0;
}