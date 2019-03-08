.include "macros.asm"

.eqv MAX_NAME_LEN 51

.data
bmi:       .float 0.0
name:      .space MAX_NAME_LEN
norm_bmi:  .float 18.5
over_bmi:  .float 25.0
obese_bmi: .float 30.0

.text
main:
	print_str ("What is your name?: ")
	get_str (name, MAX_NAME_LEN)
	
	print_str ("What is your height in inches?: ")
	get_int ($t0)
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0 # convert input to float
	
	print_str ("Enter your weight in lbs (round to a whole number): ")
	get_int ($t1)
	mtc1 $t1, $f1
	cvt.s.w $f1, $f1
	
	# f0 = height, $f1 = weight, $f2 = 703.0, $f4 = final value
	
	li $t2, 703
	mtc1 $t2, $f2
	cvt.s.w $f2, $f2
	
	mul.s $f1, $f1, $f2
	mul.s $f0, $f0, $f0
	div.s $f4, $f1, $f0
	
	s.s $f4, bmi # store to memory
	
	print_str_lbl (name)
	print_str ("Your BMI is: ")
	print_float ($f4)
	print_str ("\n")
	
	l.s $f10, norm_bmi
	l.s $f11, over_bmi
	l.s $f12, obese_bmi
	
	c.lt.s $f4, $f10
	bc1t underweight # if bmi < norm_bmi, jmp underweight
	c.lt.s $f4, $f11
	bc1t normal      # if bmi < over_bmi, jmp normal
	c.lt.s $f4, $f12
	bc1t overweight  # if bmi < obese_bmi, jmp overweight
	print_str ("This is considered obese.\n") # leftover: must be obese
	j exit
underweight:
	print_str ("This is considered underweight.\n")
	j exit
normal:
	print_str ("This is considered normal.\n")
	j exit
overweight:
	print_str ("This is considered overweight.\n")
	j exit
	
exit:
	li $v0, 10
	syscall