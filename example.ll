; The following LLVM code will be generated for this Dice program

; lambda (Int arg) -> [Int -> Void] {
;   lambda () -> Void {
;     putchar(arg);
;   }
; }(68)();
;

%Node_ = type { ; this is closure type
    i8*,
    %Node_*
}

%Function_ = type {
    void (...)*, ; function pointer
    %Node_*      ; closure
}

declare i8* @get_node(%Node_*, i32)
declare %Node_* @append_to_list(%Node_*, i8*)
declare %Node_* @get_null_list()
declare i8*     @malloc_(i32)
declare i32 @putchar_helper(%Function_*, i32)

@putchar_ = external externally_initialized global %Function_

define i32 @main() {
  entry:
    ; only need to call once at the top of main
    call i32 @initialize()
    
    ; set up empty closure for outer lambda
    %size_    = getelementptr %Function_*, %Function_** null, i32 1
    %size_int = ptrtoint %Function_** %size_ to i32
    %outer_lambda_opaque  = call i8* @malloc_(i32 %size_int)
    %outer_lambda         = bitcast i8* %outer_lambda_opaque to %Function_*

    %opaque_func       = bitcast %Function_* (%Function_*, i32)* @outer_lambda to void(...)*
    %func_field_ptr    = getelementptr inbounds %Function_, %Function_* %outer_lambda, i32 0, i32 0
                         store void(...)* %opaque_func, void(...)** %func_field_ptr

    ; call outer lambda 
    ; this is a bit verbose but I believe that would be how codegen works
    %func_field_ptr1   = getelementptr inbounds %Function_, %Function_* %outer_lambda, i32 0, i32 0
    %opaque_func1      = load void(...)*, void(...)** %func_field_ptr1
    %callable          = bitcast void(...)* %opaque_func1 to %Function_* (%Function_*, i32)*
    %inner_lambda      = call %Function_* %callable(%Function_* %outer_lambda, i32 68)

    ; call inner lambda
    %func_field_ptr2   = getelementptr inbounds %Function_, %Function_* %inner_lambda, i32 0, i32 0
    %opaque_func2      = load void(...)*, void(...)** %func_field_ptr2
    %callable1         = bitcast void(...)* %opaque_func2 to i32 (%Function_*)*
    %call              = call i32 %callable1(%Function_* %inner_lambda)
    ret i32 0
}

define i32 @initialize() {
  ; will have to add casting functions here
  %opaque_func     = bitcast i32 (%Function_*, i32)* @putchar_helper to void(...)*
  %func_field_ptr  = getelementptr inbounds %Function_, %Function_* @putchar_, i32 0, i32 0
                     store void(...)* %opaque_func, void(...)** %func_field_ptr
  ret i32 0;
}

define %Function_* @outer_lambda(%Function_* %self, i32 %arg) {
  entry:
    %size_    = getelementptr %Function_*, %Function_** null, i32 1
    %size_int = ptrtoint %Function_** %size_ to i32
    %func_opaque  = call i8* @malloc_(i32 %size_int)
    %func         = bitcast i8* %func_opaque to %Function_*

    %opaque_func     = bitcast i32 (%Function_*)* @inner_lambda to void(...)*
    %func_field_ptr  = getelementptr inbounds %Function_, %Function_* %func, i32 0, i32 0
                       store void(...)* %opaque_func, void(...)** %func_field_ptr

    %closure            = call %Node_* @get_null_list()

    %size_1             = getelementptr i32*, i32** null, i32 1
    %size_int1          = ptrtoint i32** %size_1 to i32
    %arg_opaque         = call i8* @malloc_(i32 %size_int1)
    %arg_ptr            = bitcast i8* %arg_opaque to i32*

                          store i32 %arg, i32* %arg_ptr 
    %opaque_arg_ptr     = bitcast i32* %arg_ptr to i8*
    %closure1           = call %Node_* @append_to_list(%Node_* %closure, i8* %opaque_arg_ptr)
    %closure_field_ptr  = getelementptr inbounds %Function_, %Function_* %func, i32 0, i32 1
                          store %Node_* %closure1, %Node_** %closure_field_ptr
    ret %Function_* %func
}


define i32 @inner_lambda(%Function_* %self) {
  entry:
    ; load closure
    %closure_ptr    = getelementptr inbounds %Function_, %Function_* %self, i32 0, i32 1
    %closure        = load %Node_*, %Node_** %closure_ptr

    ; load relevant argument from closure
    %opaque_arg_ptr = call i8* @get_node(%Node_* %closure, i32 0)
    %arg_ptr        = bitcast i8* %opaque_arg_ptr to i32*
    %arg            = load i32, i32* %arg_ptr

    ; now call putchar
    %func_field_ptr1   = getelementptr inbounds %Function_, %Function_* @putchar_, i32 0, i32 0
    %opaque_func1      = load void(...)*, void(...)** %func_field_ptr1
    %callable          = bitcast void(...)* %opaque_func1 to i32 (%Function_*, i32)*
    %call1 = call i32 %callable(%Function_* @putchar_, i32 %arg)
    ret i32 0
}