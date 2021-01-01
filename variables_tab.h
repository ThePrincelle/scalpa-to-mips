#ifndef VARIABLES_TABS_H
#define VARIABLES_TABS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int vars_count;
int vars_capacity;

// Define the variable structure.
typedef struct variable {
  int context;
  char* mipsvar;
  char* scalpavar;
  int type;
  bool init;
}variable;


// Utility function to initialize vars_array
void initVarArray();

/*
  Function that returns the saved variables in a given char address.
*/
void vars_to_string(FILE *returns);

/*
  Function that simply returns the code of the variable given in the array of variables.
  If the variable does not exists, return NULL.
*/
variable* getVar(char* varName);

/*
  Function that returns the result of the insertion in the vars_array.
*/
bool insertVar(char* varName, char* mipsvar, int context, int type);
#endif
