#include "symbols_tab.h"

int symbols_count;
int symbols_capacity;
char** symbols_array;

/*
    Function that simply returns the code of the symbol given in the array of symbols.
*/
int getCodeSymbol(char* symbolName){
    int i;
    for (i = 1; i < symbols_count; i++){
        // For each symbol in the table, compare if it is the same as the input symbol.
        if (strcmp(symbols_array[i], symbolName) == 0){
            return i; // Return the position of the symbol in the table
        }
    }
    return 0;
}

/*
    Function that either adds the symbol to the table of if it already exists simply finds it.
    In every case, we return the code of the symbol in the table.
*/
int findOrInsertSymbol(char* symbolName){
    int i;

    // Search for the symbol in the table and return the code if it exists.
    for (i = 1; i < symbols_count; i++){
        // For each symbol in the table, compare if it is the same as the input symbol.
        if (strcmp(symbols_array[i], symbolName) == 0){
            return i; // Return the position of the symbol in the table
        }
    }

    // If we add the symbol in the table, update the symbol_capacity
    if (symbols_count >= symbols_capacity) {
        symbols_capacity*=2;
        symbols_array = (char**)realloc(symbols_array, symbols_capacity * sizeof(char*));
    }

    // Add symbol to the array and increment the symbol_count.
    char* txt = (char*)malloc(strlen(symbolName));
    strncpy(txt, symbolName, strlen(symbolName) + 1);
    symbols_array[symbols_count] = txt;
    symbols_count++;

    // Return the number of symbols in the array
    return symbols_count - 1;
}

/*
  Displays the symbols table
*/
void display_symbols_table(FILE *returns){
  if (symbols_count > 0) {
    // Display table
    fprintf(returns, "Index \t Symbole \t\n");

    int i;
    for (i = 1; i < symbols_count; i++) {
      fprintf(returns, "%d \t %s \t\n", i, symbols_array[i]);
    }

    fprintf(returns, "\n");
  }
  else {
    fprintf(returns, "No symbols found.\n");
  }
}
