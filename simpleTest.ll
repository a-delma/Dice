; ModuleID = 'DICE'
source_filename = "DICE"

%Function_ = type { void (...)*, %Node_* }
%Node_ = type { i8*, %Node_* }
%Test1 = type { i32, %Test2 }
%Test2 = type { %Test2, %Test1 }

@putchar_ = external externally_initialized global %Function_
@hmm = global i1 false

declare void @test_func(%Test1)

declare i8* @get_node(%Node_*, i32)

declare %Node_* @append_to_list(%Node_*, i8*)

declare %Node_* @get_null_list()

declare i8* @malloc_(i32)

declare void @initialize()

define i32 @main() {
entry:
  call void @initialize()
  ret i32 0
}
