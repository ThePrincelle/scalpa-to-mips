%{
  #include <stdlib.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stdio.h>
  #include "pile.h"
  #include "symbols_tab.h"
  #include "variables_tab.h"
  #include "varArray.h"
  #include "abstract_syntax_tree.h"

  extern int yylex();
  extern FILE *yyin;
  extern FILE *yyout;
  enum type {int_val, bool_val, string_val, unit_val, array_val};
  enum op_unaire {opu_minus, opu_not};
  enum op_arith {opb_plus, opb_minus, opb_mult, opb_div, opb_pow, opb_le, opb_lt, opb_ge, opb_gt, opb_eq, opb_ne, opb_and, opb_or, opb_xor};

  typedef struct var{
    char* val;
    int type;
  } var;

  typedef struct identlist_type{
      char* ident;
      struct identlist_type* suivant;
  }identlist_type;

  typedef struct exprlist_type{
      var* expr;
      struct exprlist_type* suivant;
      int nbelement;
  }exprlist_type;

  identlist_type* creIdentlist(char* ident) { /** permet l'insertion d'une nouvelle instruction dans la liste de lecture du code **/
    identlist_type* new = malloc(sizeof(identlist_type));
    new->ident = strdup(ident);
    new->suivant = NULL;
    return new;
  }

  exprlist_type* creExprlist(var* expr) { /** permet l'insertion d'une nouvelle instruction dans la liste de lecture du code **/
    exprlist_type* new = malloc(sizeof(exprlist_type));
    new->expr = expr;
    new->suivant = NULL;
    new->nbelement = 1;
    return new;
  }

  arraytype_type* creArrayType(int type,rangelist_type* rangelist) { /** permet l'insertion d'une nouvelle instruction dans la liste de lecture du code **/
    arraytype_type* new = malloc(sizeof(arraytype_type));
    new->type = type;
    new->rangelist = rangelist;
    return new;
  }

  rangelist_type* creRangelist(int deb, int fin) { /** permet l'insertion d'une nouvelle instruction dans la liste de lecture du code **/
    rangelist_type* new = malloc(sizeof(rangelist_type));
    new->deb = deb;
    new->fin = fin;
    new->length = (fin - deb)+1;
    new->totLenght = (fin - deb)+1; 
    new->suivant = NULL;
    return new;
  }

  identlist_type* concatIdentlist(identlist_type* l1, identlist_type* l2) { /** permet l'insertion d'une instruction dans une liste de lecture du code **/
    identlist_type* res;
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

  exprlist_type* concatExprlist(exprlist_type* l1, exprlist_type* l2) { /** permet l'insertion d'une instruction dans une liste de lecture du code **/
    exprlist_type* res;
    if (l1 != NULL) res = l1;
    else if (l2 != NULL) res = l2;
         else res = NULL;
    if (l1 != NULL) {
      while (l1->suivant!=NULL) {
        l1 = l1->suivant;
      }
      l1->suivant = l2;
    }
    if(l1 != NULL)
    {
      if(l2 != NULL)
      {
        if(l2->nbelement>l1->nbelement) res->nbelement=l2->nbelement;
      } 
      res->nbelement++;
    }
    else if (l2 != NULL) res->nbelement++;
    
    return res;
  }

  rangelist_type* concatRangelist(rangelist_type* l1, rangelist_type* l2) { /** permet l'insertion d'une instruction dans une liste de lecture du code **/
    rangelist_type* res;
    if (l1 != NULL) res = l1;
    else if (l2 != NULL) res = l2;
         else res = NULL;
    if (l1 != NULL) {
      while (l1->suivant!=NULL) {
        l1 = l1->suivant;
      }
      l1->suivant = l2;
    }
    if(l1 != NULL)
    {
      if(l2 != NULL)
      {
        res->totLenght=l1->totLenght*l2->totLenght;
      } 
    }
    return res;
  }


  void yyerror(char*);
  //void lex_free();

  void init();

  struct stack* contextes = NULL;
  struct stack* vars_temp_mips = NULL;

  bool pow_exist = false;
  int nb_while = 0;
%}

%union
{
  struct identlist_type* identlist_val;
  struct rangelist_type* rangelist_val;
  struct arraytype_type* arraytype_val;
  struct exprlist_type* exprlist_val;
  int bool_val;
  int int_val;
  char* string_val;
  struct var* var;
}

%start program

//Main
%token T_PROGRAM T_IDENT T_RETURN T_WRITE T_INTEGER T_BOOLEAN T_BEGIN T_END T_STRING T_PAROUV T_PARFER T_VAR T_BRAOUV T_BRAFER SEMICOLON D_POINT COMMA T_UNIT T_ARRAY T_INT T_BOOL T_OF PP ASSIGN T_READ T_WHILE T_DO

// Operators
%token T_MINUS T_PLUS T_MULT T_POW

// Comparators
%token T_NOT T_LE T_GE T_NE T_LT T_GT T_EQ T_AND T_OR T_XOR

%nonassoc T_LE T_GE T_NE T_LT T_GT T_EQ
%left T_PLUS T_MINUS T_OR T_XOR
%left T_DIV T_MULT T_AND
%right T_POW
%right OPUMINUS T_NOT


%type <string_val> T_IDENT T_INTEGER T_BOOLEAN T_STRING
%type <bool_val> vardecllist
%type <int_val> atomictype
%type <exprlist_val> exprlist
%type <identlist_val> identlist
%type <arraytype_val> arraytype
%type <rangelist_val> rangelist
%type <var> cte expr

%%

program : T_PROGRAM initMain initVarlist prog_instr                 {
                                                                      //Fin du programme mips
                                                                      fprintf(yyout,"\nend:\n\tli $v0 10\n\tsyscall");
                                                                    };

initMain : T_IDENT                                                  {
                                                                      //Debut du programme mips
                                                                      fprintf(yyout,"\n\t.text\n#\t%s\nmain:",$1);
                                                                    };

initVarlist : vardecllist                                           {
                                                                     // Si on a des variable dans le code
                                                                     if($1)
                                                                     {
                                                                       // Preparation place mémoire mips pour toute les varibles
                                                                       fprintf(yyout,"\n\taddi $sp, $sp, %d",-4*(vars_count+arrays_vars));
                                                                     }
                                                                    };                                                                  

vardecllist : varsdecl                                              {$$ = true;}
            | varsdecl SEMICOLON vardecllist                        {$$ = true;}
            |                                                       {$$ = false;};

varsdecl : T_VAR identlist D_POINT atomictype                       {
                                                                      identlist_type* current_ident = $2;

                                                                      //Tant que la liste d'expression est pas fini
                                                                      while(current_ident != NULL)
                                                                      {
                                                                        char varscalpa[100];
                                                                        snprintf(varscalpa,100,"%s",current_ident->ident);

                                                                        variable* inserted = insertVar(varscalpa, size(contextes), $4,0);

                                                                        //Si une erreur est survennu durant l'insertion
                                                                        if(inserted == NULL)
                                                                        {
                                                                          yyerror("Syntax error (insert)");
                                                                        }
                                                                        // On charge l'expression suivante
                                                                        current_ident = current_ident->suivant;
                                                                      }

                                                                    }
          | T_VAR identlist D_POINT arraytype                     {
                                                                      identlist_type* current_ident = $2;
                                                                      while(current_ident != NULL)
                                                                      {
                                                                        char varscalpa[100];
                                                                        snprintf(varscalpa,100,"%s",current_ident->ident);

                                                                        varArray* inserted = insertArray(varscalpa, size(contextes), $4,stderr);

                                                                        if(inserted == NULL)
                                                                        {
                                                                          yyerror("Syntax error (insert)");
                                                                        }

                                                                        current_ident = current_ident->suivant;
                                                                      }
                                                                    };

identlist : T_IDENT                                                 {
                                                                      //On cree une liste d'expression avec 1 seul element
                                                                      identlist_type* temp_ident = creIdentlist($1);
                                                                      $$ = temp_ident;
                                                                    }
          | T_IDENT COMMA identlist                                 {
                                                                      identlist_type* temp_ident = creIdentlist($1);

                                                                      //On prend la liste d'expression et on lui rajoute la nouvelle expression
                                                                      identlist_type* concact_ident = concatIdentlist(temp_ident, $3);
                                                                      $$ = concact_ident;
                                                                    };

atomictype : T_UNIT                                                 {$$ = unit_val;}
           | T_BOOL                                                 {$$ = bool_val;}
           | T_INT                                                  {$$ = int_val;};

arraytype : T_ARRAY T_BRAOUV rangelist T_BRAFER T_OF atomictype     {
                                                                      $$ = creArrayType($6,$3);
                                                                    }
rangelist : T_INTEGER PP T_INTEGER                                  {
                                                                      // Le debut d'interval doit etre inferieu à la fin
                                                                      if(atoi($1) > atoi($3))
                                                                      {
                                                                        yyerror("Syntax error (range)");
                                                                      }
                                                                      //On cree une liste de range avec 1 seul element
                                                                      $$ = creRangelist(atoi($1),atoi($3));
                                                                    }
          | T_INTEGER PP T_INTEGER COMMA rangelist                 {
                                                                      if(atoi($1) > atoi($3))
                                                                      {
                                                                        yyerror("Syntax error (range)");
                                                                      }
                                                                      rangelist_type* temp_rangelist =  creRangelist(atoi($1),atoi($3));
                                                                      //On prend la liste de range et on lui rajoute la nouvelle range
                                                                      $$ = concatRangelist(temp_rangelist,$5);
                                                                   }
while_begin:                                                       {
                                                                      fprintf(yyout,"\nbwhile%d:", nb_while);
                                                                      nb_while++;
                                                                   }

while_test: expr                                                   {
                                                                      //Si expr egale à 1 go to bwhile%d nbwhile
                                                                      fprintf(yyout,"\n\tbeq $t%d 0 ewhile%d", curr_idx(vars_temp_mips),nb_while-1);
                                                                      pop(vars_temp_mips);
                                                                   }

prog_instr : T_RETURN                                              {}
           | T_RETURN expr                                         {}
           | T_BEGIN  sequence T_END                               {}
           | T_BEGIN T_END                                         {}
           | T_WHILE while_begin while_test T_DO prog_instr        {
                                                                      nb_while--;
                                                                      fprintf(yyout,"\n\tj bwhile%d", nb_while);
                                                                      fprintf(yyout,"\newhile%d:", nb_while);
                                                                   }                                                                            
           | T_WRITE expr                                          {
                                                                    
                                                                    if ($2->type == int_val || $2->type == bool_val)
                                                                    {
                                                                      /**
                                                                        Affichage mips d'un int
                                                                        => les bool sont des int en mips
                                                                      **/
                                                                      fprintf(yyout,"\n\tmove $a0 $t%d\n\tli $v0 1\n\tsyscall", curr_idx(vars_temp_mips));
                                                                    }
                                                                    else if ($2->type == string_val)
                                                                    {
                                                                      /**
                                                                        Affichage mips d'un string
                                                                      **/
                                                                      fprintf(yyout,"\n\tmove $a0 $t%d\n\tli $v0 4\n\tsyscall", curr_idx(vars_temp_mips));
                                                                    }
                                                                    //on a uttiliser une variable temporaire $t
                                                                    pop(vars_temp_mips);
                                                                   }
          | T_READ T_IDENT                                         {
                                                                      // On cherche la variable avec l'IDENT
                                                                      variable* temp_var = getVar($2);
                                                                      
                                                                      //Si on l'a pas trouver
                                                                      if (temp_var == NULL )
                                                                      {
                                                                        yyerror("Syntax error (null ou init)");
                                                                      }

                                                                      //Si elle n'existe pas dans le context courant
                                                                      if ((int)temp_var->context > size(contextes))
                                                                      {
                                                                        yyerror("Syntax error (context)");
                                                                      }

                                                                      //Elle doit etre du type int ou bool
                                                                      if(temp_var->type != bool_val && temp_var->type != int_val)
                                                                      {
                                                                        yyerror("Syntax error (read)");
                                                                      }
                                                                      
                                                                      //Affichage du message "readMessage" depouis les datas
                                                                      fprintf(yyout,"\n\tla $a0 readMessage\n\tli $v0 4\n\tsyscall");
                                                                      //code mips de read pour int
                                                                      fprintf(yyout,"\n\tli $v0 5\n\tsyscall");

                                                                      //Si la var est un bool elle ne doit pas etre plus grande que 1
                                                                      if(temp_var->type == bool_val)
                                                                      {
                                                                        fprintf(yyout,"\n\tbgt $v0 1 error");
                                                                      }

                                                                      //creation d'une variable temporaire $t
                                                                      push(vars_temp_mips, size(contextes));
                                                                      fprintf(yyout,"\n\tmove $t%d $v0", curr_idx(vars_temp_mips));
                                                                      fprintf(yyout,"\n\tsw $t%d %d($sp)", curr_idx(vars_temp_mips),temp_var->p_memoire);
                                                                      pop(vars_temp_mips);

                                                                      temp_var->init = true;
                                                                  }
          | T_READ T_IDENT T_BRAOUV exprlist T_BRAFER             {
                                                                    varArray* temp_array = getArray($2);
                                                                    variable* temp_var = temp_array->array;

                                                                    if (temp_var == NULL )
                                                                    {
                                                                      yyerror("Syntax error (null ou init)");
                                                                    }

                                                                    if ((int)temp_var->context > size(contextes))
                                                                    {
                                                                      yyerror("Syntax error (context)");
                                                                    }

                                                                    if(temp_array->type != bool_val && temp_array->type != int_val)
                                                                    {
                                                                      yyerror("Syntax error (read)");
                                                                    }
                                                                    
                                                                    //recuperation des dimmention du tableau
                                                                    rangelist_type* current_rangelist = temp_array->range;

                                                                    //Si le tableau n'a pas de dimention
                                                                    if(current_rangelist == NULL)
                                                                    {
                                                                      yyerror("Syntax error (current_rangelist)");
                                                                    }
                                                                    
                                                                    //recuperation des expression de lecture pour le tableau
                                                                    exprlist_type* current_exprlist = $4;

                                                                    //Si on n'a pas d'expression
                                                                    if(current_exprlist==NULL)
                                                                    {
                                                                      yyerror("Syntax error (exprlist)");
                                                                    }

                                                                    //Si la liste d'expression est plus petite que la dimmention du tableau
                                                                    if(current_exprlist->nbelement < temp_array->dim )
                                                                    {
                                                                      yyerror("Syntax error (dim)");
                                                                    }
                                                                    
                                                                    fprintf(yyout,"\n\tla $a0 readMessage\n\tli $v0 4\n\tsyscall");
                                                                    fprintf(yyout,"\n\tli $v0 5\n\tsyscall");

                                                                    if(temp_var->type == bool_val)
                                                                    {
                                                                      fprintf(yyout,"\n\tbgt $v0 1 error");
                                                                    }

                                                                    push(vars_temp_mips, size(contextes));
                                                                    fprintf(yyout,"\n\tmove $t%d $v0", curr_idx(vars_temp_mips));
                                                                    int p_memoire = temp_var->p_memoire;
                                                                    int lec_temp = 0;

                                                                    /*
                                                                      Calcule de la position
                                                                    */
                                                                    while(current_exprlist != NULL)
                                                                    {
                                                                      if(lec_temp == 0)
                                                                      {
                                                                        push(vars_temp_mips, size(contextes));
                                                                      }
                                                                      var* temp_expr = current_exprlist->expr;
                                                                      if(temp_expr->type != int_val)
                                                                      {
                                                                        yyerror("Syntax error (type array)");
                                                                      }
                                                                      if(current_rangelist == NULL)
                                                                      {
                                                                        yyerror("Syntax error (read out array)");
                                                                      }
                                                                      
                                                                    
                                                                      fprintf(yyout,"\n\tli $t%d %d", curr_idx(vars_temp_mips),current_rangelist->fin);
                                                                      fprintf(yyout,"\n\tbgt $t%d $t%d error", lec_temp, curr_idx(vars_temp_mips));
                                                                      
                                                                      fprintf(yyout,"\n\tli $t%d %d", curr_idx(vars_temp_mips),current_rangelist->deb);
                                                                      fprintf(yyout,"\n\tblt $t%d $t%d error", lec_temp, curr_idx(vars_temp_mips));
                                                                      fprintf(yyout,"\n\tsub $t%d $t%d $t%d",curr_idx(vars_temp_mips), lec_temp, curr_idx(vars_temp_mips));
                                                                      if(lec_temp == 0)
                                                                      {
                                                                        push(vars_temp_mips, size(contextes));
                                                                        fprintf(yyout,"\n\tmul $t%d $t%d %d\n", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips)-1,  current_rangelist->totLenght/current_rangelist->length);
                                                                        pop(vars_temp_mips);
                                                                        fprintf(yyout,"\n");
                                                                      }
                                                                      else
                                                                      {
                                                                        fprintf(yyout,"\n\tmul $t%d $t%d %d", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips),  current_rangelist->totLenght/current_rangelist->length);
                                                                        push(vars_temp_mips, size(contextes));
                                                                        fprintf(yyout,"\n\tadd $t%d $t%d $t%d\n",curr_idx(vars_temp_mips), curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                                                        pop(vars_temp_mips);
                                                                      }

                                                                      current_exprlist=current_exprlist->suivant;
                                                                      current_rangelist = current_rangelist->suivant;
                                                                      lec_temp++;
                                                                    }
                                                                    
                                                                    fprintf(yyout,"\n\tli $t%d %d",curr_idx(vars_temp_mips)-(lec_temp+1), p_memoire);
                                                                    fprintf(yyout,"\n\tadd $t%d $t%d $t%d", curr_idx(vars_temp_mips)-(lec_temp+1), curr_idx(vars_temp_mips)-(lec_temp+1),curr_idx(vars_temp_mips)+1);
                                                                    fprintf(yyout,"\n\tmul $t%d $t%d   4", curr_idx(vars_temp_mips)-(lec_temp+1), curr_idx(vars_temp_mips)-(lec_temp+1));
                                                                    fprintf(yyout,"\n\tadd $t%d, $sp, $t%d", curr_idx(vars_temp_mips)-(lec_temp+1), curr_idx(vars_temp_mips)-(lec_temp+1));
                                                                    fprintf(yyout,"\n\tsw $t%d 0($t%d)", curr_idx(vars_temp_mips)-(lec_temp-1), curr_idx(vars_temp_mips)-(lec_temp+1));
                                                                    pop(vars_temp_mips);
                                                                    pop(vars_temp_mips);

                                                                    int i;
                                                                    for(i = lec_temp; i>0; i--)
                                                                    {
                                                                      pop(vars_temp_mips);
                                                                    }

                                                                    temp_var->init = true;
                                                                    
                                                                }
          | T_IDENT ASSIGN expr                                 {
                                                                  variable* var = getVar($1);

                                                                  if (var == NULL )
                                                                  {
                                                                    yyerror("Syntax error (null ou init)");
                                                                  }

                                                                  if ((int)var->context > size(contextes))
                                                                  {
                                                                    yyerror("Syntax error (context)");
                                                                  }
                                                                  if($3->type != (int)var->type)
                                                                  {
                                                                    yyerror("Syntax error (type)");
                                                                  }

                                                                  var->init = true;


                                                                  fprintf(yyout,"\n\tsw $t%d %d($sp)", curr_idx(vars_temp_mips), var->p_memoire);
                                                                  pop(vars_temp_mips);
                                                                }

          | T_IDENT T_BRAOUV exprlist T_BRAFER ASSIGN expr  {
                                                              varArray* temp_array = getArray($1);
                                                              variable* temp_var = temp_array->array;

                                                              if (temp_var == NULL )
                                                              {
                                                                yyerror("Syntax error (null ou init)");
                                                              }

                                                              if ((int)temp_var->context > size(contextes))
                                                              {
                                                                yyerror("Syntax error (context)");
                                                              }

                                                              if($6->type != (int)temp_array->type)
                                                              {
                                                                yyerror("Syntax error (type)");
                                                              }

                                                              rangelist_type* current_rangelist = temp_array->range;
                                                              if(current_rangelist == NULL)
                                                              {
                                                                yyerror("Syntax error (current_rangelist)");
                                                              }
                                                              
                                                              exprlist_type* current_exprlist = $3;
                                                              if(current_exprlist==NULL)
                                                              {
                                                                yyerror("Syntax error (exprlist)");
                                                              }

                                                              if(current_exprlist->nbelement < temp_array->dim )
                                                              {
                                                                 yyerror("Syntax error (dim)");
                                                              }
                                                              
                                                              int p_memoire = temp_var->p_memoire;
                                                              push(vars_temp_mips, size(contextes));
                                                              fprintf(yyout,"\n\tmove $t%d $t0",curr_idx(vars_temp_mips));
                                                              fprintf(yyout,"\n\tmove $t0 $t%d",curr_idx(vars_temp_mips)-1);
                                                              fprintf(yyout,"\n\tmove $t%d $t%d",curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                                              pop(vars_temp_mips);
 
                                                              int lec_temp = 0;
                                                              while(current_exprlist != NULL)
                                                              {
                                                                int lec_pos = lec_temp;
                                                                if(lec_temp == 0)
                                                                {
                                                                  lec_pos = curr_idx(vars_temp_mips);
                                                                  push(vars_temp_mips, size(contextes));
                                                                }
                                                                var* temp_expr = current_exprlist->expr;
                                                                if(temp_expr->type != int_val)
                                                                {
                                                                  yyerror("Syntax error (type array)");
                                                                }
                                                                if(current_rangelist == NULL)
                                                                {
                                                                  yyerror("Syntax error (read out array)");
                                                                }
                                                                
                                                                fprintf(yyout,"\n\tli $t%d %d", curr_idx(vars_temp_mips),current_rangelist->fin);
                                                                fprintf(yyout,"\n\tbgt $t%d $t%d error", lec_pos, curr_idx(vars_temp_mips));
                                                                
                                                                fprintf(yyout,"\n\tli $t%d %d", curr_idx(vars_temp_mips),current_rangelist->deb);
                                                                fprintf(yyout,"\n\tblt $t%d $t%d error", lec_pos, curr_idx(vars_temp_mips));

                                                                if(lec_temp == 0)
                                                                {
                                                                  fprintf(yyout,"\n\tsub $t%d $t%d $t%d",curr_idx(vars_temp_mips)-1, lec_pos, curr_idx(vars_temp_mips));
                                                                  push(vars_temp_mips, size(contextes));
                                                                  fprintf(yyout,"\n\tmul $t%d $t%d %d\n", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips)-2, current_rangelist->totLenght/current_rangelist->length);
                                                                  pop(vars_temp_mips);
                                                                  fprintf(yyout,"\n");
                                                                }
                                                                else
                                                                {
                                                                  fprintf(yyout,"\n\tsub $t%d $t%d $t%d",curr_idx(vars_temp_mips), lec_pos, curr_idx(vars_temp_mips));
                                                                  fprintf(yyout,"\n\tmul $t%d $t%d %d", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips), current_rangelist->totLenght/current_rangelist->length);
                                                                  push(vars_temp_mips, size(contextes));
                                                                  fprintf(yyout,"\n\tadd $t%d $t%d $t%d\n",curr_idx(vars_temp_mips), curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                                                  pop(vars_temp_mips);
                                                                }

                                                                current_exprlist=current_exprlist->suivant;
                                                                current_rangelist = current_rangelist->suivant;
                                                                lec_temp++;
                                                              }
                                                              
                                                              fprintf(yyout,"\n\tli $t%d %d",curr_idx(vars_temp_mips)-lec_temp, p_memoire);
                                                              fprintf(yyout,"\n\tadd $t%d $t%d $t%d", curr_idx(vars_temp_mips)-lec_temp, curr_idx(vars_temp_mips)-lec_temp,curr_idx(vars_temp_mips)+1);
                                                              fprintf(yyout,"\n\tmul $t%d $t%d   4", curr_idx(vars_temp_mips)-lec_temp, curr_idx(vars_temp_mips)-lec_temp);
                                                              fprintf(yyout,"\n\tadd $t%d, $sp, $t%d", curr_idx(vars_temp_mips)-lec_temp, curr_idx(vars_temp_mips)-lec_temp);
                                                              fprintf(yyout,"\n\tsw $t%d 0($t%d)", curr_idx(vars_temp_mips)-lec_temp-1, curr_idx(vars_temp_mips)-lec_temp);
                                                              pop(vars_temp_mips);

                                                              int i;
                                                              for(i = lec_temp; i>-1; i--)
                                                              {
                                                                pop(vars_temp_mips);
                                                              }

                                                              temp_var->init = true;

                                                            };

sequence : prog_instr SEMICOLON sequence  {}
         | prog_instr SEMICOLON           {}
         | prog_instr                     {};

exprlist : expr                           {
                                            $$ = creExprlist($1);
                                          }
         | expr COMMA exprlist            {
                                            $$ = concatExprlist(creExprlist($1),$3);
                                          };

expr : cte                      {
                                  $$=$1;
                                  if ($1->type == int_val || $1->type == bool_val)
                                  {
                                    push(vars_temp_mips, size(contextes));
                                    fprintf(yyout,"\n\tli $t%d %d",curr_idx(vars_temp_mips), atoi($1->val));
                                  }
                                  else
                                  {
                                    push(vars_temp_mips, size(contextes));
                                    fprintf(yyout,"\n\tli $t%d %s",curr_idx(vars_temp_mips) ,$1->val);
                                  }
                                  $$->type = $1->type;
                                }
      | T_PAROUV expr T_PARFER  {
                                  $$=$2;
                                }
      | T_MINUS expr            {
                                    $$=$2;
                                    if($2->type == int_val )
                                    {
                                      fprintf(yyout,"\n\tmul $t%d $t%d -1\n\tmove $a0 $t6", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips));
                                      $$->type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                }%prec OPUMINUS
      | T_NOT expr              {
                                  $$=$2;
                                  if($2->type == bool_val )
                                  {
                                    fprintf(yyout,"\n\tseq $t%d $t%d $zero\n\tmove $a0 $t6", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips));
                                    $$->type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error (type)");
                                  }
                                }
      | expr T_PLUS expr           {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                    {
                                      fprintf(yyout,"\n\tadd $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$->type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                  }
      | expr T_MINUS expr         {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsub $t%d $t%d $t%d",curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$->type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                  }
    | expr T_MULT expr            {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                      {
                                        fprintf(yyout,"\n\tmul $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                        pop(vars_temp_mips);
                                        $$->type = int_val;
                                      }
                                      else
                                      {
                                        yyerror("Syntax error (type)");
                                      }
                                  }
    | expr T_DIV expr            {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                      {
                                        fprintf(yyout,"\n\tdiv $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                        pop(vars_temp_mips);
                                        $$->type = int_val;
                                      }
                                      else
                                      {
                                        yyerror("Syntax error (type)");
                                      }
                                  }
    | expr T_POW expr             {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                    {
                                      if(!pow_exist)
                                      {
                                        pow_exist = true;
                                      }
                                      char* code = "\n\tmove $a2 $t%d\n\tmove $a3 $t%d\n\tmove $t8 $a2\n\tjal pow\n\tmove $t%d $t8";
                                      fprintf(yyout,code, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips), curr_idx(vars_temp_mips)-1);
                                      pop(vars_temp_mips);
                                      $$->type = int_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                 }
    | expr T_LE expr             {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsle $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$->type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                 }
      | expr T_LT expr           {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                    {
                                      fprintf(yyout,"\n\tslt $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$->type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                 }
      | expr T_GE expr           {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsge $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$->type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                 }
      | expr T_GT expr           {
                                    $$=$1;
                                    if ($1->type == int_val && $3->type == int_val)
                                    {
                                      fprintf(yyout,"\n\tsgt $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                      pop(vars_temp_mips);
                                      $$->type = bool_val;
                                    }
                                    else
                                    {
                                      yyerror("Syntax error (type)");
                                    }
                                 }
      | expr T_EQ expr           {
                                  $$=$1;
                                  if (($1->type == int_val || $1->type == bool_val) && $1->type == $3->type )
                                  {
                                    fprintf(yyout,"\n\tseq $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$->type = $1->type;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error (type)");
                                  }
                                }
      | expr T_NE expr          {
                                  $$=$1;
                                  if (($1->type == int_val || $1->type == bool_val) && $1->type == $3->type )
                                  {
                                    fprintf(yyout,"\n\tsne $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$->type = $1->type;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error (type)");
                                  }
                                }
      | expr T_AND expr         {
                                  $$=$1;
                                  if ($1->type == bool_val && $3->type == bool_val)
                                  {
                                    fprintf(yyout,"\n\tand $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$->type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error (type)");
                                  }
                                }

      | expr T_OR expr          {
                                  $$=$1;
                                  if ($1->type == bool_val && $3->type == bool_val)
                                  {
                                    fprintf(yyout,"\n\tor $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$->type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error (type)");
                                  }
                                }
      | expr T_XOR expr         {
                                  $$=$1;
                                  if ($1->type == bool_val && $3->type == bool_val)
                                  {
                                    fprintf(yyout,"\n\txor $t%d $t%d $t%d", curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                    pop(vars_temp_mips);
                                    $$->type = bool_val;
                                  }
                                  else
                                  {
                                    yyerror("Syntax error (type)");
                                  }
                                }
      | T_IDENT                 {
                                  $$=malloc(sizeof(var));
                                  struct variable* var = getVar($1);

                                  if (var == NULL || !var->init )
                                  {
                                    yyerror("Syntax error (NULL ou init)");
                                  }

                                  if ((int)var->context > size(contextes))
                                  {
                                    yyerror("Syntax error (context)");
                                  }
                                  push(vars_temp_mips, size(contextes));
                                  fprintf(yyout,"\n\tlw $t%d %d($sp)", curr_idx(vars_temp_mips),var->p_memoire);
                                  $$->type = var->type;
                                }

      | T_IDENT T_BRAOUV exprlist T_BRAFER {
                                              $$=malloc(sizeof(var));
                                              varArray* temp_array = getArray($1);
                                              variable* temp_var = temp_array->array;

                                              if (temp_var == NULL || !temp_var->init )
                                              {
                                                yyerror("Syntax error (NULL ou init)");
                                              }

                                              if ((int)temp_var->context > size(contextes))
                                              {
                                                yyerror("Syntax error (context)");
                                              }

                                              rangelist_type* current_rangelist = temp_array->range;
                                              if(current_rangelist == NULL)
                                              {
                                                yyerror("Syntax error (current_rangelist)");
                                              }

                                              exprlist_type* current_exprlist = $3;
                                              if(current_exprlist==NULL)
                                              {
                                                yyerror("Syntax error (exprlist)");
                                              }

                                              if(current_exprlist->nbelement < temp_array->dim )
                                              {
                                                  yyerror("Syntax error (dim)");
                                              }

                                              int p_memoire = temp_var->p_memoire;
                                              int lec_temp = 0;
                                              while(current_exprlist != NULL)
                                              {
                                                if(lec_temp == 0)
                                                {
                                                  push(vars_temp_mips, size(contextes));
                                                }
                                                var* temp_expr = current_exprlist->expr;
                                                if(temp_expr->type != int_val)
                                                {
                                                  yyerror("Syntax error (type array)");
                                                }
                                                if(current_rangelist == NULL)
                                                {
                                                  yyerror("Syntax error (read out array)");
                                                }
                                                
                                               
                                                fprintf(yyout,"\n\tli $t%d %d", curr_idx(vars_temp_mips),current_rangelist->fin);
                                                fprintf(yyout,"\n\tbgt $t%d $t%d error", lec_temp, curr_idx(vars_temp_mips));
                                                
                                                fprintf(yyout,"\n\tli $t%d %d", curr_idx(vars_temp_mips),current_rangelist->deb);
                                                fprintf(yyout,"\n\tblt $t%d $t%d error", lec_temp, curr_idx(vars_temp_mips));
                                                fprintf(yyout,"\n\tsub $t%d $t%d $t%d",curr_idx(vars_temp_mips), lec_temp, curr_idx(vars_temp_mips));
                                                if(lec_temp == 0)
                                                {
                                                  push(vars_temp_mips, size(contextes));
                                                  fprintf(yyout,"\n\tmul $t%d $t%d %d\n", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips)-1,  current_rangelist->totLenght/current_rangelist->length);
                                                  pop(vars_temp_mips);
                                                  fprintf(yyout,"\n");
                                                }
                                                else
                                                {
                                                  fprintf(yyout,"\n\tmul $t%d $t%d %d", curr_idx(vars_temp_mips), curr_idx(vars_temp_mips),  current_rangelist->totLenght/current_rangelist->length);
                                                   push(vars_temp_mips, size(contextes));
                                                  fprintf(yyout,"\n\tadd $t%d $t%d $t%d\n",curr_idx(vars_temp_mips), curr_idx(vars_temp_mips)-1, curr_idx(vars_temp_mips));
                                                  pop(vars_temp_mips);
                                                }

                                                current_exprlist=current_exprlist->suivant;
                                                current_rangelist = current_rangelist->suivant;
                                                lec_temp++;
                                              }
                                              
                                              fprintf(yyout,"\n\tli $t%d %d",curr_idx(vars_temp_mips)-lec_temp, p_memoire);
                                              fprintf(yyout,"\n\tadd $t%d $t%d $t%d", curr_idx(vars_temp_mips)-lec_temp, curr_idx(vars_temp_mips)-lec_temp,curr_idx(vars_temp_mips)+1);
                                              fprintf(yyout,"\n\tmul $t%d $t%d   4", curr_idx(vars_temp_mips)-lec_temp, curr_idx(vars_temp_mips)-lec_temp);
                                              fprintf(yyout,"\n\tadd $t%d, $sp, $t%d", curr_idx(vars_temp_mips)-lec_temp, curr_idx(vars_temp_mips)-lec_temp);
                                              fprintf(yyout,"\n\tlw $t%d 0($t%d)", curr_idx(vars_temp_mips)-lec_temp, curr_idx(vars_temp_mips)-lec_temp);

                                              int i;
                                              for(i = lec_temp; i>0; i--)
                                              {
                                                pop(vars_temp_mips);
                                              }

                                              
                                              $$->type = temp_array->type;
                                           };

cte : T_INTEGER                 {
                                  $$=malloc(sizeof(var));
                                  $$->val = $1;
                                  $$->type = int_val;
                                }
    | T_BOOLEAN                 {
                                  $$=malloc(sizeof(var));
                                  $$->val = $1;
                                  $$->type = bool_val;
      }
    | T_STRING                  {
                                  $$=malloc(sizeof(var));
                                  $$->val = $1;
                                  $$->type = string_val;
                                };

%%

void yyerror (char *s) {
  fprintf(stderr, "[Yacc] error: %s\n", s);
  exit(1);
}

void init ()
{
  contextes = newStack();
  vars_temp_mips = newStack();
  initVarTab();
  initArrayTab();
  init_symbols_array();
}

void initData()
{
  fprintf(yyout, ".data\n");
  fprintf(yyout, "\terrorMessage:\t.asciiz\t\"Error Syntax run time\"\n");
  fprintf(yyout, "\treadMessage:\t.asciiz\t\"Please write an int and 0 for false and 1 for true:\\n\"\n");
}

void insert_procedures ()
{
  if (pow_exist) {
    fprintf(yyout, "\npow:\n\tmul $t8 $t8 $a2\n\tadd $t9 $t9 1\n\tbne $t9 $a3 pow\n\tjr $ra\n\t");
  }

  fprintf(yyout,"\n\nerror:\n\tla $a0 errorMessage\n\tli $v0 4\n\tsyscall\n\tli $v0 10\n\tsyscall");
}

void version() {
  fprintf(stderr, "Scalpa to Mips compiler\n");
  fprintf(stderr, "Usage: ./scalpa [-version] [-help] [-tos] [-tov] [-toa] [-o <out_file>] in_file\n\n");

  fprintf(stderr, "Arguments:\n");
  fprintf(stderr, "-version / -help\t display this help and exit.\n");
  fprintf(stderr, "-tos\t\t\t displays the table of symbols before exiting.\n");
  fprintf(stderr, "-tov\t\t\t displays the table of variables before exiting.\n");
  fprintf(stderr, "-toa\t\t\t displays the table of arrays before exiting.\n");
  fprintf(stderr, "-o <out_file>\t\t specify the output file for MIPS code, if not specified, defaults to <in_file>.s in the same directory as input file\n");
  fprintf(stderr, "in_file (required):\t path to the file containing the SCALPA code to be compiled into MIPS.\n\n");

  fprintf(stderr, "Created by:\n");
  fprintf(stderr, "- Hugo Brua\n");
  fprintf(stderr, "- Louis Politanski\n");
  fprintf(stderr, "- Maxime Princelle\n\n");

  fprintf(stderr, "More info at: https://share.princelle.org/scalpa-to-mips\n");

  exit(0);
}

int main(int argc, char* argv[])
{
  init();

  if (argc < 2) {
      fprintf(stderr, "Usage: %s [-version] [-help] [-tos] [-tov] [-toa] [-o <out_file>] in_file\n", argv[0]);
      exit(1);
  }

  char* optin_out_file;
  bool t_symbols_display = false;
  bool t_variables_display = false;
  bool t_arrays_display = false;

  // Handle options
  int optind;
  for (optind = 1; optind < argc && argv[optind][0] == '-'; optind++) {
    if (strcmp("-o", argv[optind]) == 0) {
      optin_out_file = argv[optind+1];

    } else if (strcmp("-version", argv[optind]) == 0) {
      version();

    } else if (strcmp("-help", argv[optind]) == 0) {
      version();

    } else if (strcmp("-tos", argv[optind]) == 0) {
      t_symbols_display = true;

    } else if (strcmp("-tov", argv[optind]) == 0) {
      t_variables_display = true;

    } else if (strcmp("-toa", argv[optind]) == 0) {
      t_arrays_display = true;

    } else {
      fprintf(stderr, "Usage: %s [-version] [-help] [-tos] [-tov] [-toa] [-o <out_file>] in_file\n", argv[0]);
      exit(1);
    }
  }

  char* in_file = argv[argc-1];
  int in_file_length = strlen(in_file);

  yyin = fopen(in_file, "r");

  if (yyin == NULL) {
      fprintf(stderr, "Unable to open file: %s\nDetails: ", argv[1]);
      perror("fopen");
      exit(1);
  }

  char* out_file;

  if (optin_out_file && !optin_out_file[0]) {
    // No file specified for output, build one from input file.
    out_file=strdup(optin_out_file);

  } else {
    // Use specified output file.
    out_file = strdup(in_file);
    strcpy(&out_file[in_file_length-4],&out_file[in_file_length]);
    out_file = strcat(out_file,".s");
  }

  // Erase content of file and/or create a new one
  fclose(fopen(out_file, "w+"));

  // Open output file
  yyout = fopen(out_file, "w");

  if (yyout == NULL) {
      fprintf(stderr, "Unable to open file: %s\nDetails: ", out_file);
      perror("fopen");
      exit(1);
  }

  initData();

  yyparse();

  insert_procedures();

  // Display table of symbols if wanted.
  if (t_variables_display) {
    fprintf(stderr, "\n\n__Table des variables__\n\n");
    vars_to_string(stderr);
  }

  // Display table of symbols if wanted.
  if (t_arrays_display) {
    fprintf(stderr, "\n\n__Table des arrays__\n\n");
    arrays_to_string(stderr);
  }

  // Display table of symbols if wanted.
  if (t_symbols_display) {
    fprintf(stderr, "\n\n__Table des symboles__\n\n");
    display_symbols_table(stderr);
  }

  

  fclose(yyin);
  fclose(yyout);

  // Be clean.
  //lex_free();
  return 0;
}
