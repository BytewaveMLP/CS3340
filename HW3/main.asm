# Eliot Partridge (EMP170002)
# CS3340.002 HW3
# (tab size = 4)

# 1.  use the dialog syscall (#54) to input a string from the user
# 2.  call a function which counts the number of characters and number
#     of words in the string and returns these in $v0 and $v1; store
#     these in memory
# 3.  output (console) the string and counts to the user
# 4.  repeat from 1 until the user enters a blank string or hits “cancel”
# 5.  additionally, use $s1 somewhere in your function so that you must
#     save it on the stack at the top of your function and restore it
#     before the function exits.
# 6.  output a dialog message (syscall #59) to say goodbye before the
#     program ends

## Maximum characters to read from the prompt
## (+1b for the terminating \0)
.eqv	MAX_STRING_LEN	241

## Helper macro to push a register onto the stack
.macro pushreg(%register)
addi	$sp, $sp, -4
sw		%register, ($sp)
.end_macro
## Helper macro to pop a register off of the stack
.macro popreg(%register)
lw		%register, ($sp)
addi	$sp, $sp, 4
.end_macro

.data
prompt:	.asciiz	"Enter a string (max 240 characters)"
words:	.asciiz	" words, "
chars:	.asciiz	" characters\n"
string:	.space	MAX_STRING_LEN

.text
main:
	li		$v0, 54
	la		$a0, prompt	# prompt to display
	la		$a1, string	# where to write the input
	li		$a2, MAX_STRING_LEN
	syscall				# prompt for input string
	neg		$a1, $a1 	# positive return codes
	andi	$a1, 0xb 	# unset bit 2 (-4 = 0, going over char limit is not an error)
	bnez	$a1, exit	# if non-zero status code (cancel or user entered nothing), exit
	li		$v0, 4
	la		$a0, string
	syscall				# echo string back
	li		$s1, -1337	# load signaling value into $s1
	jal		word_char_count
	tnei	$s1, -1337	# error out if $s0 gets clobbered (checks saving routine)
	move	$a0, $v0
	move	$t0, $v1
	li		$v0, 1
	syscall				# print word count
	li		$v0, 4
	la		$a0, words
	syscall				# "%d words, "
	li		$v0, 1
	move	$a0, $t0
	syscall				# print char count
	li		$v0, 4
	la		$a0, chars
	syscall				# "%d characters"
	j		main
exit:
	li		$v0, 10
	syscall

## Counts the number of words and characters in a string
## Args: $a0 = the address of the input string
## Retn: $v0 = the number of words in the string
##       $v1 = the number of characters in the string
word_char_count:
	pushreg($s1)
	move	$s1, $a0
	li		$v0, 1	# if there is a string there must be at least one word, generally
	li		$v1, 0	# string should contain no characters by default
wcc_loop:
	lb		$t0, ($s1)
	andi	$t1, $t0, 0xf5	# $t1 = 0 if $t0 = 0xa (\n) or 0x00 (\0)
	beqz	$t1, wcc_ret
	seq		$t1, $t0, ' '
	add		$v0, $v0, $t1	# if current char ($t0) was a space, add 1 to $v0, else add 0 (nop)
	addi	$v1, $v1, 1		# count character
	addi	$s1, $s1, 1		# move pointer forward
	j		wcc_loop
wcc_ret:
	popreg($s1)
	jr		$ra