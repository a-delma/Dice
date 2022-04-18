	.text
	.file	"small test file"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	xorl	%eax, %eax
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	".Lhi there",@object    # @"hi there"
	.section	.rodata.str1.1,"aMS",@progbits,1
".Lhi there":
	.asciz	"Hello, world!\n"
	.size	".Lhi there", 15

	.section	".note.GNU-stack","",@progbits
