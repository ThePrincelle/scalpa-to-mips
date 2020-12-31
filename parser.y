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
  enum op_arith {opb_plus, opb_minus, opb_mult, opb_div, opb_pow, opb_le, opb_lt, opb_ge, opb_gt, opb_eq, opb_ne, opb_and, opb_or, opb_xor};

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
  struct stack* variables = NULL;

  bool pow_exist = false;
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

//Main
%token T_PROGRAM T_IDENT T_RETURN T_WRITE T_INTEGER T_BOOLEAN T_BEGIN T_END T_STRING T_PAROUV T_PARFER SEMICOLON 

// Operators
%token T_MINUS T_PLUS T_MULT T_POW

// Comparators
%token T_NOT T_LE T_GE T_NE T_LT T_GT T_EQ T_AND T_OR T_XOR

%nonassoc T_LE T_GE T_NE T_LT T_GT T_EQ
%left T_PLUS T_MINUS T_OR T_XOR
%left T_DIV T_MULT T_AND
%right T_POW
%right OPUMINUS T_NOT


%type <string_val> prog_instr sequence program T_IDENT T_INTEGER T_BOOLEAN T_BEGIN T_STRING
//%type <bool_val>
//%type <int_val> 
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
                                    push(variables, size(contextes));
                                    snprintf(buffer,100,"li $t%d %d\n\t", size(variables), atoi($1.val));
                                  }
                                  else
                                  {
                                    push(variables, size(contextes));
                                    snprintf(buffer,100,"li $t%d %s\n\t", size(variables), $1.val);
                                  }
                                  $$.val = buffer;
                                  $$.type = $1.type;
                                }
      | T_PAROUV expr T_PARFER  {
                                  $$.val = $2.val;
                                  $$.type = $2.type;
                                }
      | T_MINUS expr            {
                                  char buffer [100];
                                
                                    if($2.type == int_val )
                                    {
                                      snprintf(buffer,100,"%smul $t%d $t%d -1\n\tmove $a0 $t6\n\t", $2.val, size(variables), size(variables));
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }

                                  $$.val = buffer;
                                }%prec OPUMINUS
      | T_NOT expr              {
                                  char buffer [100];
                                 
                                  if($2.type == bool_val )
                                  {
                                    snprintf(buffer,100,"%sseq $t%d $t%d $zero\n\tmove $a0 $t6\n\t", $2.val, size(variables), size(variables));
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                
                                  $$.val = buffer;
                                }
      | expr T_PLUS expr           {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      snprintf(buffer,100,"%s%sadd $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                      pop(variables);
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    $$.val = buffer;
                                  }
    | expr T_MINUS expr           {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      snprintf(buffer,100,"%s%ssub $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                      pop(variables);
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    $$.val = buffer;
                                  }
    | expr T_MULT expr            {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                      {
                                        snprintf(buffer,100,"%s%smul $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                        pop(variables);
                                        $$.type = int_val;
                                      }
                                      else
                                      {
                                        yyerror("Syntax error");
                                      }
                                    $$.val = buffer;
                                  }
      | expr T_DIV expr            {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                      {
                                        snprintf(buffer,100,"%s%sdiv $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                        pop(variables);
                                        $$.type = int_val;
                                      }
                                      else
                                      {
                                        yyerror("Syntax error");
                                      }
                                    $$.val = buffer;
                                  }
      | expr T_POW expr           {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      if(!pow_exist)
                                      {
                                        pow_exist = true;
                                      }
                                      char* code = "%s%s\n\tli $a3 $t%d\n\tli $a4 $t%d\n\tjal pow";
                                      snprintf(buffer,100,code, $1.val, $3.val, size(variables)-1, size(variables));
                                      pop(variables);
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    $$.val = buffer;
                                 }
      | expr T_LE expr           {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      snprintf(buffer,100,"%s%ssle $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                      pop(variables);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    $$.val = buffer;
                                 }
      | expr T_LT expr           {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      snprintf(buffer,100,"%s%sslt $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                      pop(variables);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    $$.val = buffer;
                                 }
      | expr T_GE expr           {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      snprintf(buffer,100,"%s%ssge $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                      pop(variables);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    $$.val = buffer;
                                 }
      | expr T_GT expr           {
                                    char buffer[100];
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      snprintf(buffer,100,"%s%ssgt $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                      pop(variables);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                    $$.val = buffer;
                                 }
      | expr T_EQ expr           {
                                  char buffer[100];
                                  if ($1.type == int_val && $3.type == int_val)
                                  {
                                    snprintf(buffer,100,"%s%sseq $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                    pop(variables);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                  $$.val = buffer;
                                } 
      | expr T_NE expr          {
                                  char buffer[100];
                                  if ($1.type == int_val && $3.type == int_val)
                                  {
                                    snprintf(buffer,100,"%s%ssne $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                    pop(variables);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                  $$.val = buffer;
                                }
      | expr T_AND expr         {
                                  char buffer[100];
                                  if ($1.type == int_val && $3.type == int_val)
                                  {
                                    snprintf(buffer,100,"%s%sand $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                    pop(variables);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                  $$.val = buffer;
                                }
                                   
      | expr T_OR expr          {
                                  char buffer[100];
                                  if ($1.type == int_val && $3.type == int_val)
                                  {
                                    snprintf(buffer,100,"%s%sor $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                    pop(variables);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                  $$.val = buffer;
                                }

      | expr T_XOR expr         {
                                  char buffer[100];
                                  if ($1.type == int_val && $3.type == int_val)
                                  {
                                    snprintf(buffer,100,"%s%sxor $t%d $t%d $t%d\n\t", $1.val, $3.val, size(variables)-1, size(variables)-1, size(variables));
                                    pop(variables);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                  $$.val = buffer;
                                };

cte : T_INTEGER                 {$$.val = $1; $$.type = int_val;}
    | T_BOOLEAN                 {$$.val = $1; $$.type = bool_val;}
    | T_STRING                  {$$.val = $1; $$.type = string_val;};
    
%%

void yyerror (char *s) {
  fprintf(stderr, "[Yacc] error: %s\n", s);
  exit(1);
}

void init ()
{
  contextes = newStack();
  variables = newStack();
}

void insert_procedures ()
{
  if (pow_exist) {
    fprintf(yyout, "pow:\n\tmul $a3 $a3 $a3\n\tadd $t9 $t9 1 \n\tbeg $t9 $a4 pow\n\tje $ra");
  }
  
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

  insert_procedures();
  
  fclose(yyin);
  fclose(yyout);

  // Be clean.
  //lex_free();
  return 0;
}
