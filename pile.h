#ifndef PILE_H
#define PILE_H

#include <stdio.h>
#include <stdlib.h>

// Data structure for stack
struct stack;
 
// Utility function to initialize stack
struct stack* newStack();
 
// Utility function to return the size of the stack
int size(struct stack *pt);

// Utility function to check if the stack is full or not
int isFull(struct stack *pt);
 
// Utility function to add an element x in the stack
void push(struct stack *pt, int x);
 
// Utility function to return top element in a stack
int peek(struct stack *pt);
 
// Utility function to pop top element from the stack
int pop(struct stack *pt);

#endif