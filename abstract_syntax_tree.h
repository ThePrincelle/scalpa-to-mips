#ifndef __ABSTRACT_SYNTAX_TREE__
#define __ABSTRACT_SYNTAX_TREE__

#include "utils.h"
#include "stdbool.h"

typedef enum nodetype_def {
  PROGRAM,
  INSTR,
  RETURN,
  IDENT,
  INTEGER,
  BOOLEAN
}NodeType;

typedef union nodedata_def {
  /* data */
  Vector child_nodes;
  int int_val;
  int bool_val;
  char* string_val;
}NodeValue;


typedef struct abstractsyntaxtree_def {
  NodeType node_type;
  NodeValue node_value;
}AbstractSyntaxTree;

#endif