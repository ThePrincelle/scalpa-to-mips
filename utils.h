#ifndef __UTILS__
#define __UTILS__

typedef struct vector_def {
  void** data;
  int size;
  int capacity;
}Vector;

void vector_init(Vector v);
void vector_size(Vector v);
void vector_capacity(Vector v);
void vector_add(Vector v, void* item);

#endif