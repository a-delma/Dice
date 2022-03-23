; ModuleID = 'MicroC'
source_filename = "MicroC"

@temp = global i32 0
@hello = global i1 false
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@fmt.1 = private unnamed_addr constant [4 x i8] c"%g\0A\00", align 1

declare i32 @putchar(i32)

define i32 @main() {
entry:
  %putchar = call i32 @putchar(i32 72)
  %putchar1 = call i32 @putchar(i32 69)
  %putchar2 = call i32 @putchar(i32 76)
  %putchar3 = call i32 @putchar(i32 76)
  %putchar4 = call i32 @putchar(i32 79)
  %putchar5 = call i32 @putchar(i32 32)
  %putchar6 = call i32 @putchar(i32 87)
  %putchar7 = call i32 @putchar(i32 79)
  %putchar8 = call i32 @putchar(i32 82)
  %putchar9 = call i32 @putchar(i32 76)
  %putchar10 = call i32 @putchar(i32 68)
  %putchar11 = call i32 @putchar(i32 33)
  %putchar12 = call i32 @putchar(i32 10)
  ret i32 0
}
