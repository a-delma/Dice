	.text
	.file	"MicroC"
	.globl	putchar_with_closure    # -- Begin function putchar_with_closure
	.p2align	4, 0x90
	.type	putchar_with_closure,@function
putchar_with_closure:                   # @putchar_with_closure
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	%esi, %edi
	callq	putchar@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	putchar_with_closure, .Lfunc_end0-putchar_with_closure
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -16
	movq	putchar_with_closure@GOTPCREL(%rip), %rax
	movq	%rax, 8(%rsp)
	leaq	8(%rsp), %rbx
	movq	%rbx, %rdi
	movl	$72, %esi
	callq	*%rax
	movq	%rbx, %rdi
	movl	$69, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$76, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$76, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$79, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$32, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$87, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$79, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$82, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$76, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$68, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$33, %esi
	callq	*8(%rsp)
	movq	%rbx, %rdi
	movl	$10, %esi
	callq	*8(%rsp)
	xorl	%eax, %eax
	addq	$16, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.Lfmt,@object           # @fmt
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lfmt:
	.asciz	"%d\n"
	.size	.Lfmt, 4

	.type	.Lfmt.1,@object         # @fmt.1
.Lfmt.1:
	.asciz	"%g\n"
	.size	.Lfmt.1, 4

	.section	".note.GNU-stack","",@progbits
