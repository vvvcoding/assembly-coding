# Program for finding if a user inputed string is a palindrome or not
# This is the main file and will call subroutines from another file
# The program will determine if the string is a palindrome by using recursion
# Written by Varun Natarajan, 10/16/24
# NetID: vvn220000

		.include	"SysCalls.asm"
		.data
buffer:		.space	200			# Max size of string
bufferSize:	.word	200			# Max size of string
newLineChar:	.asciiz "\n"			# Newline character
userInput:	.asciiz	""
promptInput:	.asciiz	"Enter a string: "	# Prompts the user for input	
palindrome:	.asciiz	"Palindrome. \n"	# Gets printed when palindrome found
notPalindrome:	.asciiz "Not a palindrome. \n"	# Gets printed when palindrome not found
		.text
		
# Global variables
		.globl	main
		.globl	buffer
		.globl	exit
		
# Start of loop, runs until user enters \n as first character
main:
outerLoop:	la	$a0, promptInput	# Load the prompt
		li	$v0, SysPrintString	# Load print function
		syscall				# Print the prompt
		li	$v0, SysReadString	# Load the read string function
		la	$a0, buffer		# Load the buffer
		lw	$a1, bufferSize		# Load the max length
		syscall				# Take user input
		
# Check if buffer is empty, if it is, end the program
		lb	$t0, buffer		# Load first character
		beqz	$t0, exit		# If buffer empty, go to exit
		
# If buffer is not empty, jump to palindromeCheck and save
# the return address. If palindromeCheck returns 0, go to
# nonPalindrome, else print the palindrome (user input)
		
		jal	mainCheck		# Jump to mainCheck
		beqz	$v0, nonPalindrome	# If v0=0, go to nonPalindrome
		la	$a0, palindrome		# Load palindrome message
		li	$v0, SysPrintString	# Load string print function
		syscall				# Print "Palindrome."
		
# Repeat this process by jumping back to outerLoop
		j	outerLoop		# Jump to outerLoop
		
# If v0=0, the input is not a palindrome, so print "Not a palindrome."
nonPalindrome:	la	$a0, notPalindrome	# Load non-palindrome message
		li	$v0, SysPrintString	# Load string print function
		syscall				# Print "Not a palindrome." 
		j	outerLoop		# Jump to outerLoop
		
# Exit function
exit:		li	$v0, SysExit		# Load exit function
		syscall				# Exit
