#include <stdio.h>
#include <stdlib.h>

//BEGINNING SEED


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

float int_to_float_helper(struct Function_* closure, int toCast) {
  return (float) toCast;
}

int float_to_int_helper(struct Function_* closure, float toCast) {
  return (int) toCast;
}

float uni_helper(struct Function_* closure) {
  return ((float)rand()/(float)(RAND_MAX));
}
struct Function_* putchar_;
struct Function_* uni_;
struct Function_* int_to_float_;
struct Function_* float_to_int_;

void initialize(){
  //putchar init
  putchar_ = (struct Function_*) malloc(sizeof(struct Function_));
  putchar_->closure = NULL;
  putchar_->ptr = (void*) putchar_helper;

  
  //uni init
  srand(0);
  uni_ = (struct Function_*) malloc(sizeof(struct Function_));
  uni_->closure = NULL;
  uni_->ptr = (void*) uni_helper;

  //casting init
  int_to_float_ = (struct Function_*)malloc(sizeof(struct Function_));
  int_to_float_->closure = NULL;
  int_to_float_->ptr = (void*) int_to_float_helper;

  float_to_int_ = (struct Function_*)malloc(sizeof(struct Function_));
  float_to_int_->closure = NULL;
  float_to_int_->ptr = (void*) float_to_int_helper;
}
