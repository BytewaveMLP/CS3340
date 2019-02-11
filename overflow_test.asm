.data
test:	.space	10
sign:	.byte	-1

.text
main:
	li		$v0, 8
	la		$a0, test
	la		$a1, 10
	syscall
	lb		$t0, sign
	tnei		$t0, -1
exit:
	li		$v0, 10
	syscall