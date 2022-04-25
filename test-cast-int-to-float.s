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
	movq	a@GOTPCREL(%rip), %rax
	movl	$74, (%rax)
	movq	b@GOTPCREL(%rip), %rbx
	movabsq	$4627251584639487181, %rax # imm = 0x40374CCCCCCCCCCD
	movq	%rax, (%rbx)
	movq	int_to_float_@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	movl	$74, %esi
	callq	*(%rdi)
	addsd	(%rbx), %xmm0
	movq	c@GOTPCREL(%rip), %rax
	movsd	%xmm0, (%rax)
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
	.type	a,@object               # @a
	.bss
	.globl	a
	.p2align	2
a:
	.long	0                       # 0x0
	.size	a, 4

	.type	b,@object               # @b
	.globl	b
	.p2align	3
b:
	.quad	0                       # double 0
	.size	b, 8

	.type	c,@object               # @c
	.globl	c
	.p2align	3
c:
	.quad	0                       # double 0
	.size	c, 8

	.section	".note.GNU-stack","",@progbits
