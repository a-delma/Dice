	.text
	.file	"DICE"
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
	movq	%rdi, %rbx
	callq	initialize@PLT
	movq	%rbx, 8(%rsp)
	movq	hmm@GOTPCREL(%rip), %rax
	movl	$86, (%rax)
	movb	$1, 4(%rax)
	movl	$89, 8(%rax)
	movq	putchar_@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	movl	$89, %esi
	callq	*(%rdi)
	xorl	%eax, %eax
	addq	$16, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	hmm,@object             # @hmm
	.bss
	.globl	hmm
	.p2align	3
hmm:
	.zero	12
	.size	hmm, 12

	.section	".note.GNU-stack","",@progbits
