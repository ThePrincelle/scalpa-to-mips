#ifndef VARARRAY_H
#define VARARRAY_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "variables_tab.h"

int arrays_count;
int arrays_capacity;

typedef struct rangelist_type{
    int deb;
    int fin;
    int length;
    struct rangelist_type* suivant;
}rangelist_type;

typedef struct arraytype_type{
      int type;
      struct rangelist_type* rangelist;
}arraytype_type;

// Define the variable structure.
typedef struct varArray {
  variable* array;
  rangelist_type* range;
  int dim;
  int nbvars;
  int type;
}varArray;

// Utility function to initialize vars_array
void initArrayTab();

/*
  Function that returns the saved variables in a given char address.
*/
void arrays_to_string(FILE *returns);

/*
  Function that simply returns the code of the variable given in the array of variables.
  If the variable does not exists, return NULL.
*/
varArray* getArray(char* varName);

/*
  Function that returns the result of the insertion in the vars_array.
*/
varArray* insertArray(char* varName, int context, arraytype_type* arraytype, FILE *returns);
#endif
