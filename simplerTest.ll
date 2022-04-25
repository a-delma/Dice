; ModuleID = 'DICE'
source_filename = "DICE"

%Function_ = type { void (...)*, %Node_* }
%Node_ = type { i8*, %Node_* }
%Test1 = type { i32, i1, i32 }

@putchar_ = external externally_initialized global %Function_*
@hmm = global %Test1 zeroinitializer

declare i8* @get_node(%Node_*, i32)

declare %Node_* @append_to_list(%Node_*, i8*)

declare i8* @malloc_(i32)

declare void @initialize()

define i32 @main(%Function_* %self) {
entry:
  call void @initialize()
  %self1 = alloca %Function_*
  store %Function_* %self, %Function_** %self1
  store %Test1 { i32 86, i1 true, i32 89 }, %Test1* @hmm
  %hmm = load %Test1, %Test1* @hmm
  %hmm2 = load %Test1, %Test1* @hmm
  %mut_struct = insertvalue %Test1 %hmm2, i32 90, 2
  ret i32 0
}
