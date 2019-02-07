# if (a < 0) a = -a
.data
a:	.word	-4

.text
main:
	lw	$s0, a
	slt	$t0, $s0, $zero
	beq	$t0, $zero, exit
	bge	$s0, 0, exit
	neg	$s0, $s0
	sw	$s0, a
exit:
	li	$v0, 10
	syscall
