# Eliot Partridge (EMP170002)
# CS3340.002 HW8

.include "./macros.asm"

.eqv FILENAME_MAX_SIZE 256

.data
filename:          .space FILENAME_MAX_SIZE
#filename:          .asciiz "../../../../../../../Users/DYY2QH2/Documents/CS3340/HW8/test_long.txt"
file_contents:     .space 1024
uncompressed_data: .space 1024

.text
main:
	alloc_heap (1024)
	move $s0, $v0
	
	_main_loop:
		get_str ("Filename to open (enter to exit): ", filename, FILENAME_MAX_SIZE)
		
		lb $t0, filename
		beq $t0, '\n', exit # if nothing was entered, the user wants to exit
		
		la $a0, filename
		jal strip_newline # strip \n from filename
		
		fopen (filename, 0)
		bltz $v0, error_exit # if there was an error opening the file, exit w/ fopen error
		move $s1, $v0 # s1 = open fd
		
		fread ($s1, file_contents, 1024) # read contents of file into buffer in memory
		move $s2, $v0 # s2 = file size
		
		fclose ($s1)
		
		print_str_imm ("Original contents:\n")
		print_str_lbl (file_contents)
		
		la $a0, file_contents
		move $a1, $s0
		move $a2, $s2
		jal compress
		move $s3, $v0 # save compressed data size
		
		print_str_imm ("\nCompressed contents:\n")
		move $a0, $s0
		move $a1, $s3
		jal print_compressed
		
		la $a0, uncompressed_data
		move $a1, $s0
		move $a2, $s3
		jal uncompress
		print_str_imm ("\nUncompressed contents:\n")
		print_str_lbl (uncompressed_data)
		
		print_str_imm ("\nUncompressed size: ")
		print_int ($s2)
		print_str_imm ("\nCompressed size: ")
		print_int ($s3)
		print_char_imm ('\n')
		j _main_loop

error_exit:
	print_str_imm ("Error opening file! Terminating...")
exit:
	li $v0, 10
	syscall

strip_newline:
	move $t0, $a0
	
	_strip_newline_loop:
		lb $t1, ($t0)
		beq $t1, '\n', _strip_here # if current char == \n, replace with \0 and exit loop
		add $t0, $t0, 1
		j _strip_newline_loop
	
	_strip_here:
		li $t1, 0
		sb $t1, ($t0)
		
	jr $ra

## Compresses a string using RLE compression
#  $a0 = address of input buffer
#  $a1 = address of output buffer
#  $a2 = original filesize
# return:
#  $v0 = size of compressed data
compress:
	add $t9, $a0, $a2
	li $v0, 0
_compress_next_char:
	bge $a0, $t9, _compress_ret
	lb $t0, ($a0) # t0 = current character
	li $t1, 0     # character count
	_compress_loop:
		addi $t1, $t1, 1
		addi $a0, $a0, 1
		lb $t2, ($a0)
		beq $t0, $t2, _compress_loop # if the next character is the same as the last, count it
		j _compress_store_count      # otherwise, write it and its count back to the output buffer
	
	_compress_store_count:
		sb $t0, ($a1) # write char
		addi $a1, $a1, 1
		sb $t1, ($a1) # write count
		addi $a1, $a1, 1
		addi $v0, $v0, 2
		j _compress_next_char
		
_compress_ret:
	jr $ra

## Prints a compressed buffer in human-readable form
#  $a0 = buffer address
#  $a1 = size of data in buffer
# return:
#  $v0 = size of compressed data
print_compressed:
	add $t9, $a0, $a1
	move $t8, $a0
	_print_compressed_loop:
		bge $t8, $t9, _print_compressed_ret
		
		lb $t0, ($t8) # read char
		addi $t8, $t8, 1
		lb $t1, ($t8) # read count
		addi $t8, $t8, 1
		
		print_char ($t0)
		print_int ($t1)
		
		j _print_compressed_loop
_print_compressed_ret:
	jr $ra

## Uncompresses an RLE-compressed buffer to a new buffer
#  $a0 = address of output buffer
#  $a1 = address of compressed data buffer
#  $a2 = size of compressed data in buffer
uncompress:
	add $t9, $a1, $a2
	_uncompress_loop:
		bge $a1, $t9, _uncompress_ret
		
		lb $t0, ($a1) # read char
		addi $a1, $a1, 1
		lb $t1, ($a1) # read count
		addi $a1, $a1, 1
		
		_uncompress_write_char_loop:
			subi $t1, $t1, 1 # decrement count
			sb $t0, ($a0) # write char back to output buffer
			addi $a0, $a0, 1
			bgtz $t1, _uncompress_write_char_loop # if the count is still >0, keep writing that char back
		
		j _uncompress_loop
_uncompress_ret:
	jr $ra