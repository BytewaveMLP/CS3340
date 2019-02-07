# if (a <= b) c = b else c = a

.data
a:	.word	5
b:	.word	6
c:	.word	0

.text
main:
	lw	$s0, a
	lw	$s1, b
	lw	$s2, c
	
	blt	$s0, $s1, else
	sw	$s1, c
	j exit
else:
	sw	$s0, c
exit:
	li	$v0, 10
	syscall