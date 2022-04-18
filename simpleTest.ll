; ModuleID = 'DICE'
source_filename = "DICE"

%Function_ = type { void (...)*, %Node_* }
%Node_ = type { i8*, %Node_* }
%Test1 = type { i32, i1 }
%Test2 = type { i1, %Test1, %Test1 }

@putchar_ = external externally_initialized global %Function_
@hmm = global %Test1 zeroinitializer
@hmmmmmm = global %Test2 zeroinitializer
@hello = global i1 false

declare i8* @get_node(%Node_*, i32)

declare %Node_* @append_to_list(%Node_*, i8*)

declare %Node_* @get_null_list()

declare i8* @malloc_(i32)

declare void @initialize()

define i32 @main() {
entry:
  call void @initialize()
  store %Test1 { i1 true, i32 1 }, %Test1* @hmm
  %hmm = load %Test1, %Test1* @hmm
  %hmm1 = load %Test1, %Test1* @hmm
  store %Test2 { i1 true, %Test1 { i32 3, i1 false }, %Test1 %hmm1 }, %Test2* @hmmmmmm
  %hmmmmmm = load %Test2, %Test2* @hmmmmmm
  ret i32 0
}
