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


// The implementation of random number generation functions below 
// (myrand and mysrand) are modified version of corresponding 
// functions from the Open Group Base Specifications C Documentation
// (https://pubs.opengroup.org/onlinepubs/9699919799/functions/rand.html)
static unsigned long next = 1;
double uni_helper(struct Function_* closure)  {
    next = next * 1103515245 + 12345;
    return 32768.0 / ((unsigned)(next/65536) % 32768);
}

void set_seed_helper(struct Function_* closure, unsigned seed) {
    next = seed;
}

int putchar_helper(struct Function_* closure, int c) {
  printf("%c", c);
  return 0;
}
struct Function_* putchar_;
struct Function_* uni_;
struct Function_* set_seed_;

void initialize(){
  putchar_ = (struct Function_*) malloc(sizeof(struct Function_));
  putchar_->closure = NULL;
  putchar_->ptr = (void*) putchar_helper;

  uni_ = (struct Function_*) malloc(sizeof(struct Function_));
  uni_->closure = NULL;
  uni_->ptr = (void*) uni_helper;

  set_seed_ = (struct Function_*) malloc(sizeof(struct Function_));
  set_seed_->closure = NULL;
  set_seed_->ptr = (void*) set_seed_helper;
}
