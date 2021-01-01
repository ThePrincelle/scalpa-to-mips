#include "varArray.h"


int arrays_count;
int arrays_capacity = 10;

varArray** arrays_array;

// Utility function to initialize vars_array
void initArrayTab(){
    arrays_array = malloc(arrays_capacity*sizeof(varArray*));
}

/*
  Function that returns the saved variables in a given char address.
*/
void arrays_to_string(FILE *returns)
{
  int i,y;

  for (i = 0; i < arrays_count; i++){
      // For each variable in the table, compare if it is the same as the input variable.
      varArray* current_array = arrays_array[i];
      variable* act_array = current_array->array;
      variable** act_vars = current_array->vars;
      rangelist_type* currant_rangelist = current_array->range;
      char* str_range = "[";
      while(currant_rangelist != NULL)
      {
        snprintf(str_range,strlen(str_range),"%s,%d..%d",str_range,currant_rangelist->deb, currant_rangelist->fin);
        currant_rangelist = currant_rangelist->suivant;
      }
      snprintf(str_range,strlen(str_range),"%s]",str_range);
      fprintf(returns, "scalpavar: %s%s -- mipsvar: %d($sp)\n", act_array->scalpavar,str_range, act_array->p_memoire);
      for (y = 0; y < current_array->nbvars; y++)
      {
        variable* act_var = act_vars[i];
        fprintf(returns, "mipsvar: %d($sp)\n", act_array->p_memoire);        
      }
  }
}

/*
  Function that simply returns the code of the variable given in the array of variables.
  If the variable does not exists, return NULL.
*/
varArray* getArray(char* varName){
  int i;
  for (i = 0; i < arrays_count; i++){
      // For each variable in the table, compare if it is the same as the input variable.
      if (strcmp(arrays_array[i]->array->scalpavar, varName) == 0){
          return arrays_array[i]; // Return the position of the variable in the table
      }
  }
  return NULL;
}

/*
  Function that returns the result of the insertion in the vars_array.
*/
varArray* insertArray(char* varName, int context, arraytype_type* arraytype)
{
    int type = arraytype->type;
    rangelist_type* rangelist = arraytype->rangelist;
    int dim = 1;
    int nbvars = 1;

    // If we add the variable in the table, update the variable_capacity
    if (arrays_count >= arrays_capacity) {
        arrays_capacity*=2;
        arrays_array = (varArray**)realloc(arrays_array, arrays_capacity * sizeof(varArray*));
    }

    rangelist_type* current_rangelist = rangelist;
    while (rangelist != NULL)
    {
        nbvars *= current_rangelist->length;
        dim ++;
        current_rangelist = current_rangelist->suivant;
    }

    int i;
    variable** vars = (variable**)malloc(nbvars*sizeof(variable*));
    for (i=0; i<nbvars;i++)
    {
        vars[i] = newVar("",context,type);
    }

    varArray* new_array = malloc(sizeof(varArray*));
    new_array->array = insertVar(varName,context,5);//type = array_val
    new_array->range = rangelist;
    new_array->vars = vars;
    new_array->dim = dim;
    new_array->nbvars = nbvars;
    new_array->type = type;

    arrays_array[arrays_count] = new_array;
    arrays_count++;

    // Variable successfully added. Return true then.
    return new_array;
}