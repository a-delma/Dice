#include <stdio.h>
#include <stdlib.h>

// Basic lists (Node_) to use a closures
// Plus accompanying functions:

struct Node_
{
  char*         val;
  struct Node_* next;
};

struct Node_* append_to_list(struct Node_* list, char* val) {
  struct Node_* next = NULL;
  next = (struct Node_*) malloc(sizeof(struct Node_));
  next->val = val;
  next->next = NULL;
  if (list == NULL) {
    return next;
  }
  struct Node_* curr = list;
  while (curr->next != NULL) {
    curr = curr->next;
  }
  curr->next = next;
  return list;
}

char* get_node(struct Node_* list, int id) {
  while (id != 0) {
    list = list->next;
    id = id - 1;
  }
  return list -> val;
}

// Functions:

typedef void (*FPtr)();
struct Function_ {
  FPtr   ptr;
  struct Node_* closure;
};

char* malloc_(int size) {
  return (char*) malloc(size);
}

// Built-in:

int putchar_helper(struct Function_* closure, int c) {
  printf("%c", c);
  return 0;
}
struct Function_* putchar_;

void initialize(){
  putchar_ = (struct Function_*) malloc(sizeof(struct Function_));
  putchar_->closure = NULL;
  putchar_->ptr = (void*) putchar_helper;
}
