.data
notes:	.byte	61  61  65  61  66  66  70  68  255 68  68  68  65  68  63  65  61  61  61  65  61  66  66  70  68  255 68  68  68  65  68  68  255 68  68  68  65  68  61  0
.align 2
times:	.word	388 259 259 259 388 259 259 259 259 259 130 130 259 259 259 259 259 388 259 259 259 388 259 259 259 259 130 130 259 259 259 259 259 130 130 259 259 259 518 0

.text
main:
	li $v0, 33
	la $t0, notes
	la $t1, times
	lbu $a0, ($t0)
	lw $a1, ($t1)
	li $a2, 1
	li $a3, 50
	loop:
		beq $a0, 255, rest
		syscall
		resume:
		addi $t0, $t0, 1
		addi $t1, $t1, 4
		lbu $a0, ($t0)
		lw $a1, ($t1)
		bnez $a0, loop
		j exit
		rest:
		li $v0, 32
		syscall
		li $v0, 33
		j resume
		
exit:
	li $v0, 10
	syscall
