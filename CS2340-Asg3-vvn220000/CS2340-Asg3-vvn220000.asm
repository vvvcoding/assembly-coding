# Program for Sieve of Eratosthenes
# This program finds all the prime numbers from 2 to n (user input) by
# storing bit positions 0 - n as 1's in memory, and then setting every
# composite number to 0; afterwards, only the prime bit positions will contain 1
# Written by Varun Natarajan, 10/2/2024

		.include	"SysCalls.asm"
		.data
userInput:	.word	0			# Store user input
promptForNum:	.asciiz	"Enter a number: "	# Prompt for user to enter num
errorPrompt:	.asciiz	"Error, number should be between 3 - 160,000.\n"	# Prompt if user enters invalid num
newlineChar:	.asciiz	"\n"			# Newline
primesPrompt:	.asciiz	"Prime Numbers: \n"	# Prime number prompt
		.text
		
#		Get user input for a number, if the number is
#		less than 3 or greater than 160,000, go to printErrorOne
#		and print the error message
getUserInput:	la	$a0, promptForNum	# Load address of promptForNum
		li	$v0, SysPrintString	# Load print function
		syscall				# Print the prompt
		li	$v0, SysReadInt		# Load read int function
		syscall				# Read the int
		move	$t1, $v0		# Move int at v0 to t1
		blt	$t1, 3, printError	# If t1<t2, go to printError
		bgt	$t1, 160000, printError	# If t1>t3, go to printError
		sw	$t1, userInput		# Store user input
		j	allocStart		# Jump to allocStart
		
#		Print the error message, then jump back to getUserInput
printError:	la	$a0, errorPrompt	# Load address of errorPrompt
		li	$v0, SysPrintString	# Load print function
		syscall				# Print the error
		j	getUserInput		# Jump back to getUserInput
		
#		Loads 0xFF (0b1111111) and n/8 into a registers
#		Allocates n/8 bytes of space to store every bit position
#		
allocStart:	li	$t2, 255		# Load 0xFF (0b11111111)
		li	$t5, 0			# Initialize counter to 0
		addi	$t3, $t1, 8		# Add t1 + 8 into t3 (round up)
		srl	$t3, $t3, 3		# Divide by 8
		move	$a0, $t3		# Load number of bytes to allocate
		li	$v0, SysAlloc		# Load allocation function
		syscall
		move	$t0, $v0		# Move pointer to memory to t0
		move 	$t9, $t0		# Store original pointer in t9
		
#		Loop that iterates through every byte
#		and stores 0xFF (0b11111111) in each byte
allocLoop:	sb	$t2, 0($t0)		# Store 0xFF into byte at t4
		addi	$t0, $t0, 1		# Move pointer to next byte
		addi	$t5, $t5, 1		# Increment counter
		blt	$t5, $t3, allocLoop	# If t5<t3, go to allocLoop
		
#		At this point, n/8 bytes have been stored and filled
#		and filled with 1's

#		KEY for the registers
#		$t0 and $t9 = point to the base address
#		$t1 = byte counter
#		$t2 = current divisor
#		$t4 = max divisor (n/2)
#		$t5 = bit position in the current byte
#		$s0 = overall bit position (0-n)
#		$s3 = n (user input)

#		Initialize registers to be used for finding composites
initRegisters:	move	$t0, $t9		# Reset pointer at t0 to t9
		lw	$s3, userInput		# Load userInput into s3
		srl	$t4, $s3, 1		# t4 = user input/2
		li	$t2, 2			# Current divisor
		li	$t1, 0			# Byte counter
		li	$t5, 0			# Index for bit position
		li	$s0, 0			# Overall bit position
		
#		Since all even numbers are composite, any multiple of 2
#		should be set to 0. handleTwo and twosLoop apply the bit
#		mask 0b01010101 to every byte other than the first, which
#		should be 0b11110101 since bit positions 0,1,2,3 are all 1's
		
#		Load bit mask for first byte 0xF5 (0b11110101) and apply to
#		first bit. If n (user input) < 8, go print the primes, else
#		apply the general bit mask 0x55 (0b01010101) to the following bytes
handleTwo:	li	$t7, 245		# Load bit mask for first byte
		lb	$t6, ($t0)		# Load byte at t0 into t6
		and	$t6, $t6, $t7		# t6 = t6 AND t7
		sb	$t6, ($t0)		# Store t6 in t0
		ble	$s3, 8, printPrimes	# If s3<8, go to printPrimes
		
#		Loops through bytes 1-n/8 and applies bit mask 0x55 (0b01010101)
		addi	$t1, $t1, 1		# Increment byte counter
		li	$t7, 85			# Load bit mask for all other byte
twosLoop:	addi	$t0, $t0, 1		# Move pointer to next byte
		lb	$t6, ($t0)		# Load byte at t0 into t6
		and	$t6, $t6, $t7		# t6 = t6 AND t7
		sb	$t6, ($t0)		# Store t6 in $t0
		addi	$t1, $t1, 1		# Increment byte counter
		blt	$t1, $t3, twosLoop	# If byteCnt<numBytes, go to twosLoop	

#		The following code has an outer loop that runs from current 
#		divisor (3) to max divisor (n/2), but current divisor increments
#		by 2 to skip over any even divisors (already handled by previous
#		code). The outer loop checks if the current bit has already been
#		set to 0, and if not, enter second loop that runs from current
#		bit position to n (user input). 	

#		Begin loop, if current divisor >= max divisor, go print primes
#		Else, find current byte position and current bit position in the byte
		addi	$t2, $t2, 1		# Increment divisor
		li	$s0, 3			# Load 3 into s0
		move	$t0, $t9		# Reset pointer to base address
findPosition:	bge	$t2, $t4, printPrimes	# If t4=t2, go to printPrimes
		srl	$t8, $s0, 3		# t8 = overallPosition / 8 = (byte position)
		sll	$t5, $t8, 3		# t5 = t8 * 8
		sub	$t5, $s0, $t5		# t5 = bit position
		
#		Load the current byte and check if current bit is 0 or 1
#		If current bit is 0, increment to next divisor, else if
#		current bit 1, go set every multiple of that bit to 0
checkCurBit:	lb	$t6, ($t0)		# Load byte at t0 into t6
		li	$t1, 7			# Load 7 into t1
		sub	$t1, $t1, $t5		# t1 = 7 - bit position
		srlv	$t6, $t6, $t1		# t6 shifted left by value of t1
		andi	$t6, $t6, 1		# t6 AND 1
		beq	$t6, 1,	setZeros	# If t6=1, go to setZeros
		addi	$t2, $t2, 2		# Increment divisor to next odd
		j	findPosition		# Jump to findPosition
		
#		Loops through all multiples of the current divisor and sets
#		the bit to 0. Exits when overall bit position = n (user input)
setZeros:	add	$s0, $s0, $t2		# Go to next multiple
		bgt	$s0, $s3, incrDivisor	# If s0=s3, go to incrDivisor
		srl	$t8, $s0, 3		# t8 = overallPosition / 8 = (byte position)
		sll	$t5, $t8, 3		# t5 = t8 * 8
		sub	$t5, $s0, $t5		# t5 = bit position
		li	$t1, 7			# Load 7 into t1
		sub	$t1, $t1, $t5		# t1 = t1-t5
		li	$s1, 1			# Load 1 into s1
		sllv	$s1, $s1, $t1		# Shift s1 by t1
		not	$s1, $s1		# Invert the bits
		move	$t0, $t9		# Reset t0 to base address
		add	$t0, $t0, $t8		# Byte pointer t0 = t8
		lb	$t6, ($t0)		# Load byte at position t0
		and	$t6, $t6, $s1		# Set bit to zero
		sb	$t6, ($t0)		# Store new byte
		j	setZeros		# Jump to setZeros
		
#		Move to next divisor by adding 2 (adding 2 skips even num divisors)
#		Sets overall bit position = current divisor because there is
#		no need to check anything prior to it
incrDivisor:	addi	$t2, $t2, 2		# Increment divisor to next odd
		addi	$s0, $t2, 0		# Set overall bit position = divisor
		move	$t0, $t9		# Reset t0 to base address
		j	findPosition		# Jump to findPosition
		
#		Loop through each byte and print any overall bit positions that
#		are 1's, and skip any that are 0's

#		Reset $t0 to base address, byte counter to 0, and overall bit
#		position to 0
printPrimes:	move 	$t0, $t9          	# Reset pointer to base address
    		li 	$t1, 0              	# Reset byte counter
    		lw 	$s3, userInput      	# Load userInput into s3
    		li 	$t2, 0              	# Reset overall bit position counter
		la	$a0, primesPrompt	# Load primesPrompt into a0
		li	$v0, SysPrintString	# Load print string function
		syscall				# Print primesPrompt

#		Loop from overall bit position to n (user input)
printLoop:    	bge 	$t2, $s3, endPrint 	# If overall bit position >= user input, end loop
    		lb 	$t6, 0($t0)         	# Load byte at current pointer
    		li 	$t3, 7             	# Start from the leftmost bit (bit index 7)

#		Loop through each bit in the current byte and check if the
#		current bit is 1 or 0. If the current bit is 1 
checkBits:	blt 	$t3, 0, nextByte    	# If bit index < 0, move to next byte
    		li 	$t7, 1                	# Load 1 into t7
    		sllv 	$t8, $t7, $t3       	# Shift 1 left by bit index
    		and 	$t9, $t6, $t8        	# Check if the bit is set
    		beqz 	$t9, skipPrint      	# If not set, skip printing

    		# Calculate the actual prime number position (0-based)
    		move 	$a0, $t2            	# Position is already in 0-based
    		blt 	$a0, 2, skipPrint    	# Skip if position < 2 (not a prime)

    		# Check if the position is within the n (user input) limit
    		ble 	$a0, $s3, printPosition # If position <= user input, print it
    		j 	skipPrint              	# Otherwise, skip printing

# 		Print the valid prime position (0-based)
printPosition:	li 	$v0, 1                	# Print integer syscall
    		syscall

# 		Print newline after each position
    		la 	$a0, newlineChar	# Load address of newline
    		li 	$v0, SysPrintString  	# Print string syscall
    		syscall

#		Move to the next bit then return to
skipPrint:	addi 	$t3, $t3, -1        	# Decrement bit index (check next left bit)
    		addi 	$t2, $t2, 1         	# Increment overall bit position
    		j 	checkBits              	# Check next bit

#		Move to the next byte and increment counter
nextByte:	addi 	$t1, $t1, 1         	# Increment byte counter
    		addi 	$t0, $t0, 1         	# Move to the next byte
    		j 	printLoop              	# Repeat for the next byte

endPrint:	li 	$v0, 10               	# Exit syscall
		syscall
