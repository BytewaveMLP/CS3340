# Eliot Partridge (EMP170002)
# CS3340.002 HW6

.include "macros.asm"

.eqv BUFFER_LENGTH 81

.data
file: .asciiz "C:\\Users\\Bytewave\\Downloads\\input.txt"
buf:  .space  BUFFER_LENGTH
.align 2
arr:      .space 80
arr_size: .word  0

.text
main:
	jal read_file_to_buf
	jal buf_to_int_arr
	
	print_str ("arr  (pre-sort) = ")
	jal print_arr
	
	jal sort_arr
	
	print_str ("\narr (post-sort) = ")
	jal print_arr
	print_char_imm ('\n')
	
	j exit
exit:
	li $v0, 10
	syscall

fopen_err:
	print_str ("Failed to open input file!")
	j exit

################################################

read_file_to_buf:
	li $v0, 13   # fopen
	la $a0, file # path
	li $a1, 0    # flag: 00 - read only
	syscall      # $a2 is ignored
	bltz $v0, fopen_err # if input file failed to open, we're done

	move $s0, $v0 # $s0 = open fd
	move $a0, $s0

	li $v0, 14
	la $a1, buf
	li $a2, BUFFER_LENGTH
	subi $a2, $a2, 1 # ensure there is always a \0 at the end by reading N-1 bytes
	syscall
	
	li $v0, 16
	syscall
	
	jr $ra

buf_to_int_arr:
	la $t0, buf
	la $t1, arr
	li $t9, 10
	li $t8, 0
	__btia_loop:
		lb   $t2, ($t0)
		beqz $t2, __btia_ret
		beq  $t2, '\n', __btia_reset
		blt  $t2, '0', __btia_skip
		bgt  $t2, '9', __btia_skip
		subi $t2, $t2, '0'
		mult $t3, $t9
		mflo $t3
		add  $t3, $t3, $t2
	__btia_skip:
		addi $t0, $t0, 1
		j __btia_loop
	__btia_reset:
		sw $t3, ($t1)
		addi $t1, $t1, 4
		addi $t8, $t8, 1
		li $t3, 0
		j __btia_skip
__btia_ret:
	sw $t8, arr_size
	jr $ra

print_arr:
	la $t0, arr
	lw $t1, arr_size
	__pa_loop:
		beqz $t1, __pa_ret
		li $v0, 1
		lw $a0, ($t0)
		syscall
		print_char_imm (' ')
		subi $t1, $t1, 1
		addi $t0, $t0, 4
		j __pa_loop
__pa_ret:
	jr $ra

sort_arr:
	la $t0, arr
	lw $t1, arr_size
	__sa_loop1:
		beq $t1, 0, __sa_ret
		addi $t2, $t0, 0
		subi $t5, $t1, 1
		move $t8, $t2
		li $t9, 2147483647
		__sa_loop2:
			beq $t5, 0, __sa_loop1_swap
			lw $t3, ($t2)
			bgt $t3, $t9, __sa_loop2_cont
			move $t8, $t2
			move $t9, $t3
		__sa_loop2_cont:
			addi $t2, $t2, 4
			subi $t5, $t5, 1
			j __sa_loop2
		## swap
	__sa_loop1_swap:
		lw $t6, ($t8)
		lw $t7, ($t0)
		sw $t7, ($t8)
		sw $t6, ($t0)
		addi $t0, $t0, 4
		subi $t1, $t1, 1
		j __sa_loop1
__sa_ret:
	jr $ra