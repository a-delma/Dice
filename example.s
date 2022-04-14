	.text
	.file	"example.ll"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$96, %edi
	callq	putchar@PLT
	callq	initialize@PLT
	movl	$8, %edi
	callq	malloc_@PLT
	movq	outer_lambda@GOTPCREL(%rip), %rcx
	movq	%rcx, (%rax)
	movq	%rax, %rdi
	movl	$68, %esi
	callq	*%rcx
	movq	%rax, %rdi
	callq	*(%rax)
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	outer_lambda            # -- Begin function outer_lambda
	.p2align	4, 0x90
	.type	outer_lambda,@function
outer_lambda:                           # @outer_lambda
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	.cfi_offset %rbp, -16
	movl	%esi, %r14d
	movl	$8, %edi
	callq	malloc_@PLT
	movq	%rax, %rbx
	movq	inner_lambda@GOTPCREL(%rip), %rax
	movq	%rax, (%rbx)
	callq	get_null_list@PLT
	movq	%rax, %rbp
	movl	$8, %edi
	callq	malloc_@PLT
	movl	%r14d, (%rax)
	movq	%rbp, %rdi
	movq	%rax, %rsi
	callq	append_to_list@PLT
	movq	%rax, 8(%rbx)
	movq	%rbx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	outer_lambda, .Lfunc_end1-outer_lambda
	.cfi_endproc
                                        # -- End function
	.globl	inner_lambda            # -- Begin function inner_lambda
	.p2align	4, 0x90
	.type	inner_lambda,@function
inner_lambda:                           # @inner_lambda
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	8(%rdi), %rdi
	xorl	%esi, %esi
	callq	get_node@PLT
	movl	(%rax), %esi
	movq	putchar_@GOTPCREL(%rip), %rdi
	callq	*(%rdi)
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	inner_lambda, .Lfunc_end2-inner_lambda
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
