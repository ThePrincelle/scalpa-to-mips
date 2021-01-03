#include "array_tab.h"

int arrays_count;
int arrays_capacity = 10;
int arrays_vars = 0;

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

  if(arrays_count == 0)
  {
    fprintf(stderr, "No arrays found.\n\n");
  }

  int i,y;
  for (i = 0; i < arrays_count; i++){
      // For each variable in the table, compare if it is the same as the input variable.
      varArray* current_array = arrays_array[i];
      variable* act_array = current_array->array;
      rangelist_type* currant_rangelist = current_array->range;
      int nbvars = current_array->nbvars;

      char str_range[100];
      char tmp_buff[100];
      bool first = true;
      while(currant_rangelist != NULL)
      {
        if(first)
        {
           snprintf(tmp_buff,100,"[%d..%d",currant_rangelist->deb, currant_rangelist->fin);
        }
        else
        {
           snprintf(tmp_buff,100,"%s,%d..%d",str_range,currant_rangelist->deb, currant_rangelist->fin);
        }
        snprintf(str_range,100,"%s",tmp_buff);
        currant_rangelist = currant_rangelist->suivant;
        first = false;
      }
      snprintf(tmp_buff,100,"%s]",str_range);
      snprintf(str_range,100,"%s",tmp_buff);
      fprintf(returns, "scalpavar: %s%s -- mipsvar: %d($sp) %d($sp)\n", act_array->scalpavar,str_range, act_array->p_memoire,nbvars*4);
  }
  fprintf(returns, "\n");
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
varArray* insertArray(char* varName, int context, arraytype_type* arraytype, FILE *returns)
{
    int type = arraytype->type;
    rangelist_type* rangelist = arraytype->rangelist;
    int dim = 0;
    int nbvars = 1;

    // If we add the variable in the table, update the variable_capacity
    if (arrays_count >= arrays_capacity) {
        arrays_capacity*=2;
        arrays_array = (varArray**)realloc(arrays_array, arrays_capacity * sizeof(varArray*));
    }

    rangelist_type* current_rangelist = rangelist;
    while (current_rangelist != NULL)
    {
        nbvars *= current_rangelist->length;
        dim ++;
        current_rangelist = current_rangelist->suivant;
    }

    variable* array = insertVar(varName,context,5,nbvars-1);//type = array_val

    varArray* new_array = malloc(sizeof(varArray));
    new_array->array = array;
    new_array->range = rangelist;
    new_array->dim = dim;
    new_array->nbvars = nbvars;
    new_array->type = type;

    arrays_array[arrays_count] = new_array;
    arrays_count++;
    arrays_vars += nbvars;
    

    // Variable successfully added. Return true then.
    return new_array;
}
