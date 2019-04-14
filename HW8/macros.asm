.macro print_int (%reg)
	li $v0, 1
	move $a0, %reg
	syscall
.end_macro

.macro print_char (%reg)
	li $v0, 11
	move $a0, %reg
	syscall
.end_macro

.macro print_char_imm (%char)
	li $v0, 11
	li $a0, %char
	syscall
.end_macro

.macro print_str_reg (%regAddr)
	li $v0, 4
	move $a0, %regAddr
	syscall
.end_macro

.macro print_str_lbl (%label)
	li $v0, 4
	la $a0, %label
	syscall
.end_macro

.macro print_str_imm (%str)
	.data
	__print_str: .asciiz %str
	
	.text
	li $v0, 4
	la $a0, __print_str
	syscall
.end_macro

.macro get_str (%prompt, %buf, %maxLen)
	print_str_imm (%prompt)
	
	li $v0, 8
	la $a0, %buf
	li $a1, %maxLen
	syscall
.end_macro

.macro fopen (%filename, %flags)
	li $v0, 13
	la $a0, %filename
	li $a1, %flags
	li $a2, 0 # mode - ignored
	syscall
.end_macro

.macro fclose (%fd)
	li $v0, 16
	move $a0, %fd
	syscall
.end_macro

.macro fread (%fd, %buf, %max)
	li $v0, 14
	move $a0, %fd
	la $a1, %buf
	li $a2, %max
	syscall
.end_macro

.macro alloc_heap (%size)
	li $v0, 9
	li $a0, %size
	syscall
.end_macro
