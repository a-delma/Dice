; ModuleID = 'MicroC'
source_filename = "MicroC"

%f_i32_i32_struct = type { i32 (%f_i32_i32_struct*, i32)* }

@temp = global i32 0
@temp2 = global i32 0
@hello = global i1 false
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@fmt.1 = private unnamed_addr constant [4 x i8] c"%g\0A\00", align 1

declare i32 @putchar_with_closure(%f_i32_i32_struct*, i32)

declare i32 @putchar(i32)

define i32 @main() {
entry:
  %putchar = alloca i32 (%f_i32_i32_struct*, i32)*
  %putchar1 = call i32 @putchar(i32 72)
  %putchar2 = call i32 @putchar(i32 69)
  %putchar3 = call i32 @putchar(i32 76)
  %putchar4 = call i32 @putchar(i32 76)
  %putchar5 = call i32 @putchar(i32 79)
  %putchar6 = call i32 @putchar(i32 32)
  %putchar7 = call i32 @putchar(i32 87)
  %putchar8 = call i32 @putchar(i32 79)
  %putchar9 = call i32 @putchar(i32 82)
  %putchar10 = call i32 @putchar(i32 76)
  %putchar11 = call i32 @putchar(i32 68)
  %putchar12 = call i32 @putchar(i32 33)
  %putchar13 = call i32 @putchar(i32 10)
  ret i32 0
}
