%{
  #include <stdlib.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stdio.h>
  #include "pile.h"
  #include "symbols_tab.h"
  #include "stdbool.h"
  #include "abstract_syntax_tree.h"

  extern int yylex();
  extern FILE *yyin;
  extern FILE *yyout;
  enum type {int_val, bool_val, string_val};
  enum op_unaire {opu_minus, opu_not};

  typedef struct quadrup { /** ligne de code mips et le code **/
    char* instruction;
    int   cible;
  } quadrup;
  quadrup QUAD[100];
  int nextquad = 0;
  
  typedef struct lpos { /** liste de lecture du code **/
  int position;
  struct lpos* suivant;
  } lpos;
  
  lpos* crelist(int position) { /** permet l'insertion d'une nouvelle instruction dans la liste de lecture du code **/
    lpos* new = malloc(sizeof(lpos));
    new->position = position;
    new->suivant = NULL;
    return new;
  }
  
  lpos* concat(lpos* l1, lpos* l2) { /** permet l'insertion d'une instruction dans une liste de lecture du code **/
    lpos* res;
    if (l1 != NULL) res = l1;
    else if (l2 != NULL) res = l2;
         else res = NULL;
    if (l1 != NULL) {
      while (l1->suivant!=NULL) {
        l1 = l1->suivant;
      }
      l1->suivant = l2;
    }
    return res;
  }
  
  void complete(lpos* liste, int cible) { /** complete l'execution d'un quad avec un lpos **/
    QUAD[liste->position].cible = cible;
    while (liste->suivant != NULL) {
      liste = liste->suivant;
      QUAD[liste->position].cible = cible;
    }
  }
  
  void gencode(char* code) { /** genere un nouveau quad **/
    QUAD[nextquad].instruction=code;
    QUAD[nextquad].cible=0;
    nextquad++;
  }
   
  void yyerror(char*);
  //void lex_free();

  void init();

  struct stack* contextes = NULL;
%}

%union
{
  int bool_val;
  int int_val;
  char* string_val;
  struct 
  {
    char* val;
    int type;
  } var;
}

%start program
%token T_PROGRAM T_IDENT T_RETURN T_WRITE T_INTEGER T_BOOLEAN T_BEGIN T_END T_STRING SEMICOLON T_MINUS T_NOT

%type <string_val> T_IDENT T_RETURN T_WRITE T_PROGRAM T_BEGIN T_END T_STRING T_MINUS T_NOT T_INTEGER T_BOOLEAN SEMICOLON prog_instr sequence 
//%type <bool_val>  
%type <int_val> opu
%type <var> cte expr
%%

program : T_PROGRAM T_IDENT prog_instr {fprintf(yyout,"\t.text\n#\t%s\nmain:\n\t%s",$2,$3);};

prog_instr : T_RETURN               {$$ = "";}
           | T_RETURN expr          {$$= "";}
           | T_BEGIN {push(contextes, 0);} sequence T_END {$$ = $1; pop(contextes);}
           | T_BEGIN T_END          {$$ = "";}
           | T_WRITE expr           {char buffer [100];
                                     if ($2.type == int_val || $2.type == bool_val)
                                     {
                                      snprintf(buffer,100,"%sli $v0 1\n\tsyscall",$2.val);
                                     }
                                     else
                                     {
                                      snprintf(buffer,100,"%sli $v0 4\n\tsyscall",$2.val);
                                     }
                                     $$ = buffer;};

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
         | prog_instr                     { $$ = $1 ;};

expr : cte                      {char buffer [100];
                                  if ($1.type == int_val || $1.type == bool_val)
                                  {
                                    snprintf(buffer,100,"li $a0 %d\n\t",atoi($1.val));
                                  }
                                  else
                                  {
                                    snprintf(buffer,100,"li $a0 %d\n\t",atoi($1.val));
                                  }
                                  $$.val = buffer;
                                  $$.type = $1.type;
                                }
      | opu expr                {
                                  char buffer [100];
                                  if($1 == opu_minus)
                                  {
                                    if($2.type == int_val )
                                    {
                                      snprintf(buffer,100,"%smul $t6 $a0 -1\n\tmove $a0 $t6\n\t",$2.val);
                                      $$.type = int_val;                                     
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    
                                  }
                                  else if ($1 == opu_not)
                                  {
                                    if($2.type == bool_val )
                                    {
                                      snprintf(buffer,100,"%sseq $t6 $a0 $zero\n\tmove $a0 $t6\n\t",$2.val);    
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                  }
                                  $$.val = buffer; 
                                };
                                

cte : T_INTEGER                 {$$.val = $1; $$.type = int_val;}
    | T_BOOLEAN                 {$$.val = $1; $$.type = bool_val;}
    | T_STRING                  {$$.val = $1; $$.type = string_val;};
  
opu : T_NOT                     {$$ = opu_not;}
    | T_MINUS                   {$$ = opu_minus;};

%%

void yyerror (char *s) {
  fprintf(stderr, "[Yacc] error: %s\n", s);
  exit(1);
}

void init ()
{
  contextes = newStack();
}

int main(int argc, char* argv[])
{
  init();
  
  if (argc != 2) {
        fprintf(stderr, "Usage: %s file\n", argv[0]);
      exit(1);
  }

  char* in_file = argv[1];
  int in_file_length = strlen(in_file);

  yyin = fopen(in_file, "r");

  if (yyin == NULL) {
      fprintf(stderr, "unable to open file %s\n", argv[1]);
      perror("fopen");
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
