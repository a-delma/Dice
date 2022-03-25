; This is a struct type for functions of type i8 -> i32.
; It consists of a function pointer and the closure.
; In our case, the closure is empty because the only function
; of this type in our program has empty closure. 
%functioni32i8 = type {
    i32 (%functioni32i8*, i8)* ; function pointer
}

; This is wrapper around @putchar that 
; takes the function struct with closure as argument and ignores it.
define i32 @putcharwithclosure(%functioni32i8* %closure, i8 %arg) {
entry:
  call i32 @putchar(i8 %arg)
  ret i32 0
}

declare i32 @putchar(i8)

define i32 @main() {
entry:

  ; Let's first create a function struct
  %putchar = alloca %functioni32i8

  ; Now we make the function pointer refer specifically to @putchar
  %functionptr = getelementptr %functioni32i8, %functioni32i8* %putchar, i32 0, i32 0 
  store i32 (%functioni32i8*, i8)* @putcharwithclosure, i32 (%functioni32i8*, i8)** %functionptr

  ; We would also set up the closure here
  ; We shouldn't worry about this now, but it might look like this:
  ; %argptr = getelementptr %functioni32i8, %functioni32i8* %putchar, i32 0, i32 1
  ; store i8 5, i8* %argptr

  ; ...... Arbitrary code preceding function call here

  ; At this point we are making a function call to %putchar.
  ; Let's load the corresponding function
  %functionptr1 = getelementptr %functioni32i8, %functioni32i8* %putchar, i32 0, i32 0 
  %function = load i32 (%functioni32i8*, i8)*, i32 (%functioni32i8*, i8)** %functionptr1

  ; Finally, we can make the function call
  call i32 %function(%functioni32i8* %putchar, i8 65)
  ret i32 0
}