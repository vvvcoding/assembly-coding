# Floating Point and Sorting Program
# This program takes input for up to 100 floating point numbers 
# and stores them into an "array". Then, the array is sorted using bubble sort.
# Finally, the count, sum, and average of the inputs is printed.
# Written by Varun Natarajan on 10/28/24
# NetID: vvn220000

		.include	"SysCalls.asm"
		.data
arraySpace:	.space	800				# "array" space
numPrompt:	.asciiz	"Enter a number: "		# Prompt to enter number
countPrompt:	.asciiz	"Count: "			# Prompt for count
sumPrompt:	.asciiz	"Sum: "				# Prompt for sum
averagePrompt:	.asciiz	"Average: "			# Prompt for average
listPrompt:	.asciiz	"Sorted list: \n"		# Prompt for sorted list
newLine:	.asciiz	"\n"				# Newline character
average:	.double	0.0				# Store average
storeSum:	.double 0.0				# Store sum
hundred: 	.double 100.0     			# 100.0 for scaling
half: 		.double 0.5           			# 0.5 for rounding
		.text
	
# Main:
# Function that contains the input loop
# Will call the bubbleSort and printResults functions
main:	
		la   	$t0, arraySpace			# Load address of arraySpace
		li	$t1, 0				# Initialize input count
		mtc1	$t1, $f4			# Set $f4 = 0
		cvt.d.w	$f4, $f4			# Convert $f4 to double
		li	$t5, 1				# Load 1 into $t5
		mtc1	$t5, $f6			# Set $f6 = 1
		cvt.d.w	$f6, $f6			# Convert $f5 to double
		andi $t0, $t0, 0xfffffff8		# Align the address with boundary

# Loop that takes input for up to 100 floating point numbers.
# If the number entered is not 0, store in memory, else, exit loop and begin sort	
mainLoop:	# Take input into $v0
		la	$a0, numPrompt			# Load input prompt address
		li	$v0, SysPrintString		# String print function
		syscall					# Print prompt
		li	$v0, SysReadDouble		# Load input function
		syscall					# Take input
		
		# If $v0 = 0, go to bubbleSort
		li	$t2, 0				# Load 0 into t1
		mtc1.d	$t2, $f2			# Set f2 = t1
		c.eq.d	$f0, $f2			# If input = 0, set condition = true
		bc1t	endLoop				# If true, go to endLoop
		
		# If count = 100, go to bubbleSort
		beq	$t1, 100, endLoop		# If $t1 = 100, endLoop
		
		# If $v0 != 0, store in memory, add to sum, repeat loop
		l.d	$f10, storeSum			# Load storeSum to f10
		add.d	$f10, $f10, $f0			# f10 = storeSum + new input
		s.d	$f10, storeSum			# Store f10 in storeSum
		s.d	$f0, 0($t0)			# Save input to memory
		addi	$t0, $t0, 8			# Increment array pointer
		addi	$t1, $t1, 1			# Increment integer input count
		add.d	$f4, $f4, $f6			# Increment double input count
		j	mainLoop			# Jump to mainLoop
		
# Branches here when the input loop receives a 0
# Will call the bubbleSort, printResults, and then exit
endLoop:	# Calculate and round the average
		li	$t7, 0				# Initialize t7 to 0
		l.d	$f10, storeSum			# Load sum into f10
		div.d	$f10, $f10, $f4			# f10 = sum / count
		ldc1    $f0, hundred			# Load 100.0 into $f1
    		mul.d   $f10, $f10, $f0			# f10 = average * 100.0
    		ldc1    $f2, half             		# Load 0.5 into $f2
    		add.d   $f10, $f10, $f2			# Add 0.5 for rounding
    		trunc.w.d $f10, $f10			# Truncate to integer
    		cvt.d.w $f10, $f10			# Convert back to double
    		ldc1    $f0, hundred			# Load 100.0 again into $f1
    		div.d   $f10, $f10, $f0			# Divide by 100.0 to get back to average
		s.d	$f10, average			# Store the average
		
		# Rounding the sum
		l.d	$f10, storeSum			# Load storeSum into f10
    		ldc1    $f0, hundred          		# Load 100.0 into $f0
    		mul.d   $f10, $f10, $f0       		# f10 = sum * 100.0
    		ldc1    $f2, half             		# Load 0.5 into $f2
    		add.d   $f10, $f10, $f2       		# Add 0.5 for rounding
    		trunc.w.d $f10, $f10          		# Truncate to integer
    		cvt.d.w $f10, $f10            		# Convert back to double
    		ldc1    $f0, hundred         		# Load 100.0 again into $f0
    		div.d   $f10, $f10, $f0       		# Divide by 100.0 to get back to sum
    		s.d     $f10, storeSum        		# Store rounded sum
		
		# Call the bubbleSort function and save return address
		ble	$t1, 1, skipSort		# If input count <= 1, skipSort
		jal	bubbleSort			# Jump to bubbleSort and save return address
		
		# Call the printResults function and save return address
skipSort:	jal	printResults			# Jump to printResults and save return address
		
		# End of program 
		j	exitFunction			# Jump to exitFunction

# Sorting Function:
# Has 2 loops
# First loop goes from 0 to n - 1 and stops if no two elements were
# swapped by the inner loop. Second loop goes from 0 to n - i - 1, if element
# j > element j + 1, swap.
bubbleSort:	# Initialize variables
		la	$t0, arraySpace			# Load base address into t0
		li	$t2, 0				# Initialize i = 0
		li	$t3, 0				# Initialize j = 0
		li	$t5, 0				# Initialize boolean hasSwapped = false
		li	$t6, 0				# Initialize inner loop exit condition
		li	$t7, 0				# Initialize outer loop exit condition
		subi	$t7, $t1, 1			# t7 = t1 (count) - 1

outerLoop:	li	$t5, 0				# Reset hasSwapped = false
		bge	$t2, $t7, endSort		# If t2>=t7, endSort
		
innerLoop:	addi	$t6, $t2, 1			# t6 = i + 1
		sub	$t6, $t1, $t6			# t6 = n (count) - t6
		bge	$t3, $t6, endInnerLoop		# If t3 >= t6, endInnerLoop
		ldc1	$f20, 0($t0)			# Load arr[j] into $f20
		ldc1	$f22, 8($t0)			# Load arr[j+1] into $f22
		c.lt.d	$f22, $f20			# If arr[j+1] < arr[j], set flag = true
		bc1f	skipSwap			# If flag = false, skipSwap, else swap
		mov.d	$f24, $f20			# temp = arr[j]
		s.d	$f22, 0($t0)			# arr[j] = arr[j+1]
		s.d	$f24, 8($t0)			# arr[j+1] = arr[j]
		li	$t5, 1				# hasSwapped = true
skipSwap:	addi	$t3, $t3, 1			# Increment j
		addi	$t0, $t0, 8			# Increment pointer
		j	innerLoop			# Jump to innerLoop
		
endInnerLoop:	beq	$t5, 0, endSort			# If hasSwapped = false, endSort
		addi	$t2, $t2, 1			# Increment i
		li	$t3, 0				# Reset j
		la	$t0, arraySpace			# Reset t0 to base address
		j	outerLoop			# Jump to outerLoop
		
endSort:	jr	$ra				# Return to main

# Printing Function:
printResults:	# Print sorted list
		la	$a0, listPrompt			# Load address of listPrompt
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print listPrompt
		li	$t0, 0				# Initialize t0 to 0
		la	$t9, arraySpace			# t9 = base address of list
printLoop:	ldc1	$f12, 0($t9)			# Load double into f12
		li	$v0, SysPrintDouble		# Load print double function
		syscall					# Print the double
		la	$a0, newLine			# Load newLine into a0
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print newLine
		addi	$t0, $t0, 1			# Increment temp count
		addi	$t9, $t9, 8			# Increment pointer
		blt	$t0, $t1, printLoop		# If t1 = t0, endPrintLoop

		# Print count
		la	$a0, countPrompt		# Load countPrompt
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print countPrompt
		move	$a0, $t1			# Load count
		li	$v0, SysPrintInt		# Load print int function
		syscall					# Print the count
		la	$a0, newLine			# Load newline
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print newline
		
		# Print sum
		la	$a0, sumPrompt			# Load sumPrompt
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print sumPrompt
		ldc1	$f12, storeSum			# Load sum into $f12
		li	$v0, SysPrintDouble		# Load print double function
		syscall					# Print sum
		la	$a0, newLine			# Load newline
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print newline
		
		# Print average
		la	$a0, averagePrompt		# Load averagePrompt
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print averagePrompt
		ldc1	$f12, average			# Load average into $f12
		li	$v0, SysPrintDouble		# Load print double function
		syscall					# Print average
		la	$a0, newLine			# Load newline
		li	$v0, SysPrintString		# Load print string function
		syscall					# Print newline
		
		# Jump back
		jr	$ra				# Return to main
		
# Exit
exitFunction:	li	$v0, SysExit			# Load exit function
		syscall					# Exit
