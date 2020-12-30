#include "pile.h"
 
int default_capacity = 10;

// Data structure for stack
struct stack
{
    int maxsize;    // define max capacity of stack
    int top;        
    int *items;
};
 
// Utility function to initialize stack
struct stack* newStack()
{
    struct stack *pt = (struct stack*)malloc(sizeof(struct stack));
 
    pt->maxsize = default_capacity;
    pt->top = -1;
    pt->items = (int*)malloc(sizeof(int) * default_capacity);
 
    return pt;
}
 
// Utility function to return the size of the stack
int size(struct stack *pt)
{
    return pt->top + 1;
}
 
// Utility function to check if the stack is empty or not
int isEmpty(struct stack *pt)
{
    return pt->top == -1;    // or return size(pt) == 0;
}
 
// Utility function to check if the stack is full or not
int isFull(struct stack *pt)
{
    return pt->top == pt->maxsize - 1;    // or return size(pt) == pt->maxsize;
}
 
// Utility function to add an element x in the stack
void push(struct stack *pt, int x)
{
    // check if the stack is already full. Then inserting an element would 
    // lead to stack overflow
    if (isFull(pt))
    {
        pt->maxsize*=2;
        pt = (struct stack *)realloc(pt, pt->maxsize * sizeof(char*));
    }
 
    printf("Inserting %d\n", x);
    
    // add an element and increments the top index
    pt->items[++pt->top] = x;
}
 
// Utility function to return top element in a stack
int peek(struct stack *pt)
{
    // check for empty stack
    if (!isEmpty(pt))
        return pt->items[pt->top];
    else
        exit(EXIT_FAILURE);
}
 
// Utility function to pop top element from the stack
int pop(struct stack *pt)
{
    // check for stack underflow
    if (isEmpty(pt))
    {
        printf("Pile vide (pop de trop) (voir contextes).\nProgram Terminated !\n");
        exit(EXIT_FAILURE);
    }
 
    printf("Removing %d\n", peek(pt));
 
    // decrement stack size by 1 and (optionally) return the popped element
    return pt->items[pt->top--];
}
 