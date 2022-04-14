typedef void (*FPtr)();
struct Function_ {
  FPtr   ptr;
  struct Node_* closure;
};


// Built-in:

int putchar_helper(struct Function_* closure, int c) {
  return 0;
}
struct Function_* putchar_;

int initialize(){
  putchar_->closure = 0;
  putchar_->ptr = (void*) putchar_helper;
  return 0;
}