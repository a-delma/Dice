// The file with the C code to be imported at code generation phase
// Author(s): Sasha Fedchin, Diego Griese

#include <stdio.h>
#include <stdlib.h>
#include <time.h>             

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

char* malloc_(int64_t size) {
  return (char*) malloc(size);
}

// Built-in:


// The implementation of random number generation functions below 
// (myrand and mysrand) are modified version of corresponding 
// functions from the Open Group Base Specifications C Documentation
// (https://pubs.opengroup.org/onlinepubs/9699919799/functions/rand.html)
unsigned long next;

float uni_helper(struct Function_* closure)  {
    next = next * 1103515245 + 12345;
    return ((unsigned)(next/65536) % 32768) / 32768.0;
}

void set_seed_helper(struct Function_* closure, int seed) {
    next = seed;
}

void putchar_helper(struct Function_* closure, int c) {
  printf("%c", c);
}

void print_float_helper(struct Function_* closure, float f) {
  printf("%f", f);
}

float int_to_float_helper(struct Function_* closure, int toCast) {
  return ((float) toCast);
}

int int_to_bool_helper(struct Function_* closure, int toCast) {
  return toCast == 0 ? 0 : 1;
}

int float_to_int_helper(struct Function_* closure, float toCast) {
  return ((int) toCast);
}

int float_to_bool_helper(struct Function_* closure, float toCast) {
  return uni_helper(closure) <= toCast ? 1 : 0;
}

float bool_to_float_helper(struct Function_* closure, int toCast) {
  return toCast == 0 ? 0.0 : 1.0;
}

int bool_to_int_helper(struct Function_* closure, int toCast) {
  return toCast;
}

struct Function_* putchar_;
struct Function_* print_float_;
struct Function_* uni_;
struct Function_* set_seed_;
struct Function_* int_to_float_;
struct Function_* int_to_bool_;
struct Function_* float_to_int_;
struct Function_* float_to_bool_;
struct Function_* bool_to_int_;
struct Function_* bool_to_float_;

void initialize(int seed){
  
  //BEGINNING SEED
  srand((unsigned long) time(NULL));
  next = seed < 0  ? rand() : seed;

  putchar_ = (struct Function_*) malloc(sizeof(struct Function_));
  putchar_->closure = NULL;
  putchar_->ptr = (void*) putchar_helper;

  print_float_ = (struct Function_*) malloc(sizeof(struct Function_));
  print_float_->closure = NULL;
  print_float_->ptr = (void*) print_float_helper;

  uni_ = (struct Function_*) malloc(sizeof(struct Function_));
  uni_->closure = NULL;
  uni_->ptr = (void*) uni_helper;

  set_seed_ = (struct Function_*) malloc(sizeof(struct Function_));
  set_seed_->closure = NULL;
  set_seed_->ptr = (void*) set_seed_helper;
  
  int_to_float_ = (struct Function_*)malloc(sizeof(struct Function_));
  int_to_float_->closure = NULL;
  int_to_float_->ptr = (void*) int_to_float_helper;

  float_to_int_ = (struct Function_*)malloc(sizeof(struct Function_));
  float_to_int_->closure = NULL;
  float_to_int_->ptr = (void*) float_to_int_helper;

  float_to_bool_ = (struct Function_*)malloc(sizeof(struct Function_));
  float_to_bool_->closure = NULL;
  float_to_bool_->ptr = (void*) float_to_bool_helper;

  int_to_bool_ = (struct Function_*)malloc(sizeof(struct Function_));
  int_to_bool_->closure = NULL;
  int_to_bool_->ptr = (void*) int_to_bool_helper;

  bool_to_float_ = (struct Function_*)malloc(sizeof(struct Function_));
  bool_to_float_->closure = NULL;
  bool_to_float_->ptr = (void*) bool_to_float_helper;

  bool_to_int_ = (struct Function_*)malloc(sizeof(struct Function_));
  bool_to_int_->closure = NULL;
  bool_to_int_->ptr = (void*) bool_to_int_helper;
}
