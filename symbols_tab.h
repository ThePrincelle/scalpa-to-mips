#ifndef SYMBOLS_TABS_H
#define SYMBOLS_TABS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Utility function to initialize symbols_array
void initSymbolsTab();

/*
    Function that either adds the symbol to the table of if it already exists do nothing.
*/
void insertSymbol(char* name, int type);

/*
  Get string value of enum type
*/
char* getSymbolType(int type);

/*
  Displays the symbols table
*/
void display_symbols_table(FILE *returns);

#endif
