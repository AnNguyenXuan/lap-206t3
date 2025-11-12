	.file	"test.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "ok\0"
.LC1:
	.ascii "no\0"
	.text
	.globl	check
	.def	check;	.scl	2;	.type	32;	.endef
	.seh_proc	check
check:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$32, %rsp
	.seh_stackalloc	32
	.seh_endprologue
	movl	%ecx, 16(%rbp)
	cmpl	$1234, 16(%rbp)
	jne	.L2
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L3
.L2:
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	puts
.L3:
	nop
	addq	$32, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$32, %rsp
	.seh_stackalloc	32
	.seh_endprologue
	call	__main
	movl	$5678, %ecx
	call	check
	movl	$0, %eax
	addq	$32, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
	.def	puts;	.scl	2;	.type	32;	.endef
