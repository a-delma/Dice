; ModuleID = 'MicroC'
source_filename = "MicroC"

%f_i32_i32_struct = type { i32 (%f_i32_i32_struct*, i32)* }

@temp = global i32 0
@temp2 = global i32 0
@hello = global i1 false
@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@fmt.1 = private unnamed_addr constant [4 x i8] c"%g\0A\00", align 1

declare i32 @putchar(i32)

define i32 @putchar_with_closure(%f_i32_i32_struct* %0, i32 %1) {
entry:
  %"we need to put something here" = call i32 @putchar(i32 %1)
  ret i32 0
}

define i32 @main() {
entry:
  %putChar = alloca %f_i32_i32_struct
  %ptr = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  store i32 (%f_i32_i32_struct*, i32)* @putchar_with_closure, i32 (%f_i32_i32_struct*, i32)** %ptr
  %ptr1 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr1
  %result = call i32 %fnc(%f_i32_i32_struct* %putChar, i32 72)
  %ptr2 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc3 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr2
  %result4 = call i32 %fnc3(%f_i32_i32_struct* %putChar, i32 69)
  %ptr5 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc6 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr5
  %result7 = call i32 %fnc6(%f_i32_i32_struct* %putChar, i32 76)
  %ptr8 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc9 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr8
  %result10 = call i32 %fnc9(%f_i32_i32_struct* %putChar, i32 76)
  %ptr11 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc12 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr11
  %result13 = call i32 %fnc12(%f_i32_i32_struct* %putChar, i32 79)
  %ptr14 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc15 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr14
  %result16 = call i32 %fnc15(%f_i32_i32_struct* %putChar, i32 32)
  %ptr17 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc18 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr17
  %result19 = call i32 %fnc18(%f_i32_i32_struct* %putChar, i32 87)
  %ptr20 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc21 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr20
  %result22 = call i32 %fnc21(%f_i32_i32_struct* %putChar, i32 79)
  %ptr23 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc24 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr23
  %result25 = call i32 %fnc24(%f_i32_i32_struct* %putChar, i32 82)
  %ptr26 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc27 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr26
  %result28 = call i32 %fnc27(%f_i32_i32_struct* %putChar, i32 76)
  %ptr29 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc30 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr29
  %result31 = call i32 %fnc30(%f_i32_i32_struct* %putChar, i32 68)
  %ptr32 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc33 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr32
  %result34 = call i32 %fnc33(%f_i32_i32_struct* %putChar, i32 33)
  %ptr35 = getelementptr %f_i32_i32_struct, %f_i32_i32_struct* %putChar, i32 0, i32 0
  %fnc36 = load i32 (%f_i32_i32_struct*, i32)*, i32 (%f_i32_i32_struct*, i32)** %ptr35
  %result37 = call i32 %fnc36(%f_i32_i32_struct* %putChar, i32 10)
  ret i32 0
}
