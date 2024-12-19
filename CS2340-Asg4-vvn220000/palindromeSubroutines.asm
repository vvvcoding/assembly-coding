# This file holds subroutines that will be called in the main file of the
# recursive palindromes program.
# The first subroutine trims any invalid input from the user inputed string,
# resulting in a new buffer that only contains valid input, all in uppercase
# The second subroutine is a recursive function that compares the leftmost and 
# rightmost characters of a string from the stack. If they are equal, the function
# is called recursively and the process is repeated until the program determines
# whether a palindrome was found.
# Written by Varun Natarajan, 10/16/24
# NetID: vvn220000

		.include	"SysCalls.asm"
		.data
newBuffer:	.space	200			# Max string length
		.text
		
# Global variables
		.globl	mainCheck

# Main function in the palindromeChecking.asm file
# Call subroutines: first calls stringPrep to trim any invalid characters, then
# calls the recursive function, finally returns to the previous file to print
mainCheck:	li	$s0, 0			# Initialize s0 register
		move	$s0, $ra		# Store return address
		
		# Call stringPrep function to trim invalid input
		la	$a0, buffer		# Load buffer (user input) into a0
		jal	stringPrep		# Jump to stringPrep
		
		# Call recursive function
		move	$a0, $v0		# Save newBuffer in a0 
		jal	saveReturn		# Call recursion
		move	$ra, $s0		# Get return address to other file
		jr	$ra			# Jump to return address
		
# stringPrep function will remove any characters that are not numbers or 
# uppercase/lowercase letters and save the valid characters into newBuffer
stringPrep:	li	$t1, 0			# Index for output string
		lb	$t0, 0($a0)		# Load first character
		li	$t2, '\n'		# Load newline character
		beq	$t0, $t2, exit		# Exit function

# prepLoop and the functions it calls will check:
# If the current byte (character) is less than '0', the code will skip over it. 
# If it is between '0' and '9', it will store the byte. If it is greater
# than '9', it will check if it is an alphabetic character
prepLoop:	lb	$t0, 0($a0)		# t0 = first byte of user input
		beqz	$t0, endPrep		# If empty, go to endPrep
		
		# If statements
		blt	$t0, '0', skipByte	# If t0<'0', go to skipByte
		bgt	$t0, '9', checkAlphabet	# If t0>'9', go to checkAlphabet
		j	storeByte		# Jump to storeByte
		
# If current byte (character) is less than 'A', skip the byte.
# If the current byte is greater than 'Z', it could be a lower
# case letter, so go to checkLower. Else, store the byte
checkAlphabet:	li	$t2, 'A'		# Load 'A' into t2
		li	$t3, 'Z'		# Load 'Z' into t3
		blt	$t0, $t2, skipByte	# If t0<'A', go to skipByte
		bgt	$t0, $t3, checkLower	# If t0<'Z', go to checkLower
		j	storeByte		# Jump to storeByte
		
# If current byte (character) is less than 'a' or 'z', skip the byte.
# Else, store the byte.
checkLower:	li	$t2, 'a'		# Load 'a' into t2
		li 	$t3, 'z'		# Load 'z' into t3
		blt	$t0, $t2, skipByte	# If t0<'a', go to skipByte
		bgt	$t0, $t3, skipByte	# If t0>'z', go to skipByte
		sub	$t0, $t0, 32		# Convert character to uppercase
		
# Takes the current byte (character) and stores it into newBuffer, then drops
# down to skipByte to move to the next byte.
storeByte:	sb	$t0, newBuffer($t1)	# Store valid character in newBuffer
		addi	$t1, $t1, 1		# Increment pointer in newBuffer
		
# Increments the pointer to "skip" the byte, then moves repeats the loop
skipByte:	addi	$a0, $a0, 1		# Increment pointer to next character
		j	prepLoop		# Jump to prepLoop
		
# If the current byte (character) is null (\0), you've hit the end of the input
# endPrep saves a \0 into the last byte of newBuffer and then returns to the main
endPrep:	sb	$zero, newBuffer($t1)	# Stores the null character at the end
		la	$v0, newBuffer		# Load address of newBuffer into v0
		jr	$ra			# Return to main
		
# Recursive function:
# Allocate stack space for the return address, the length, and the address of the
# string. Then call the length subrouting to get the length, and then store the
# length. Then use the length of the string to find how much stack space to
# allocate for the string copy, and then copy the string onto the stack.
# Then load the leftmost and rightmost characters of the string from the stack,
# and compare them. If they are equal, call the recursive function. Else, begin
# popping the stack.

# Save return address
saveReturn:	move	$s2, $ra		# Save return address to main
		move	$s3, $sp		# Save stack pointer
		li	$s1, 0			# Initialize s1 to 0

# Recursive function
findPalindrome:	addi	$sp, $sp, -8		# Allocate stack space
		sw	$ra, 0($sp)		# Save return address
		sw	$a0, 4($sp)		# Save string address
		
# Get string length, length will be returned in $t2
		j	loadString		# Jump to loadString
    
# Check base case
baseCaseCheck:	beq	$s1, $t2, nonPalindrome	# If input has no letters/digits, nonPalindrome
		move	$t9, $t2		# Save length
		slti	$t1, $t2, 2		# If t2 (length) < 2, t1 = 1, else t1 = 0
		bnez	$t1, foundPalindrome	# If t1 != 0, foundPalindrome
		
# Check current first and last characters
		lb	$t5, 0($t7)		# Load first character
		addi	$t2, $t2, -1		# Decrement length
		add	$t2, $t2, $t7		# Get offset for last char
		lb	$t6, 0($t2)		# Load last character
		bne	$t5, $t6, nonPalindrome	# If t5 != t6, nonPalindrome

# Allocate space for string, store new string
		j	stringSpace		# Jump to stringSpace
		
# Recursive call
recurseCall:	addi	$s1, $s1, 1		# Increment s1
		j	findPalindrome		# Recurse
		
		
# If palindrome found, deallocate stack space and return to saved address
foundPalindrome:
		move	$ra, $s2		# Reset return address
		move	$sp, $s3		# Deallocate stack
		addi	$v0, $zero, 1		# Set v0 = 1
		jr	$ra			# Return to call
		
# If palindrome not found, deallocate stack space and return to saved address
nonPalindrome:	move	$ra, $s2		# Reset return address
		move	$sp, $s3		# Deallocate stack
		addi	$v0, $zero, 0		# Set v0 = 0
		jr	$ra			# Return to call
		

# Function to get string length, including the null terminator
# Length will be stored in $t2
loadString:	lw	$t7, 4($sp)		# Load the address of string
		move	$t4, $t7		# Get address of string
		li	$t2, 0			# Initialize length counter
loopLen:	lb      $t3, 0($t4)            	# Load character
    		beqz    $t3, baseCaseCheck	# If t3=null, go to baseCaseCheck
    		addi    $t4, $t4, 1             # Move to the next character
    		addi    $t2, $t2, 1             # Increment length counter
    		j       loopLen             	# Repeat


# Function to calculate how much space to allocate for the string
# t3 will now hold the amount of space to allocate (should be multiple of 4)
stringSpace:	move	$t2, $t9		# Reset length
		li	$t3, 0			# Initialize t3
		addi	$t3, $t2, 3		# t3=length + 3
		li	$t4, 3			# Load 3 into t4
		not	$t4, $t4		# Store inverse of 3 in t4
		and	$t3, $t3, $t4		# t3 = t3 AND t4
		
# Function to store current string
		move	$a0, $t3		# Load space needed
		li	$v0, SysAlloc		# Load allocation function
		syscall				# Allocate space

		move	$a0, $v0		# Save address
		addi	$t7, $t7, 1		# Increment pointer
		addi	$t2, $t2, -2		# Decrement length
		
# Copy string to space
		li	$t8, 0			# Initialize counter
copyLoop:	lb	$t6, 0($t7)		# Load character at t7
		sb	$t6, 0($v0)		# Store character to address v0
		addi	$t7, $t7, 1		# Increment source pointer
		addi	$v0, $v0, 1		# Increment destination pointer
		addi	$t8, $t8, 1		# Increment length counter
		bge	$t8, $t2, doneCopy	# If t8=t1, doneCopy
		j	copyLoop		# Repeat

# Store null character in the last character spot, and return to the recursive method
doneCopy:	sb	$zero, 0($v0)		# Store \0 in last character
		j	recurseCall		# Jump to recurseCall
