#include "variables_tab.h"

int vars_count;
int vars_capacity;

// Define the variable structure.
struct variable {
  int context;
  char* mipsvar;
  char* scalpavar;
  int type;
};

struct variable** vars_array;

/*
  Function that simply returns the code of the variable given in the array of variables.
  If the variable does not exists, return NULL.
*/
struct variable* getVar(char* varName){
    int i;
    for (i = 1; i < vars_count; i++){
        // For each variable in the table, compare if it is the same as the input variable.
        if (strcmp(vars_array[i]->scalpavar, varName) == 0){
            return vars_array[i]; // Return the position of the variable in the table
        }
    }
    return NULL;
}

/*
  Function that returns the result of the insertion in the vars_array.
*/
bool insertVar(char* varName, char* mipsvar, int context, int type){
    int i;

    // Retrieve the variable position in the table.
    struct variable* old_var = getVar(varName);

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
        vars_array = (struct variable**)realloc(vars_array, vars_capacity * sizeof(struct variable*));
    }

    // Add variable to the array and increment the variable_count.
    char* scalpavar_txt = (char*)malloc(strlen(varName));
    strncpy(scalpavar_txt, varName, strlen(varName) + 1);

    // Add variable to the array and increment the variable_count.
    char* mipsvar_txt = (char*)malloc(strlen(mipsvar));
    strncpy(mipsvar_txt, mipsvar, strlen(mipsvar) + 1);

    struct variable* new_var =  malloc(sizeof(struct variable*));
    new_var->scalpavar = scalpavar_txt;
    new_var->mipsvar = mipsvar_txt;
    new_var->context = context;
    new_var->type = type;

    vars_array[vars_count] = new_var;
    vars_count++;

    // Variable successfully added. Return true then.
    return true;
}
