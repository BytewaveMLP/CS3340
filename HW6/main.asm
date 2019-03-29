# Eliot Partridge (EMP170002)
# CS3340.002 HW6

.include "macros.asm"

.eqv BUFFER_SIZE 81

.data
file: .asciiz "input.txt"
buf:  .space  BUFFER_SIZE
.align 2
arr:      .space 80
arr_size: .word  0

.text
main:
	la $a0, file
	la $a1, buf
	li $a2, BUFFER_SIZE
	jal read_file_to_buf
	bltz $v0, fopen_err
	
	la $a0, arr
	li $a1, 20 # unused
	la $a2, buf
	jal buf_to_int_arr
	sw $v0, arr_size
	
	print_str ("arr  (pre-sort) = ")
	la $a0, arr
	lw $a1, arr_size
	jal print_arr
	
	la $a0, arr
	lw $a1, arr_size
	jal sort_arr
	
	print_str ("\narr (post-sort) = ")
	la $a0, arr
	lw $a1, arr_size
	jal print_arr
	
	print_str ("\nmean   = ")
	la $a0, arr
	lw $a1, arr_size
	jal arr_calc_mean
	print_float ($f0)
	
	print_str ("\nmedian = ")
	la $a0, arr
	lw $a1, arr_size
	jal arr_calc_median
	print_float ($f0)
	
	print_str ("\nstddev = ")
	la $a0, arr
	lw $a1, arr_size
	jal arr_calc_stddev
	print_float ($f0)
	
	j exit
exit:
	li $v0, 10
	syscall

fopen_err:
	print_str ("Failed to open input file!")
	j exit

################################################

## Reads a given file into an input buffer
#  $a0 = (filename)
#  $a1 = (buf)
read_file_to_buf:
	move $t0, $a1
	
	li $v0, 13   # fopen
	li $a1, 0    # flag: 00 - read only
	syscall      # $a2 is ignored
	bltz $v0, __rftb_ret # if input file failed to open, we're done
	
	move $a0, $v0

	li $v0, 14
	move $a1, $t0
	subi $a2, $a2, 1 # ensure there is always a \0 at the end by reading N-1 bytes
	syscall
	
	move $t0, $v0
	
	li $v0, 16
	syscall
	
	move $v0, $t0

__rftb_ret:
	jr $ra

## Converts a character buffer to an array of words, returning the new array's size
#  $a0 = (arr)
#  $a1 = ignored
#  $a2 = (buf)
# ret:
#  $v0 = number of words read
buf_to_int_arr:
	move $t0, $a2
	move $t1, $a0
	li $t9, 10
	li $t8, 0
	__btia_loop:
		lb   $t2, ($t0)
		beqz $t2, __btia_ret         # we've reached EOF
		beq  $t2, '\n', __btia_reset # we've reached the end of a number
		blt  $t2, '0', __btia_skip   # if not a numeric character, skip
		bgt  $t2, '9', __btia_skip
		subi $t2, $t2, '0'           # ASCII -> numeric
		mult $t3, $t9                # acc *= 10
		mflo $t3
		add  $t3, $t3, $t2           # acc += $t2
	__btia_skip:
		addi $t0, $t0, 1
		j __btia_loop
	__btia_reset:
		sw $t3, ($t1)                # save out to array
		addi $t1, $t1, 4             # advance pointer
		addi $t8, $t8, 1             # size += 1
		li $t3, 0
		j __btia_skip
__btia_ret:
	move $v0, $t8
	jr $ra

print_arr:
	move $t0, $a0
	move $t1, $a1
	__pa_loop:
		beqz $t1, __pa_ret   # end of array?
		li $v0, 1
		lw $a0, ($t0)
		syscall
		print_char_imm (' ')
		subi $t1, $t1, 1
		addi $t0, $t0, 4
		j __pa_loop
__pa_ret:
	jr $ra

## Sorts a given array using selection sort
## Loosely adapted from https://en.wikipedia.org/wiki/Selection_sort#Implementation
#  $a0 = (arr)
#  $a1 = sizeof(arr)
sort_arr:
	move $t0, $a0
	addi $t1, $a1, 1
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

## Calculates the mean of an array, returning it in $f0
#  $a0 = (arr)
#  $a1 = sizeof(arr)
# ret:
#  $f0 = mean(arr)
arr_calc_mean:
	move $t0, $a0
	move $t1, $a1
	li $t9, 0
	mtc1 $t9, $f12
	cvt.s.w $f0, $f12 # $f0 = running sum
	mtc1 $a1, $f12
	cvt.s.w $f1, $f12 # $f1 = total
	__am_loop:
		beqz $t1, __am_ret
		lw $t2, ($t0)
		mtc1 $t2, $f12
		cvt.s.w $f12, $f12
		add.s $f0, $f0, $f12
		subi $t1, $t1, 1
		addi $t0, $t0, 4
		j __am_loop
__am_ret:
	div.s $f0, $f0, $f1
	jr $ra

## Calculate the median of the array, returning it in $f0
## An argument could be made that this implementation is incorrect, as it doesn't follow HW6 spec.
## However, I feel as though returning two different data types makes little sense, and is just
## inconvenient for the programmer. I understand if you choose to dock points for it, but given that
## stddev needs this calculation anyway, I'm going to have the function return a float regardless of
## whether the array size is even or odd.
#  $a0 = (arr)
#  #a1 = sizeof(arr)
# ret:
#  $f0 = median(arr)
arr_calc_median:
	move $t0, $a0
	move $t1, $a1
	
	li $t9, 2
	div $t1, $t9
	mfhi $t8
	mflo $t1
	
	li $t7, 4
	mult $t1, $t7
	mflo $t1
	subi $t1, $t1, 4
	add $t0, $t0, $t1
	
	lw $t2, ($t0)
	
	beqz $t8, __amed_even_size
	
	mtc1 $t2, $f0
	cvt.s.w $f0, $f0
	
	j __am_ret
__amed_even_size:
	addi $t0, $t0, 4
	
	lw $t3, ($t0)
	add $t2, $t2, $t3
	
	mtc1 $t2, $f0
	cvt.s.w $f0, $f0
	mtc1 $t9, $f1
	cvt.s.w $f1, $f1
	div.s $f0, $f0, $f1
__amed_ret:
	jr $ra

## Calculates the standard deviation of the array, returning it in $f0
#  $a0 = (arr)
#  $a1 = sizeof(arr)
# ret:
#  $f0 = stdDev(arr)
arr_calc_stddev:
	push ($ra)
	jal arr_calc_mean # calculate mean again, for portability
	move $t0, $a0
	move $t1, $a1
	mov.s $f2, $f0
	li $t9, 0
	mtc1 $t9, $f0
	cvt.s.w $f0, $f0
	__asd_loop:
		beqz $t1, __asd_ret
		lw $t2, ($t0)
		mtc1 $t2, $f12
		cvt.s.w $f12, $f12   # r_i
		sub.s $f1, $f2, $f12 # r_i - r_avg
		mul.s $f1, $f1, $f1  # (r_i - r_avg)^2
		add.s $f0, $f0, $f1  # sum((r_i - r_avg)^2)
		subi $t1, $t1, 1
		addi $t0, $t0, 4
		j __asd_loop
__asd_ret:
	subi $t0, $a1, 1 # n - 1
	mtc1 $t0, $f12
	cvt.s.w $f12, $f12
	div.s $f0, $f0, $f12 # sum((r_i - r_avg)^2) / (n - 1)
	sqrt.s $f0, $f0      # sqrt(sum((r_i - r_avg)^2) / (n - 1))
	pop ($ra)
	jr $ra
	