.text
	li	$v0, 33
	li	$a0, 50
	li	$a1, 500
	li	$a2, 1
	li	$a3, 40
loop:
	syscall
	add	$a0, $a0, 1
	ble $a0, 108, loop
exit:
	li	$v0, 10
	syscall
