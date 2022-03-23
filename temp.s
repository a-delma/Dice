	.text
	.file	"MicroC"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$72, %edi
	callq	putchar@PLT
	movl	$69, %edi
	callq	putchar@PLT
	movl	$76, %edi
	callq	putchar@PLT
	movl	$76, %edi
	callq	putchar@PLT
	movl	$79, %edi
	callq	putchar@PLT
	movl	$32, %edi
	callq	putchar@PLT
	movl	$87, %edi
	callq	putchar@PLT
	movl	$79, %edi
	callq	putchar@PLT
	movl	$82, %edi
	callq	putchar@PLT
	movl	$76, %edi
	callq	putchar@PLT
	movl	$68, %edi
	callq	putchar@PLT
	movl	$33, %edi
	callq	putchar@PLT
	movl	$10, %edi
	callq	putchar@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	temp,@object            # @temp
	.bss
	.globl	temp
	.p2align	2
temp:
	.long	0                       # 0x0
	.size	temp, 4

	.type	hello,@object           # @hello
	.globl	hello
hello:
	.byte	0                       # 0x0
	.size	hello, 1

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
