.macro print_str (%s)
	.data
		__m__print_str: .asciiz %s
	.text
		li $v0, 4
		la $a0, __m__print_str
		syscall
.end_macro

.macro print_str_mem (%lbl)
	li $v0, 4
	la $a0, %lbl
	syscall
.end_macro

.macro print_str_at (%reg)
	li $v0, 4
	move $a0, %reg
	syscall
.end_macro

.macro read_int (%reg)
	li $v0, 5
	syscall
	move %reg, $v0
.end_macro

.macro print_int (%reg)
	li $v0, 1
	move $a0, %reg
	syscall
.end_macro