; ModuleID = 'DICE'
source_filename = "DICE"

%Function_ = type { void (...)*, %Node_* }
%Node_ = type { i8*, %Node_* }

@putchar_ = external externally_initialized global %Function_*
@int_to_float_ = external externally_initialized global %Function_*
@a = global i32 0
@b = global double 0.000000e+00
@c = global double 0.000000e+00

declare i8* @get_node(%Node_*, i32)

declare %Node_* @append_to_list(%Node_*, i8*)

declare i8* @malloc_(i32)

declare void @initialize()

define i32 @main(%Function_* %self) {
entry:
  call void @initialize()
  %self1 = alloca %Function_*
  store %Function_* %self, %Function_** %self1
  store i32 74, i32* @a
  %a = load i32, i32* @a
  store double 2.330000e+01, double* @b
  %b = load double, double* @b
  %intToFloat = load %Function_*, %Function_** @int_to_float_
  %ptr = getelementptr inbounds %Function_, %Function_* %intToFloat, i32 0, i32 0
  %func_opq = load void (...)*, void (...)** %ptr
  %func = bitcast void (...)* %func_opq to double (%Function_*, i32)*
  %a2 = load i32, i32* @a
  %result = call double %func(%Function_* %intToFloat, i32 %a2)
  %b3 = load double, double* @b
  %tmp = fadd double %result, %b3
  store double %tmp, double* @c
  %c = load double, double* @c
  ret i32 0
}
