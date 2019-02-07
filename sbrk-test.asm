.text
main:
	li	$v0, 5
	syscall				# read int

	move	$a0, $v0
	move	$t0, $a0
	li	$v0, 9
	syscall				# allocate (sbrk) heap memory of requested size
	
	move	$a0, $v0
	move	$a1, $t0
	li	$v0, 8
	syscall				# read string into heap memory address
	
	li	$v0, 4
	syscall				# print read string to prove it worked
	
exit:
	li	$v0, 10
	syscall
