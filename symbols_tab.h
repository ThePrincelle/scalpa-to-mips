#ifndef SYMBOLS_TABS_H
#define SYMBOLS_TABS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int symbols_capacity;
char** symbols_array;

/*
    Function that simply returns the code of the symbol given in the array of symbols.
*/
int getCodeSymbol(char* symbolName);

/*
    Function that either adds the symbol to the table of if it already exists simply finds it.
    In every case, we return the code of the symbol in the table.
*/
int findOrInsertSymbol(char* symbolName);

/*
  Displays the symbols table
*/
void display_symbols_table(FILE *returns);

#endif
