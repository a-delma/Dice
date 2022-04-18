; ModuleID = 'small test file'
source_filename = "small test file"

%coolfunction = type opaque

@coolfunctionstruct = external global %coolfunction*
@"hi there" = private unnamed_addr constant [15 x i8] c"Hello, world!\0A\00", align 1

define i32 @main(i32 %arg) {
entry:
  %loadinst = load %coolfunction*, %coolfunction** @coolfunctionstruct
  ret i32 0
}
