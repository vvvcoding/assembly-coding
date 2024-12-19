# Math Game Program
# This is a memory game.
# The user will enter a row and column and the game will flip over that tile
# to reveal what is underneath the question mark at that location.
# If the user flips over 2 question marks and the values underneath it match,
# they will stay on the screen. Otherwise, they will be flipped back over.
# The game is over when the game is displaying all values on the board.
# Written by Varun Natarajan on 12/2/24
# NetID: vvn220000
		.data
		.include	"SysCalls.asm"
		.include	"macros.asm"
hasBeenFound:	.word		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		# Boolean array (0 if not found, 1 if found)
filedesc:	.word		0			# File descriptor
locationsArr:	.space		16			# Array that contains locations
readingBuffer:	.space		12			# Buffer for reading
userInputPos:	.space		8			# Buffer for position
		.eqv		readBufSize	12	# Reading buffer size
		.eqv		posBufSize	8	# Position input size
		.eqv		numCols		4	# Number of columns
row1:		.asciiz		" \tA\tB\tC\tD\n"	# Row 1 of the board
questionMark:	.asciiz		"?"			# Question mark to print
tab:		.asciiz		"\t"			# Tab to print
newline:	.asciiz		"\n"			# Newline
multiNewline:	.asciiz		"\n\n\n\n\n\n\n\n\n\n"	# Multiple newlines
prompt:		.asciiz		"Enter column and row of your choice, for example, B2: "	# Prompt for user input
reEnterInput:	.asciiz		"Invalid position, re-enter your choice.\n"		# Error prompt
sameInputErr:	.asciiz		"Same position entered, be original.\n"			# Error prompt
gameOver:	.asciiz		"Congratulations! You won!\n"				# Game over prompt
mathFile:	.asciiz		"C:\\Users\\Dell User\\Downloads\\MathData.txt"		# File name
		.text	
# Main Function:
main:		# Check if game is over
		li	$t1, 0			# Load counter
		la	$t2, hasBeenFound	# Load boolean array
checkIfDone:	lw	$t0, 0($t2)		# Load hasBeenFound array
		beqz	$t0, continueGame	# If $t0 = 0, continue the game
		beq	$t1, 16, exitFunction	# If $t1 = 16, exitFunction
		addi	$t2, $t2, 4		# Increment array index
		addi	$t1, $t1, 1		# Increment counter
		j	checkIfDone		# Repeat loop
		
		# If there are still matches to be found, continue game
continueGame:	jal	printBoard		# Call printBoard function
		jal	boardSetUp		# Call boardSetUp function
		
		# Get and display the first user input
		jal	getPosition		# Call getPosition function
		move	$s1, $t2		# Save location in $s1
		move	$s3, $t2		# Save location in $s3
		la	$t3, hasBeenFound	# Load address of hasBeenFound
		add	$t2, $t2, $t3		# Add base address to location
		la	$t7, 0($t2)		# Load adress in $t2 into $t7
		li	$t6, 5			# Set $t6 = non-zero integer
		lw	$t5, 0($t7)		# Load boolean from array
		bnez	$t5, skipInput		# If $t5 != 0, skipInput
		sw	$t6, 0($t7)		# Store non-zero integer in boolean array
		PrintString(multiNewline)	# Print multiple newlines
		jal	printBoard		# Call printBoard function
		j	nextInput
		
		# Print error statement and restart loop
skipInput:	PrintString(sameInputErr)	# Print sameInputErr
		Sleep(3000)			# Sleep console for 3 seconds
		j	finishLoop		# Jump to finishLoop
		
		# Get and display the second user input
nextInput:	jal	getPosition		# Call getPosition function
		beq	$t2, $s1, errorHandle	# If $t2 = $s1, errorHandle
		move	$s2, $t2		# Save location in $s2
		move	$s3, $t2		# Save location in $s3
		la	$t3, hasBeenFound	# Load address of hasBeenFound
		add	$t2, $t2, $t3		# Add base address to location
		la	$t7, 0($t2)		# Load address in $t2 into $t7
		li	$t6, 5			# Set $t6 = non-zero integer
		lw	$t5, 0($t7)		# Load boolean from array
		bnez	$t5, errorHandle	# If $t5 != 0, errorHandle
		sw	$t6, 0($t7)		# Store non-zero integer in boolean array
		PrintString(multiNewline)	# Print multiple newlines
		jal	printBoard		# Call printBoard function
		
		# Give user time to memorize locations
		Sleep(3000)			# Sleep console for 4 seconds

		# Load 2 elements from given indices from locationsArr and check if 
		# they are equal. If they are not, reset hasBeenFound elements at 
		# those indices to 0.
		move	$t7, $s1		# Get saved location from $s1 into $t7
		la	$t3, locationsArr	# Load locationsArr into $t3
		srl	$t7, $t7, 2		# $t7 = $t7 / 4
		add	$t7, $t7, $t3		# Add locationsArr address to $t7
		move	$t8, $s2		# Get saved location from $s2 into $t8
		srl	$t8, $t8, 2		# $t8 = $t8 / 4
		add	$t8, $t8, $t3		# Add locationsArr address to $t8
		lb	$t4, 0($t7)		# Load element from locationsArr into $t4
		lb	$t5, 0($t8)		# Load element from locationsArr into $t5
		beq	$t4, $t5, finishLoop	# If $t4 = $t5, finishLoop
		j	resetBool		# Jump to resetBool
		
		# If user enteres the same location twice, print error
errorHandle:	PrintString(sameInputErr)	# Print sameInputErr
		Sleep(3000)			# Sleep console for 2 seconds
		la	$t3, hasBeenFound	# Load address of hasBeenFound
		add	$s1, $s1, $t3		# Add address to $s1
		la	$t4, 0($s1)		# Load element at address
		sw	$zero, 0($t4)		# Reset element to zero
		j	finishLoop		# Jump to finishLoop
		
		# If elements not equal, reset hasBeenFound elements to 0
resetBool:	la	$t3, hasBeenFound	# Load address of hasBeenFound
		add	$s1, $s1, $t3		# Add address to $s1
		add	$s2, $s2, $t3		# Add address to $s2
		la	$t4, 0($s1)		# Load element at address
		la	$t5, 0($s2)		# Load element at address
		sw	$zero, 0($t4)		# Reset element to zero
		sw	$zero, 0($t5)		# Reset element to zero

		# Finish current loop and repeat the process
finishLoop:	PrintString(multiNewline)	# Print multiple newlines
		j	main			# Jump to main
# End of main function

# PrintBoard Function:
# This function prints the board to the screen.
printBoard:	SaveReturnAddress		# Save return address to main
		PrintString(row1)		# Print row1 of the board

		# Loop through each row and each column and print the board
		li	$s6, 0			# Initialize counter
		li	$t0, 1			# Load board-row index
		la	$t2, hasBeenFound	# Load array into $t2
loopThroughRow: PrintInteger($t0)		# Print current row
		li	$t1, 0			# Load board-column index
loopThroughCol:	lw	$t3, 0($t2)		# Load boolean from array into $t3
		beqz	$t3, printQ		# If $t3 = 0, print question mark
		bnez	$t3, printValue		# If $t3 != 0, print value at index
returnColLoop:	addi	$t2, $t2, 4		# Increment array pointer
		addi	$t1, $t1, 1		# Increment column index
		blt	$t1, 4, loopThroughCol	# If $t1 < 5, loopThroughCol
endInnerLoop:	addi	$t0, $t0, 1		# Increment row index
		PrintString(newline)		# Print newline
		blt	$t0, 5, loopThroughRow	# If $t0 < 5, loopThroughRow
		bge	$t0, 5, returnBoard	# If $t0 >= 4, returnBoard

		# Print either question mark or value underneath question mark
printQ:		PrintString(tab)		# Print tab
		PrintString(questionMark)	# Print questionMark
		addi	$s6, $s6, 1		# Increment counter
		j	returnColLoop		# Continue looping
		
		# Print value "under" the question mark
printValue:	PrintString(tab)		# Print tab
		move	$s3, $s6		# Load counter to $s3
		jal	getPrintValue		# Call getPrintValue and pass in $s3
		addi	$s6, $s6, 1		# Increment counter
		j	returnColLoop		# Repeat loop

		# Return to main
returnBoard:	DeallocStack			# Deallocate the stack and get $ra
		jr	$ra			# Return to function call
# End of PrintBoard function

# BoardSetUp Function:
# This function opens the file given and calls the readFile function
boardSetUp:	# Open file
		la	$a0, mathFile		# Load address of mathFile
		li	$a1, 0			# Flags – read only
		li	$a2,0			# Mode, which is ignored
		li	$v0,13 			# Function magic number
		syscall				# Open file
		sw 	$v0, filedesc		# Save file descriptor
		
		# Read from file, store info to arrays, then return to main 
		SaveReturnAddress		# Save return address to main
		jal	readFile		# Call readFile function
		DeallocStack			# Deallocate the stack and get $ra
		jr	$ra			# Return to main
# End of boardSetUp function

# ReadFile Function
# This function searches for a ',' and then stores the value after the ',' in
# the locationsArr.
readFile:	la	$t6, locationsArr	# Load locationsArr address
		
		# While bytes read > 0, read blocks of data
readOuterLoop:	lw	$a0, filedesc		# Load filedesc
		la	$a1, readingBuffer	# Load reading buffer
		li	$a2, readBufSize	# Load buffer size
		li	$v0, SysReadFile	# Load file reading function
		syscall				# Read file
		beq	$v0, 0,	stopReading	# If 0 bytes read, stopReading
		move	$t0, $v0		# Set $t0 = number of bytes read
		
		# Save locations from file to array
readInnerLoop:	lb	$t4, 0($a1)		# Load byte from buffer
		beq	$t4, 44, storeLocation	# If $t4 = ',', storeLocation
		addi	$a1, $a1, 1		# Increment buffer pointer
		bne	$t0, $a1, readInnerLoop
		
		# Store location in array
storeLocation:	addi	$a1, $a1, 1		# Increment buffer pointer
		lb	$t4, 0($a1)		# Load byte with location
		sb	$t4, 0($t6)		# Store byte to array
		addi	$t6, $t6, 1		# Increment array pointer
		addi	$a1, $a1, 1		# Increment buffer pointer
		lb	$t4, 0($a1)		# Load byte from buffer
		j	readOuterLoop		# Repeat loop
		
		# Since 0 bytes were read, return to function call
stopReading:	lw	$a0, filedesc		# Load file descriptor
		li	$v0, SysCloseFile	# Load close file function
		syscall				# Close input file
		jr	$ra			# Return to main
# End readFile function

# GetPosition Function:
# This function converts the user input in the form of 'B4' to a location in
# a 2D-array, then returns that position in the register $t2.
getPosition:	# Get user input for a position
getPosInput:	PrintString(prompt)		# Print input prompt
		la	$a0, userInputPos	# Load space for input
		li	$a1, posBufSize		# Load input size
		li	$v0, SysReadString	# Load string read function
		syscall				# Take user input
		
		# Validate input
		move	$s7, $a0		# Save buffer
		li	$t1, 0			# Initialize $t1 with 0
checkLength:	lb	$t0, 0($s7)		# Load byte from buffer
		addi	$s7, $s7, 1		# Increment buffer pointer
		addi	$t1, $t1, 1		# Increment counter
		beq	$t0, 10, colIndexPos	# If $t0 = '\n', colIndexPos
		bgt	$t1, 2, errorPrint	# If counter > 2, errorPrint
		j	checkLength		# Jump to checkLength
		
		# Get column index
colIndexPos:	la	$t0, userInputPos	# Load userInputPos
		lb	$t1, 0($t0)		# Load letter from input
		beq	$t1, 'A', colIndA	# If $t1 = 'A', colIndA
		beq	$t1, 'B', colIndB	# If $t1 = 'B', colIndB
		beq	$t1, 'C', colIndC	# If $t1 = 'C', colIndC
		beq	$t1, 'D', colIndD	# If $t1 = 'D', colIndD
		PrintString(reEnterInput)	# Print reEnterInput
		j	getPosInput		# Else, get position again
		
		# Set column index
colIndA:	li	$t1, 0			# $t1 (column index) = 0
		j	getRowIndex		# Jump to getRowIndex
colIndB:	li	$t1, 1			# $t1 (column index) = 1
		j	getRowIndex		# Jump to getRowIndex
colIndC:	li	$t1, 2			# $t1 (column index) = 2
		j	getRowIndex		# Jump to getRowIndex
colIndD:	li	$t1, 3			# $t1 (column index) = 3

		# Get row index
getRowIndex:	lb	$t2, 1($t0)		# Load number from input
		beq	$t2, 49, rowInd1	# If $t2 = 49 (ascii), rowInd1
		beq	$t2, 50, rowInd2	# If $t2 = 50 (ascii), rowInd2
		beq	$t2, 51, rowInd3	# If $t2 = 51 (ascii), rowInd3
		beq	$t2, 52, rowInd4	# If $t2 = 52 (ascii), rowInd4
errorPrint:	PrintString(reEnterInput)	# Print reEnterInput
		j	getPosInput		# Else, get position again
		
		# Set row index
rowInd1:	li	$t2, 1			# $t2 (row index) = 1
		j	calcPosition		# Jump to calcPosition
rowInd2:	li	$t2, 2			# $t2 (row index) = 2
		j	calcPosition		# Jump to calcPosition
rowInd3:	li	$t2, 3			# $t2 (row index) = 3
		j	calcPosition		# Jump to calcPosition
rowInd4:	li	$t2, 4			# $t2 (row index) = 4	
		
		# Calculate array position
calcPosition:	sub	$t2, $t2, 1		# $t2 - 1
		sll	$t2, $t2, 2		# $t2 = row index * number of columns
		add	$t2, $t2, $t1		# $t2 = $t2 + column index
		sll	$t2, $t2, 2		# $t2 = $t2 * number of bytes
		
		# Return to main
		jr	$ra			# Return to function call
# End of getPosition function

# GetPrintValue Function:
# This function reads the file given and prints the value "under" the question
# mark at the location entered by the user.
getPrintValue:	move	$t9, $s3		# Load saved location
		li	$t8, 0			# Initialize inner loop counter
		
		# Open file
		la	$a0, mathFile		# Load address of mathFile
		li	$a1, 0			# Flags – read only
		li	$a2,0			# Mode, which is ignored
		li	$v0,13 			# Function magic number
		syscall				# Open file
		sw 	$v0, filedesc		# Save file descriptor
		
		# While counter <= $t9, repeat loop
getValBufLoop:	lw	$a0, filedesc		# Load filedesc
		la	$a1, readingBuffer	# Load reading buffer
		li	$a2, readBufSize	# Load buffer size
		li	$v0, SysReadFile	# Load file reading function
		syscall				# Read file
		addi	$t8, $t8, 1		# Increment inner loop counter
		ble	$t8, $t9, getValBufLoop	# If $t8 <= $t9, getValBufLoop
		
		# Find the string to display to the screen, then print it
readValBuf:	lb	$t8, 0($a1)		# Load byte from buffer
		bne	$t8, 32, printValBuf	# If $t8 != ' ', printValBuf
		addi	$a1, $a1, 1		# Increment buffer pointer
		j	readValBuf		# Repeat loop
printValBuf:	lb	$t8, 0($a1)		# Load byte from buffer
		beq	$t8, 32, stopPrinting	# If $t8 = ' ', stopPrinting
		move	$a0, $t8		# Load $t8 in $a0
		li	$v0, SysPrintChar	# Load print character function
		syscall				# Print character
		addi	$a1, $a1, 1		# Increment buffer pointer
		j	printValBuf		# Repeat loop
		
		# Close file and return to function call
stopPrinting:	lw	$a0, filedesc		# Load file descriptor
		li	$v0, SysCloseFile	# Load close file function
		syscall				# Close input file
		jr	$ra			# Return to printBoard function
# End of getPrintValue function

# Exit Function:
exitFunction:	jal	printBoard		# Call printBoard function
		PrintString(gameOver)		# Print gameOver prompt
		li	$v0, SysExit		# Load exit function
		syscall				# Exit