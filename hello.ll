; ModuleID = 'MicroC'
source_filename = "MicroC"

%map_int_to_void_struct = type { i32 (%map_int_to_void_struct*, i32)* }

@fmt = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@fmt.1 = private unnamed_addr constant [4 x i8] c"%g\0A\00", align 1

declare i32 @putchar(i32)

define i32 @putchar_with_closure(%map_int_to_void_struct* %0, i32 %1) {
entry:
  %"we need to put something here" = call i32 @putchar(i32 %1)
  ret i32 0
}

define i32 @main() {
entry:
  %putChar = alloca %map_int_to_void_struct
  %ptr = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  store i32 (%map_int_to_void_struct*, i32)* @putchar_with_closure, i32 (%map_int_to_void_struct*, i32)** %ptr
  %ptr1 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr1
  %result = call i32 %fnc(%map_int_to_void_struct* %putChar, i32 72)
  %ptr2 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc3 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr2
  %result4 = call i32 %fnc3(%map_int_to_void_struct* %putChar, i32 69)
  %ptr5 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc6 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr5
  %result7 = call i32 %fnc6(%map_int_to_void_struct* %putChar, i32 76)
  %ptr8 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc9 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr8
  %result10 = call i32 %fnc9(%map_int_to_void_struct* %putChar, i32 76)
  %ptr11 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc12 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr11
  %result13 = call i32 %fnc12(%map_int_to_void_struct* %putChar, i32 79)
  %ptr14 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc15 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr14
  %result16 = call i32 %fnc15(%map_int_to_void_struct* %putChar, i32 32)
  %ptr17 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc18 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr17
  %result19 = call i32 %fnc18(%map_int_to_void_struct* %putChar, i32 87)
  %ptr20 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc21 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr20
  %result22 = call i32 %fnc21(%map_int_to_void_struct* %putChar, i32 79)
  %ptr23 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc24 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr23
  %result25 = call i32 %fnc24(%map_int_to_void_struct* %putChar, i32 82)
  %ptr26 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc27 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr26
  %result28 = call i32 %fnc27(%map_int_to_void_struct* %putChar, i32 76)
  %ptr29 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc30 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr29
  %result31 = call i32 %fnc30(%map_int_to_void_struct* %putChar, i32 68)
  %ptr32 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc33 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr32
  %result34 = call i32 %fnc33(%map_int_to_void_struct* %putChar, i32 33)
  %ptr35 = getelementptr %map_int_to_void_struct, %map_int_to_void_struct* %putChar, i32 0, i32 0
  %fnc36 = load i32 (%map_int_to_void_struct*, i32)*, i32 (%map_int_to_void_struct*, i32)** %ptr35
  %result37 = call i32 %fnc36(%map_int_to_void_struct* %putChar, i32 10)
  ret i32 0
}
