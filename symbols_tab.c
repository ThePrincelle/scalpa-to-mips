#include "symbols_tab.h"

int symbols_count;
int symbols_capacity = 10;

enum type {int_val, bool_val, string_val, unit_val, array_val};

typedef struct symbol {
  char* name;
  int type;
} symbol;

symbol** symbols_array;

// Utility function to initialize symbols_array
void init_symbols_array()
{
  symbols_array = malloc(symbols_capacity*sizeof(symbol*));
}

/*
    Function that either adds the symbol to the table of if it already exists do nothing.
*/
void insertSymbol(char* name, int type){

  // Search for the symbol in the table and return the code if it exists.
  int i;
  for (i = 0; i < symbols_count; i++){
      // For each symbol in the table, compare if it is the same as the input symbol.
      if (strcmp(symbols_array[i]->name, name) == 0 && symbols_array[i]->type == type){
        break; // Return the position of the symbol in the table
      }
  }

  // If we add the symbol in the table, update the symbol_capacity
  if (symbols_count >= symbols_capacity) {
      symbols_capacity*=2;
      symbols_array = (symbol**)realloc(symbols_array, symbols_capacity * sizeof(symbol*));
  }

  // Create new symbol object.
  symbol* new_symbol = malloc(sizeof(symbol));
  new_symbol->name = strdup(name);
  new_symbol->type = type;

  // Add the symbol to the list of symbols.
  symbols_array[symbols_count] = new_symbol;

  // Increment the symbol count
  symbols_count++;
}

/*
  Get string value of enum type
*/
char* getSymbolType(int type){
  switch(type){
    case int_val: return "integer";
    case bool_val: return "boolean";
    case string_val: return "string";
    case unit_val: return "unit";
    case array_val: return "array";
    default: return "unkown";
  }
}

/*
  Displays the symbols table
*/
void display_symbols_table(FILE *returns){
  if (symbols_count > 0) {
    // Display table
    fprintf(returns, "%s \t| \t %s \t| %s \n", "Index", "Symbole", "Type");
    fprintf(returns, "------------------------------------------- \n");

    int i;
    for (i = 0; i < symbols_count; i++) {
      fprintf(returns, "%d \t| \t %s \t\t| %s \n", i, symbols_array[i]->name, getSymbolType(symbols_array[i]->type));
    }

    fprintf(returns, "\n");
  }
  else {
    fprintf(returns, "No symbols found.\n\n");
  }
}
