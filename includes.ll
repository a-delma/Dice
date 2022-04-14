; ModuleID = 'includes.c'
source_filename = "includes.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Function_ = type { void (...)*, %struct.Node_* }
%struct.Node_ = type opaque

@putchar_ = common global %struct.Function_* null, align 8

; Function Attrs: noinline nounwind optnone
define i32 @putchar_helper(%struct.Function_* %closure, i32 %c) #0 {
entry:
  %closure.addr = alloca %struct.Function_*, align 8
  %c.addr = alloca i32, align 4
  store %struct.Function_* %closure, %struct.Function_** %closure.addr, align 8
  store i32 %c, i32* %c.addr, align 4
  ret i32 0
}

; Function Attrs: noinline nounwind optnone
define i32 @initialize() #0 {
entry:
  %0 = load %struct.Function_*, %struct.Function_** @putchar_, align 8
  %closure = getelementptr inbounds %struct.Function_, %struct.Function_* %0, i32 0, i32 1
  store %struct.Node_* null, %struct.Node_** %closure, align 8
  %1 = load %struct.Function_*, %struct.Function_** @putchar_, align 8
  %ptr = getelementptr inbounds %struct.Function_, %struct.Function_* %1, i32 0, i32 0
  store void (...)* bitcast (i32 (%struct.Function_*, i32)* @putchar_helper to void (...)*), void (...)** %ptr, align 8
  ret i32 0
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="+cx8,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
