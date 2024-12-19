# 
		.include	"SysCalls.asm"
		.data	
buffer:		.space	50			# Space for storing string
accumulator:	.word	0			# Accumulator used for binary
errorCount:	.word	0			# Number of user input errors
validInputs:	.word	0			# Number of valid inputs
total:		.word	0			# Total sum of all valid inputs
newlineChar:	.asciiz	"\n"			# Variable for newline character
prompt:		.asciiz	"Enter a number: "	# Prompt for user input
errorPrompt:	.asciiz	"Error: "		# Prompt for error
sumPrompt:	.asciiz	"Sum="			# Final sum prompt
validPrompt:	.asciiz	"Count of valid numbers = "
printErrors:	.asciiz	"Total number of errors: "
		.text
		
		li	$t4, 0			# Initialize t4, holds the total
		
#		Main loop, prompts user for a string,
#		then checks the first character for a newline.
#		If newline exists, end the loop
loopStart:	li	$t3, 0			# Initialize t3, will hold accumulator
		li	$t5, 0			# Initialize t5, will hold 0 or 1
		la	$a0, prompt		# Load address of propmt
		li	$v0, SysPrintString	# Load print function
		syscall
		li	$v0, SysReadString	# Load read string function
		la	$a0, buffer		# Load address of buffer
		li	$a1, 100		# Max size of buffer
		syscall				# Read string into buffer
		# Check if there is newline character at the beginning of string
		lb	$t0, buffer		# Load character from buffer
		la	$t1, 10			# Load newlineChar
		beq	$t0, $t1, loopEnd	# If t0=t1="\n", end loop
		# Check if there is minus sign at the beginning of string
		li	$t1, '-'			# Load negative sign into t1
		beq	$t0, $t1, negativeCheck	# If t0=t1="-", go to negativeCheck
		j	errorLoop		# Else, jump to errorLoop

#		Enter this if there is a negative sign at
#		the beginning of buffer
negativeCheck:	la	$a0, buffer		# Load address of buffer
		addi	$a0, $a0, 1		# Move the pointer over by 1
		addi	$t5, $t5, 1		# Save minus sign
		lb	$t7, 0($a0)		# Load byte of current character
		beq	$t7, 10, errorFlag	# If t7=t1='\n', go to errorFlag

#		Check for any errors in the user input string.
#		If there are errors, go to errorFlag 
errorLoop:	lb	$t0, 0($a0)		# Load byte of current character
		li	$t1, 45			# Load '-' into t1
		beq	$t0, $t1, errorFlag	# If t0=t1='-', go to errorFlag
		la	$t1, 10			# Load newlineChar
		beq	$t0, $t1, errorLoopEnd	# If t0=t1="\n", go to errorLoopEnd
		li	$t1, 57			# Load ascii 9
		bgt	$t0, $t1, errorFlag	# If t0>t1, go to errorFlag
		li	$t1, 48			# Load ascii 0
		blt	$t0, $t1, errorFlag	# If t0<t1, go to errorFlag
		sub	$t0, $t0, $t1		# Convert ascii to binary
		mul	$t3, $t3, 10      	# Multiply accumulator by 10
    		add	$t3, $t3, $t0     	# Add digit to accumulator
    		addi	$a0, $a0, 1		# Move to the next digit
    		j	errorLoop		# Repeat the loop
		
#		Only enter this if an error is found, then increase errorCount,
#		then print the error
errorFlag:	lw	$t0, errorCount		# Load errorCount
		addi	$t0, $t0, 1		# Add 1 to errorCount
		sw	$t0, errorCount		# Store new count into errorCount
		la	$a0, errorPrompt	# Load address of errorPrompt
		li	$v0, SysPrintString	# Load print function
		syscall
		la	$a0, buffer		# Load address of buffer
		li	$v0, SysPrintString	# Load print function
		syscall
		j	loopStart		# Get user input again

#		Enter here when you have an input that has been validated
#		Increase validInputs, then handle the addition/subtraction
#		of the input
errorLoopEnd:	lw	$t0, validInputs	# Load validInputs
		addi	$t0, $t0, 1		# Add 1 to validInputs
		sw	$t0, validInputs	# Store new count into validInputs
		beq	$t5, 1, isNegative	# If t5=0, go to isNegative
		add	$t4, $t4, $t3		# t4 = accumulator + current number
#		After the input has been added/subtracted, save the new total
saveTotal:	sw	$t4, total		# Store new value into total
		j	loopStart
		
#		Subtract the negative number, then jump back to saveTotal
isNegative:	sub	$t4, $t4, $t3		# t4 = accumulator - current number
		j	saveTotal		# Jump to saveTotal

#		End of loop, loopStart branches here if a newline
#		character is found. Print the summation, number of valid
#		inputs, and the number of invalid inputs
loopEnd:	la	$a0, sumPrompt		# Load address of sumPrompt
		li	$v0, SysPrintString	# Load print function
		syscall
		lw	$a0, total		# Load address of total
		li	$v0, SysPrintInt	# Load print int function
		syscall
		la	$a0, newlineChar	# Load address of newlineChar
		li	$v0, SysPrintString	# Load print function
		syscall
#		Print number of valid inputs
		la	$a0, validPrompt	# Load address of validPrompt
		li	$v0, SysPrintString	# Load print function
		syscall
		lw	$a0, validInputs	# Load address of validInputs
		li	$v0, SysPrintInt	# Load print int function
		syscall
		la	$a0, newlineChar	# Load address of newlineChar
		li	$v0, SysPrintString	# Load print function
		syscall
#		Print number of user input errors
		la	$a0, printErrors	# Load address of printErrors
		li	$v0, SysPrintString	# Load print function
		syscall
		lw	$a0, errorCount		# Load address of errorCount
		li	$v0, SysPrintInt	# Load print int function
		syscall
		la	$a0, newlineChar	# Load address of newlineChar
		li	$v0, SysPrintString	# Load print function
		syscall
		li	$v0, SysExit		# Load exit function
		syscall				# Exit
