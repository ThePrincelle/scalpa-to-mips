#include "variables_tab.h"

int vars_count;
int vars_capacity = 10;

variable** vars_array;

// Utility function to initialize vars_array
void initVarArray()
{
    vars_array = malloc(vars_capacity*sizeof(variable*));
}

/*
  Function that simply returns the code of the variable given in the array of variables.
  If the variable does not exists, return NULL.
*/
variable* getVar(char* varName){
  int i;
  for (i = 0; i < vars_count; i++){
      // For each variable in the table, compare if it is the same as the input variable.
      if (strcmp(vars_array[i]->scalpavar, varName) == 0){
          return vars_array[i]; // Return the position of the variable in the table
      }
  }

  return NULL;
}

/*
  Function that returns the saved variables in a given char address.
*/
void vars_to_string(FILE *returns)
{
  int i;
  for (i = 0; i < vars_count; i++){
      // For each variable in the table, compare if it is the same as the input variable.
      variable* act_val = vars_array[i];
      fprintf(returns, "scalpavar: %s -- mipsvar: %s\n", act_val->scalpavar, act_val->mipsvar);
  }

}

/*
  Function that returns the result of the insertion in the vars_array.
*/
bool insertVar(char* varName, char* mipsvar, int context, int type){
    // Retrieve the variable position in the table.
    variable* old_var = getVar(varName);

    // If the variable doesn't exist, create it.
    if(old_var != NULL)
    {
      // If the variable already exists in the current context, return false and do not insert it.
      if(old_var->context<=context)
      {
        return false;
      }
    }

    // If we add the variable in the table, update the variable_capacity
    if (vars_count >= vars_capacity) {
        vars_capacity*=2;
        vars_array = (variable**)realloc(vars_array, vars_capacity * sizeof(variable*));
    }

    variable* new_var = malloc(sizeof(variable*));
    new_var->scalpavar = strdup(varName);
    new_var->mipsvar = strdup(mipsvar);
    new_var->context = context;
    new_var->type = type;
    new_var->init = false;


    vars_array[vars_count] = new_var;
    vars_count++;

    // Variable successfully added. Return true then.
    return true;
}
