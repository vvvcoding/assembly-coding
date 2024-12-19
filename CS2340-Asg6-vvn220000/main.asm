# This program can encrypt or decrypt files given by the user. 
# A meny will prompt the user to enter:
# 1 to encrypt a file, 2 to decrypt a file, and 3 to exit.
# The program will then take input for an input file and an output file, as well
# as a key used to encrypt/decrypt the file.
# This program was written by Varun Natarajan on 11/13/2024.
# NetID: vvn220000

		.include	"SysCalls.asm"			# Include syscalls
		.include	"macros.asm"			# Include macros
		.data
fileNameBuffer: .space		255				# Filename buffer
		.eqv		fileBufSize	255		# Filename buffer size
keyBuffer:	.space		60				# Key buffer
		.eqv		keyBufSize	60		# Key buffer size
outputBuffer:	.space		255				# Output buffer
readingBuffer:	.space		1024				# Buffer for reading data
		.eqv		readBufSize	1024		# Reading buffer size
inputFileDesc:	.word		0				# Input file descriptor
outputFileDesc:	.word		0				# Output file descriptor
newLine:	.asciiz		"\n"				# Newline
		# Prompt for menu
menuPrompt:	.asciiz		"===================\nMenu: \n1: Encrypt the file \n2: Decrypt the file \n3: Exit \n===================\n"
inputPrompt:	.asciiz		"Enter your choice: "		# Prompt for input
fileInputDec:	.asciiz		"Enter a filename to decrypt: "	# Prompt for encryption file
fileInputEnc:	.asciiz		"Enter a filename to encrypt: "	# Prompt for decryption file
fileOpenError:	.asciiz		"Error, file not found.\n"	# Prompt for file open error
keyPrompt:	.asciiz		"Enter key: "			# Prompt for key
keyError:	.asciiz		"Error, nothing entered for key.\n"	# Prompt for key error		
outputPrompt:	.asciiz		"Enter output name: "		# Prompt for outfile
encExtension:	.asciiz		"enc"				# Encryption extension
txtExtension:	.asciiz		"txt"				# Text extension
		.text
		
# Main Function:
# This function will call the menu function until 3 is entered,
# then it will call the exit function
main:		
encryptionLoop:
		# Call menu function, will return with 1, 2, or 3 in $v0
		jal	menu			# Call menu function and save $ra
		
		# If 3 is entered, exit
		beq	$v0, 3, exit		# Branch if $v0 = 3
		
		# Get file names and open files
		jal	fileSetUp		# Call fileSetUp function
		
		# Call encryption/decryption function, else continue loop
		beq	$s0, 0, encryptionLoop	# Branch if $s0 = 0
		beq	$s0, 2, encDecCall	# Branch if $s0 = 2
		beq	$s0, 1, encDecCall	# Branch if $s0 = 1
		j	contMainLoop		# Continue main loop
		
		# Call encrypt and decrypt functions
encDecCall:	jal	encryptOrDecrypt	# Call encryptOrDecrypt function
		
		# Else, continue loop
contMainLoop:	j	encryptionLoop		# Continue main loop
# End of main function

		
# Menu Function:
# Called by the main
# Will print the menu and wait for input. Will return to main with the
# number entered by the user
menu:		# Use macros to print menu
		PrintString(menuPrompt)		# Print menuPrompt
		
		# Take input from user and validate
validateInput:	PrintString(inputPrompt)	# Print inputPrompt
		UserInputInt			# Take input for a choice
		blt	$v0, 1, validateInput	# If input < 1, take input again
		bgt	$v0, 3, validateInput	# If input > 3, take input again
		
		# Return to main
		jr	$ra			# Jump to main	
# End of menu function

		
# fileSetUp Function:
# Takes input for an input and output filename and a key.
# If the input or output file name cannot be found, an error is displayed.
# If no output file name is entered, the input file name is copied, and the
# extension is changed to the proper one (.enc or .txt). The files are then
# opened/created.
fileSetUp:	
		# Print correct prompt
		move	$s0, $v0		# Store user choice
		beq	$v0, 2, decPrint	# If user input = 2, decPrint
		PrintString(fileInputEnc)	# Print fileInputEnc
		j	getFileName		# Jump to getFileName
decPrint:	PrintString(fileInputDec)	# Print fileInputDec

		# Get filename
getFileName:	la	$a0, fileNameBuffer	# Load buffer
		li	$a1, fileBufSize	# Load buffer size
		li	$v0, SysReadString	# Load read string function
		syscall				# Read file name
		
		# Null-terminate the filename
		AllocStack			# Allocate stack space and store return to main in stack
		jal	removeNewLine		# Call removeNewLine function

		# Open file, if $v0 is negative, error, else, save file descriptor
		la	$a0, fileNameBuffer	# Load address of fileNameBuffer
		li	$a1, 0			# Flag - read only
		li	$a2, 0			# Mode, which is ignored
		li	$v0, SysOpenFile	# Load open file function
		syscall				# Open file
		blt	$v0, 0, fileNotFound	# If $v0 < 0, file not found
		sw	$v0, inputFileDesc	# Store input file descriptor
		
		# Request key from user
		PrintString(keyPrompt)		# Print keyPrompt
		la	$a0, keyBuffer		# Load keyBuffer
		li	$a1, keyBufSize		# Load keyBufSize
		li	$v0, SysReadString	# Load read string function
		syscall				# Get key
		lb	$t0, 0($a0)		# Load first byte
		beq	$t0, $t8, printKeyError	# If $t0 = $t8 (newline), print key error

		# Get output file
		PrintString(outputPrompt)	# Print outputPrompt
		la	$a0, outputBuffer	# Load outputBuffer
		li	$a1, fileBufSize	# Load fileBufSize
		li	$v0, SysReadString	# Load read string function
		syscall				# Load output file name
		lb	$t0, 0($a0)		# Load first byte
		beq	$t0, $t8, outputFunc	# If $t0 = $t8 (newline), outputFunc
		
		# Null-terminate the filename
		jal	removeNewLine		# Call removeNewLine function
		j	openOutput		# Jump to openOutput
		
		# Call setOutputFile function to copy the filename and add correct extension
outputFunc:	jal	setOutputFile		# Call setOutputFile function
		
		# Open output file
openOutput:	la	$a0, outputBuffer	# Load address of outputBuffer
		li	$a1, 1			# Flag - write only
		li	$a2, 0			# Mode, which is ignored
		li	$v0, SysOpenFile	# Load open file function
		syscall				# Open file
		blt	$v0, 0, fileNotFound	# If $v0 < 0, file not found
		sw	$v0, outputFileDesc	# Store output file descriptor
		
		# Go to returnMain
		j	returnMain		# Jump to returnMain 

		# File not found or not opened, print error
fileNotFound:	PrintString(fileOpenError)	# Print fileOpenError
		li	$s0, 0			# Set $s0 = 0
		j	errorReturn		# Jump to errorReturn		

		# Print key error, then return to main
printKeyError:	PrintString(keyError)		# Print keyError
		j	errorReturn		# Jump to errorReturn

		# Return to function call
returnMain:	move	$v0, $s0		# Set $v0 = user menu choice
errorReturn:	DeallocStack			# Get return address and deallocate stack
		jr	$ra			# Return to main
# End of fileSetUp function


# removeNewLine Function:
# This function takes a string and replaces the newline character at the end
# with a null-terminator. This will get called when the user enters a filename
removeNewLine:	# Null-terminate the filename
		move	$t9, $a0		# Set $t9 = $a0
		li	$t8, '\n'		# Set $t8 = newLine
insertNullLoop:	lb	$t0, 0($t9)		# Load byte into $t0
		beq	$t0, $t8, setNull	# If $t0 = $t8 = newLine, setNull
		addi	$t9, $t9, 1		# Increment pointer
		j	insertNullLoop		# Repeat loop
setNull:	sb	$zero, 0($t9)		# Set current byte = null
		jr	$ra			# Return to function call
# End of removeNewLine function


# setOutputFile Function:
# This function is called when the user doesn't give an output file.
# First, the function copies the string in fileNameBuffer to outputBuffer.
# The function stops copying when it finds the period.
# After the period, check if you are adding the .enc or .txt extension.
# Then add the correct extension, null-terminate it, and exit the function.
setOutputFile:	# Set outputBuffer equal to that of fileNameBuffer
		la	$t6, fileNameBuffer	# Load fileNameBuffer address
		la	$t5, outputBuffer	# Load outputBuffer address
copyLoop:	lb	$t0, 0($t6)		# Load byte from fileNameBuffer
		sb	$t0, 0($t5)		# Store fileNameBuffer byte in outputBuffer
		addi	$t6, $t6, 1		# Increment fileNameBuffer pointer
		addi	$t5, $t5, 1		# Increment outputBuffer pointer
		beq	$t0, '.', extension	# If $t0 = '.', add the correct extension
		j	copyLoop		# Else, continue loop
		
		# Add the correct extension
extension:	li	$t3, 0			# Load 0 into $t3
		li	$t4, 3			# Load 3 into $t4
		beq	$s0, 2, textExtension	# If $s0 = Decryption, textExtension
		
		# Encryption extension loop, adds the extension after the period
		la	$t7, encExtension	# Load encExtension
eExtensionLoop:	lb	$t8, 0($t7)		# Load byte from encExtension
		sb	$t8, 0($t5)		# Store byte in outputBuffer
		addi	$t7, $t7, 1		# Increment encExtension pointer
		addi	$t5, $t5, 1		# Increment outputBuffer pointer
		addi	$t3, $t3, 1		# Increment $t3
		beq	$t3, $t4, nullTerminate	# If $t3 = $t4, nullTerminate
		j	eExtensionLoop		# Repeat loop
		
		# Text extension loop, adds the extension after the period
textExtension:	la	$t7, txtExtension	# Load txtExtension
tExtensionLoop:	lb	$t8, 0($t7)		# Load byte from txtExtension
		sb	$t8, 0($t5)		# Store byte in outputBuffer
		addi	$t7, $t7, 1		# Increment txtExtension pointer
		addi	$t5, $t5, 1		# Increment outputBuffer pointer
		addi	$t3, $t3, 1		# Increment $t3
		beq	$t3, $t4, nullTerminate	# If $t3 = $t4, nullTerminate
		j	tExtensionLoop		# Repeat loop
		
nullTerminate:	sb	$zero, 0($t5)		# Null-terminate the filename

		# Return
		jr	$ra			# Return to function call
# End of setOutputFile function

		
# encryptOrDecrypt Function:
# While the number of bytes read is greater than 0, this function will encrypt
# each byte in the buffer using the key given by the user. The buffer will then be
# written to the output file. When 0 bytes are read, the loop will end and the 
# output and input files will be closed.
encryptOrDecrypt:
		# While bytes read > 0, read blocks of data
readFileLoop:	lw	$a0, inputFileDesc	# Load input file descriptor
		la	$a1, readingBuffer	# Load address of buffer
		li	$a2, readBufSize	# Load size of buffer (1024 bytes)
		li	$v0, SysReadFile	# Load file reading function
		syscall				# Read data from file
		beq	$v0, 0,	closeFiles	# If 0 bytes read, closeFiles
		move	$t0, $v0		# Set $t0 = number of bytes read
		
		# Encrypt data in buffer with key using a loop
		la	$t1, keyBuffer		# Load address of key buffer
		li	$t2, 0			# Initialize index to 0
		
		# Loop for encryption
encryptBufLoop:	lb	$t3, 0($t1)		# Load byte from key
		beq	$t3, '\n', resetKey	# If key points to '\n', set key pointer to base address
		
		# Encrypt/decrypt the byte
		lb	$t4, 0($a1)		# Load byte from buffer
		beq	$s0, 1, encryptBuf	# If $s0 = 1, encryptBuf
		beq	$s0, 2, decryptBuf	# If $s0 = 2, decryptBuf
returnBufLoop:	sb	$t4, 0($a1)		# Store encrypted byte back in the buffer
		addi	$a1, $a1, 1		# Increment buffer pointer
		addi	$t2, $t2, 1		# Increment buffer index
		bge	$t2, $t0, doneEncrypt	# If $t2 >= number of bytes read, doneEncrypt
		
		# Else, continue loop
		addi	$t1, $t1, 1		# Increment key buffer pointer
		j	encryptBufLoop		# Repeat loop
		
		# Encrypt or decrypt byte from buffer
encryptBuf:	addu	$t4, $t4, $t3		# Add key to byte from buffer
		j	returnBufLoop		# Return to the loop

decryptBuf:	subu	$t4, $t4, $t3		# Subtract key from byte
		j	returnBufLoop		# Return to the loop
		
		# Reset keyBuffer address, then continue encryption
resetKey:	la	$t1, keyBuffer		# Load keyBuffer base address
		j	encryptBufLoop		# Return to encryption loop
		
		# Write the encrypted/decrypted buffer to the output file
doneEncrypt:	lw	$a0, outputFileDesc	# Load output file descriptor
		la	$a1, readingBuffer	# Load buffer
		move	$a2, $t0		# Load number of bytes to write
		li	$v0, SysWriteFile	# Load file writing function
		syscall				# Write encrypted buffer to file
		
		# Return to initial loop and read the next block of data
		j	readFileLoop		# Jump to readFileLoop
		
		# Since 0 bytes were read, close the file and return to main
closeFiles:	lw	$a0, inputFileDesc	# Load input file descriptor
		li	$v0, SysCloseFile	# Load close file function
		syscall				# Close input file
		
		# Close output file
		lw	$a0, outputFileDesc	# Load output file descriptor
		li	$v0, SysCloseFile	# Load close file function
		syscall				# Close output file

		# Return to function call
		jr	$ra			# Return to main
# End of encrypt function


# Exit Function:
# Exits the program when 3 is entered
exit:		li	$v0, SysExit		# Load exit function
		syscall				# Exit program