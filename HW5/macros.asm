.macro print_str (%str)
	.data
	m__print_str: .asciiz %str
	.text
	li $v0, 4
	la $a0, m__print_str
	syscall
.end_macro

.macro print_str_lbl (%lbl)
	li $v0, 4
	la $a0, %lbl
	syscall
.end_macro

.macro print_float (%f)
	li $v0, 2
	mov.s $f12, %f
	syscall
.end_macro

.macro get_int (%reg)
	li $v0, 5
	syscall
	move %reg, $v0
.end_macro

.macro get_str (%buf, %len)
	li $v0, 8
	la $a0, %buf
	li $a1, %len
	syscall
.end_macro