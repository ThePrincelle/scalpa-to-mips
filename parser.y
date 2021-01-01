%{
  #include <stdlib.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stdio.h>
  #include "pile.h"
  #include "symbols_tab.h"
  #include "variables_tab.h"
  #include "abstract_syntax_tree.h"

  extern int yylex();
  extern FILE *yyin;
  extern FILE *yyout;
  enum type {int_val, bool_val, string_val, unit_val};
  enum op_unaire {opu_minus, opu_not};
  enum op_arith {opb_plus, opb_minus, opb_mult, opb_div, opb_pow, opb_le, opb_lt, opb_ge, opb_gt, opb_eq, opb_ne, opb_and, opb_or, opb_xor};

  typedef struct quadrup { /** ligne de code mips et le code **/
    char* instruction;
    int   cible;
  } quadrup;
  quadrup QUAD[100];
  int nextquad = 0;


  struct identliste{
      char* ident;
      struct identliste* suivant;
  };

  struct identliste* creIdentlist(char* ident) { /** permet l'insertion d'une nouvelle instruction dans la liste de lecture du code **/
    struct identliste* new = malloc(sizeof(struct identliste*));
    new->ident = ident;
    new->suivant = NULL;
    return new;
  }

  struct identliste* concatIdentlist(struct identliste* l1, struct identliste* l2) { /** permet l'insertion d'une instruction dans une liste de lecture du code **/
    struct identliste* res;
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
  struct stack* vars_temp_mips = NULL;

  bool pow_exist = false;
%}

%union
{
  struct identliste* identlist_val;
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
%token T_PROGRAM T_IDENT T_RETURN T_WRITE T_INTEGER T_BOOLEAN T_BEGIN T_END T_STRING T_PAROUV T_PARFER T_VAR T_BRAOUV T_BRAFER SEMICOLON D_POINT COMMA T_UNIT T_ARRAY T_INT T_BOOL T_OF PP

// Operators
%token T_MINUS T_PLUS T_MULT T_POW

// Comparators
%token T_NOT T_LE T_GE T_NE T_LT T_GT T_EQ T_AND T_OR T_XOR

%nonassoc T_LE T_GE T_NE T_LT T_GT T_EQ
%left T_PLUS T_MINUS T_OR T_XOR
%left T_DIV T_MULT T_AND
%right T_POW
%right OPUMINUS T_NOT


%type <string_val> prog_instr sequence program varsdecl T_IDENT T_INTEGER T_BOOLEAN T_BEGIN T_STRING
//%type <bool_val>
%type <int_val> typename atomictype
%type <identlist_val> identlist
%type <var> cte expr

%%

program : T_PROGRAM T_IDENT  {fprintf(yyout,"\t.text\n#\t%s\nmain:",$2);} vardecllist prog_instr {fprintf(yyout,"\n\tli $v0 10\n\tsyscall");};

vardecllist : varsdecl                                              {}
            | varsdecl SEMICOLON vardecllist                        {}
            |                                                       {};

varsdecl : T_VAR identlist D_POINT typename                         {
                                                                      struct identliste* current_ident = $2;
                                                                      while(current_ident != NULL)
                                                                      {
                                                                        char varmips[100];
                                                                        snprintf(varmips,100,"$s%d",vars_count);

                                                                        /** @TODO: Talle max des $s **/

                                                                        char varscalpa[100];
                                                                        snprintf(varscalpa,100,"%s",current_ident->ident);

                                                                        bool inserted = insertVar(varscalpa, varmips, size(contextes), $4, stderr);

                                                                        if(!inserted)
                                                                        {
                                                                          yyerror("Syntax error");
                                                                        }

                                                                        current_ident = current_ident->suivant;
                                                                      }

                                                                    };

identlist : T_IDENT                                                 {
                                                                      struct identliste* temp_ident = creIdentlist($1);
                                                                      $$ = temp_ident;
                                                                    }
          | T_IDENT COMMA identlist                                 {
                                                                      struct identliste* temp_ident = creIdentlist($1);
                                                                      struct identliste* concact_ident = concatIdentlist(temp_ident, $3);
                                                                      $$ = concact_ident;
                                                                    };

typename : atomictype                                               {$$ = $1;}
         //| arraytype                                                {};

atomictype : T_UNIT                                                 {$$ = unit_val;}
           | T_BOOL                                                 {$$ = bool_val;}
           | T_INT                                                  {$$ = int_val;}

/*arraytype : T_ARRAY T_BRAOUV rangelist T_BRAFER T_OF atomictype     {}
rangelist : T_INTEGER PP T_INTEGER                                  {}
          | T_INTEGER PP T_INTEGER COMMA rangelist                  {}*/

prog_instr : T_RETURN               {}
           | T_RETURN expr          {}
           | T_BEGIN {push(contextes, 0);} sequence T_END {$$ = $1; pop(contextes);}
         | T_BEGIN T_END          { /**delete all var inner current context**/}
           | T_WRITE expr           {
                                     if ($2.type == int_val || $2.type == bool_val)
                                     {
                                      fprintf(yyout,"\n\tmove $a0 $t%d\n\tli $v0 1\n\tsyscall", size(vars_temp_mips));
                                     }
                                     else
                                     {
                                      fprintf(yyout,"\n\tmove $a0 $t%d\n\tli $v0 4\n\tsyscall", size(vars_temp_mips));
                                     }
                                    };

sequence : prog_instr SEMICOLON sequence {

                                          }
         | prog_instr SEMICOLON          {

                                          }
         | prog_instr                     { $$ = $1 ;};

expr : cte                      {
                                  if ($1.type == int_val || $1.type == bool_val)
                                  {
                                    push(vars_temp_mips, size(contextes));
                                    fprintf(yyout,"\n\tli $t%d %d",size(vars_temp_mips), atoi($1.val));
                                  }
                                  else
                                  {
                                    push(vars_temp_mips, size(contextes));
                                    fprintf(yyout,"\n\tli $t%d %s",size(vars_temp_mips) ,$1.val);
                                  }
                                  $$.type = $1.type;
                                }
      | T_PAROUV expr T_PARFER  {
                                  $$.val = $2.val;
                                  $$.type = $2.type;
                                }
      | T_MINUS expr            {
                                    if($2.type == int_val )
                                    {
                                      fprintf(yyout,"\n\tmul $t%d $t%d -1\n\tmove $a0 $t6", size(vars_temp_mips), size(vars_temp_mips));
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                }%prec OPUMINUS
      | T_NOT expr              {


                                  if($2.type == bool_val )
                                  {
                                    fprintf(yyout,"\n\tseq $t%d $t%d $zero\n\tmove $a0 $t6", size(vars_temp_mips), size(vars_temp_mips));
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }

                                }
      | expr T_PLUS expr           {

                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      fprintf(yyout,"\n\tadd $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                  }
      | expr T_MINUS expr         {
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsub $t%d $t%d $t%d",size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                  }
    | expr T_MULT expr            {
                                    if ($1.type == int_val && $3.type == int_val)
                                      {
                                        fprintf(yyout,"\n\tmul $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                        pop(vars_temp_mips);
                                        $$.type = int_val;
                                      }
                                      else
                                      {
                                        yyerror("Syntax error");
                                      }
                                  }
    | expr T_DIV expr            {
                                    if ($1.type == int_val && $3.type == int_val)
                                      {
                                        fprintf(yyout,"\n\tdiv $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                        pop(vars_temp_mips);
                                        $$.type = int_val;
                                      }
                                      else
                                      {
                                        yyerror("Syntax error");
                                      }
                                  }
    | expr T_POW expr             {
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      if(!pow_exist)
                                      {
                                        pow_exist = true;
                                      }
                                      char* code = "\n\tmove $a2 $t%d\n\tmove $a3 $t%d\n\tmove $t8 $a2\n\tjal pow\n\tmove $t%d $t8";
                                      fprintf(yyout,code, size(vars_temp_mips)-1, size(vars_temp_mips), size(vars_temp_mips)-1);
                                      pop(vars_temp_mips);
                                      $$.type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                 }
    | expr T_LE expr             {
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsle $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                 }
      | expr T_LT expr           {
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      fprintf(yyout,"\n\tslt $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                 }
      | expr T_GE expr           {
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsge $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                 }
      | expr T_GT expr           {
                                    if ($1.type == int_val && $3.type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsgt $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$.type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error");
                                    }
                                 }
      | expr T_EQ expr           {
                                  if (($1.type == int_val || $1.type == bool_val) && $1.type == $3.type )
                                  {
                                    fprintf(yyout,"\n\tseq $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$.type = $1.type;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                }
      | expr T_NE expr          {
                                  if (($1.type == int_val || $1.type == bool_val) && $1.type == $3.type )
                                  {
                                    fprintf(yyout,"\n\tsne $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$.type = $1.type;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                }
      | expr T_AND expr         {
                                  if ($1.type == bool_val && $3.type == bool_val)
                                  {
                                    fprintf(yyout,"\n\tand $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                }

      | expr T_OR expr          {
                                  if ($1.type == bool_val && $3.type == bool_val)
                                  {
                                    fprintf(yyout,"\n\tor $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
                                }
      | expr T_XOR expr         {
                                  if ($1.type == bool_val && $3.type == bool_val)
                                  {
                                    fprintf(yyout,"\n\txor $t%d $t%d $t%d", size(vars_temp_mips)-1, size(vars_temp_mips)-1, size(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$.type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error");
                                  }
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
  vars_temp_mips = newStack();
  initVarArray();
}

void insert_procedures ()
{
  if (pow_exist) {
    fprintf(yyout, "\npow:\n\tmul $t8 $t8 $a2\n\tadd $t9 $t9 1\n\tbne $t9 $a3 pow\n\tjr $ra\n\t");
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

  vars_to_string(stderr);

  fclose(yyin);
  fclose(yyout);

  // Be clean.
  //lex_free();
  return 0;
}
