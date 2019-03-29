.macro print_str (%str)
	.data
	m__print_str: .asciiz %str
	.text
	li $v0, 4
	la $a0, m__print_str
	syscall
.end_macro

.macro print_int (%reg)
	li $v0, 4
	move $a0, %reg
	syscall
.end_macro

.macro print_char_imm (%ch)
	li $v0, 11
	li $a0, %ch
	syscall
.end_macro

.macro print_float (%f)
	li $v0, 2
	mov.s $f12, %f
	syscall
.end_macro
