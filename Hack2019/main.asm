# CS3340.002 Hack2019 Submission
# Eliot Partridge (EMP170002)

.include "macros.asm"

.data
# Lookup tables!
# Why implement the switch statement when you can just hardcode all possible values? :D
jan: .asciiz "Jan"
feb: .asciiz "Feb"
mar: .asciiz "Mar"
apr: .asciiz "Apr"
may: .asciiz "May"
jun: .asciiz "Jun"
jul: .asciiz "Jul"
aug: .asciiz "Aug"
sep: .asciiz "Sep"
oct: .asciiz "Oct"
nov: .asciiz "Nov"
dec: .asciiz "Dec"
month_lens: .word 31 28 31 30 31 30 31 31 30 31 30 31

.text
main:
	print_str ("Welcome to the months and days program.\n")
get_disp:
	print_str ("Press 1 for month number, 2 for month abbreviation: ")
	read_int ($s0) # $s0 = disp selection
	ble $s0, 0, input_disp_err
	bge $s0, 3, input_disp_err
get_month:
	print_str("Please enter the month 1 - 12, enter 0 to quit: ")
	read_int ($s1) # $s1 = month
	beqz $s1, exit
	ble $s1, -1, input_month_err
	bge $s1, 13, input_month_err
	subi $a0, $s1, 1
	jal get_month_days
	move $s2, $v0 # $s2 = month days
	print_str ("Number of days in month ")
	beq $s0, 2, month_name # if user selected month abbreviations, print those
	print_int ($s1)        # otherwise just print month number
print_month_days:
	print_str (" is ")
	print_int ($s2)
	print_str ("\n")
	j get_month
month_name: # print month abbreviation
	subi $t1, $s1, 1
	mul $t1, $t1, 4
	la $t0, jan # lookup table-based switch statement :D
	add $t0, $t0, $t1
	print_str_at ($t0)
	j print_month_days
exit:
	li $v0, 10
	syscall
input_month_err:
	print_str ("Month must be between 1 and 12\n")
	j get_month
input_disp_err:
	print_str ("Display selection must be 1 or 2\n")
	j get_disp

# Gets the number of days in a given month
# $a0 = month number to get (0-indexed)
# ret: $v0 = the number of days in the given month
get_month_days:
	move $t0, $a0
	mul $t0, $t0, 4
	la $t1, month_lens
	add $t1, $t1, $t0
	lw $v0, ($t1)
	jr $ra
