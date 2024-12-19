# 
		.include	"SysCalls.asm"
		.data
bitPosition:	.asciiz	"Bit Position: "
newlineChar:	.asciiz	"\n"
posByte:	.asciiz "Position in Byte: "
divisor:	.asciiz "Divisor: "
userInput:	.word	0			# Store user input
promptForNum:	.asciiz	"Enter a number: "	# Prompt for user to enter num
errorPrompt:	.asciiz	"Error, number should be between 3 - 160,000.\n"	# Prompt if user enters invalid num
		.text
		
#		Get user input for a number, if the number is
#		less than 3 or greater than 160,000, go to printErrorOne
getUserInput:	la	$a0, promptForNum	# Load address of promptForNum
		li	$v0, SysPrintString	# Load print function
		syscall				# Print the prompt
		li	$v0, SysReadInt		# Load read int function
		syscall				# Read the int
		move	$t1, $v0		# Move int at v0 to t1
		blt	$t1, 3, printErrorOne	# If t1<t2, go to printErrorOne
		bgt	$t1, 160000, printErrorOne	# If t1>t3, go to printErrorOne
		sw	$t1, userInput		# Store user input
		j	allocStart		# Jump to allocStart
		
#		Print the error, then jump back to getUserInput
printErrorOne:	la	$a0, errorPrompt	# Load address of errorPrompt
		li	$v0, SysPrintString	# Load print function
		syscall				# Print the error
		j	getUserInput		# Jump back to getUserInput
		
#
allocStart:	li	$t2, 255		# Load 0xFF
		li	$t5, 0			# Initialize counter to 0
		addi	$t3, $t1, 7		# Add t1 + 7 into t3 (round up)
		srl	$t3, $t3, 3		# Divide by 8
		move	$a0, $t3		# Load number of bytes to allocate
		li	$v0, SysAlloc		# Load allocation function
		syscall
		move	$t0, $v0		# Move pointer to memory to t0
		move 	$t9, $t0		# Store original pointer in t9
		
#DELETE THIS AFTER PLEASE (EVERYTHING IN BETWEEN)
		la	$a0, ($t3)
		li	$v0, SysPrintInt
		syscall
#STOP DELETING HERE PLEASE
		
#
allocLoop:	sb	$t2, 0($t0)		# Store 0xFF into byte at t4
		addi	$t0, $t0, 1		# Move pointer to next byte
		addi	$t5, $t5, 1		# Increment counter
		blt	$t5, $t3, allocLoop	# If t5<t3, go to allocLoop
		
#
		move	$t0, $t9		# Reset pointer at t0 to t9
		lw	$t6, userInput		# Load userInput into t6
		srl	$t4, $t6, 2		# t4 = user input/2
		li	$t2, 2			# Index for divisor
		li	$t1, 0			# Index in byte
		li	$t5, 0			# Index for bit position
nextDivisor:	#beq	$t2, $t4, printPrimes	# If t2=t4, go to printPrimes
		j	nextBit			# Jump to nextBit
incrDivisor:	addi	$t2, $t2, 1		# Increment divisor
		blt	$t2, $t4, nextDivisor	# If t2<t4, go to nextDivisor
		j	printPrimes		# Jump to printPrimes
		
#
nextBit:	beq	$t5, $t6, nextDivisor	# If t1=t6, go to nextDivisor
		blt	$t5, 4, skipBits	# If t5<4, go to skipBits
		j	checkDivisible
		
#
createMask:	li	$t8, 7			# Load 7 into t8
		sub	$t6, $t8, $t1		# t6 = 7 - t1 (position in byte)
		li	$t8, 1			# Load 1 into t8
		sllv	$t6, $t8, $t6		# Create mask (t8 shifted left by t6)
		
applyMask:	lb	$t8, ($t0)		# Load byte at position t0 into t8
		and	$t8, $t8, $t6		# Apply the bitmask
incrPosition:	addi	$t5, $t5, 1		# Increment bit position
		lw	$t6, userInput		# Load userInput into t6
		beq	$t5, $t6, resetBitPos	# If t5=t6, go to resetBitPos
		beq	$t1, 7, resetBytePos	# If t1=7, go to resetBytePos
		addi	$t1, $t1, 1		# Increment position in byte (t1)
		j	nextBit			# Jump to nextBit
		
#
resetBitPos:	li	$t5, 0			# Set bit position (t5) to 0
		li	$t1, 0			# Set position in byte (t1) to 0
		j	incrDivisor		# Jump to incrDivisor

#
resetBytePos:	li	$t1, 0			# Set position in byte (t1) to 0
		addi	$t0, $t0, 1		# Move pointer to next byte
		
		j	nextBit			# Jump to nextBit
		
#
#initVariables:	move	$t8, $t2
#		move	$t7, $t5
checkDivisible: #bleu	$t8, $t7, handleMult	# If t2<=t5, go to handleMult
		div	$t8, $t5, $t2
		mul	$t7, $t8, $t2
		sub	$t8, $t5, $t7
		beq	$t8, 0, case0
		bgt	$t8, 0, case1
		
#
skipBits:	li	$t5, 4			# Set bit index to 4
		li	$t1, 4			# Set position in byte to 4
		j	nextBit			# Jump to nextByte
		
#
case1:		li	$t7, 1
		j	incrPosition
		
case0:		li	$t7, 0
		j	createMask	

#
		move	$t0, $t9		# Reset pointer at t0 to t9
		li	$t1, 0			# Index in byte
		li	$t5, 2			# Index for bit position
		lw	$t6, userInput		# Load userInput into t6
printPrimes:	beq	$t5, $t6, exitFunction	# If t5=t6, go to exitFunction
		beq	$t1, 8, resetByteCnt	# If t1=8, go to resetByteCnt
		lb	$t7, ($t0)		# Load byte at t0 into t7
		srlv	$t8, $t7, $t1		# Pick bit position at t1
		and	$t8, $t8, 1		# AND t8 and 1
		beq	$t8, 1, printNum	# If t8=1, found a prime, printNum
		j	incrPositions		# Jump to incrPositions
		
#
resetByteCnt:	li	$t1, 0			# Reset index in byte (t1) to 0
		addi	$t0, $t0, 1		# Move pointer to next byte
		j	printPrimes		# Jump to printPrimes

#
printNum:	move	$a0, $t5		# Move t5 into a0
		li	$v0, SysPrintInt	# Load print function
		syscall				# Print the prime
		la	$a0, newlineChar
		li	$v0, SysPrintString
		syscall
		
incrPositions:	addi	$t5, $t5, 1		# Increment bit position
		addi	$t1, $t1, 1		# Increment position in byte
		j	printPrimes		# Jump to printPrimes

		
exitFunction:	li	$v0, SysExit		# Load exit function
		syscall				# Exit
