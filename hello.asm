.data
hello:	.asciiz	"Hello, world!"

.text
main:
	li	$v0, 4		# load value 4 into register $v0
	la	$a0, hello	# load address of label "hello" into register $a0
	syscall			# call kernel
					# $v0 = 4, PrintString, $a0 is address of string to print

	li	$v0, 10		# load value 10 into register $v0
	syscall			# call kernel
					# $v0 = 10, Exit without status