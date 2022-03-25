	.text
	.file	"sasha.ll"
	.globl	putcharwithclosure      # -- Begin function putcharwithclosure
	.p2align	4, 0x90
	.type	putcharwithclosure,@function
putcharwithclosure:                     # @putcharwithclosure
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
	.size	putcharwithclosure, .Lfunc_end0-putcharwithclosure
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	putcharwithclosure@GOTPCREL(%rip), %rax
	movq	%rax, (%rsp)
	movq	%rsp, %rdi
	movl	$65, %esi
	callq	*%rax
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
