# Eliot Partridge (EMP170002)
# CS3340 HW2

# note: if the formatting looks weird, use tab size 4

.data
a:			.word	0
b:			.word	0
c:			.word	0
res1:		.word	0
res2:		.word	0
res3:		.word	0
name:		.space	20
pName:		.asciiz	"Enter your name: "
pInt:		.asciiz	"Enter an integer (1-100): "
sResult:	.asciiz	"Results: "
space:		.asciiz	" "

.text
main:
	li		$v0, 4
	la		$a0, pName
	syscall					# print name prompt
	li		$v0, 8
	la		$a0, name
	li		$a1, 20			# name is 20 bytes long
	syscall					# collect name from user
	li		$t0, 2			# setup loop counter (3 times)
	la		$t1, a			# stores address of next word to write to
loop:
	li		$v0, 4
	la		$a0, pInt
	syscall					# prompt for next int
	li		$v0, 5
	syscall					# collect int from user
	sw		$v0, ($t1)		# store at $t1 (first a, then b, then c)
	subi	$t0, $t0, 1		# decrement loop counter
	addi	$t1, $t1, 4		# move address where we're writing to up a word
	bgez	$t0, loop		# if $t0 >= 0, loop
	
	lw		$t0, a
	lw		$t1, b
	lw		$t2, c
	
	move	$t3, $t0		# res1 = a
	add		$t3, $t3, $t0	# res1 = res1 + a (res1 = 2a)
	sub		$t3, $t3, $t1	# res1 = res1 - b (res1 = 2a - b)
	addi	$t3, $t3, 9		# res1 = res1 + 9 (res1 = 2a - b + 9)
	sw		$t3, res1		# save to memory
	
	move	$t4, $t2		# res2 = c
	sub		$t4, $t4, $t1	# res2 = res2 - b (res2 = c - b)
	add		$t4, $t4, $t0	# res2 = res2 + a (res2 = c - b + a)
	subi	$t4, $t4, 5		# res2 = res2 - 5 (res2 = c - b + (a - 5))
	sw		$t4, res2		# save to memory
	
	move	$t5, $t0		# res3 = a
	subi	$t5, $t5, 3		# res3 = res3 - 3 (res3 = a - 3)
	add		$t5, $t5, $t1	# res3 = res3 + b (res3 = (a - 3) + b)
	addi	$t5, $t5, 4		# res3 = res3 + 4 (res3 = (a - 3) + (b + 4)
	sub		$t5, $t5, $t2	# res3 = res3 - c (res3 = (a - 3) + (b + 4) - (c))
	subi	$t5, $t5, 7		# res3 = res3 - 7 (res3 = (a - 3) + (b + 4) - (c + 7))
	sw		$t5, res3		# save to memory
	
	li		$v0, 4
	la		$a0, name
	syscall					# print the user's name
	la		$a0, sResult
	syscall					# print the RESULTS: prefix
	li		$v0, 1
	lw		$a0, res1
	syscall					# print res1
	li		$v0, 4
	la		$a0, space
	syscall					# add a space
	li		$v0, 1
	lw		$a0, res2
	syscall					# print res2
	li		$v0, 4
	la		$a0, space
	syscall
	li		$v0, 1
	lw		$a0, res3
	syscall					# print res3
	
exit:
	li		$v0, 10
	syscall					# clean exit, no status

# a		= 1
# b		= 2
# c		= 3
# res1	= 9
# res2	= -3
# res3	= -6

# a		= 2
# b		= 4
# c		= 6
# res1	= 9
# res2	= -1
# res3	= -6
