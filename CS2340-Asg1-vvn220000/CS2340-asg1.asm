# This program takes user input for a bunch integers and prints the summation
# Written by Varun Natarajan for CS2340, Assignment 1, starting September 4, 2024
# NetID: vvn220000
		.include "SysCalls.asm"		# Includes SysCalls file
		.data
counter:	0				# Num of loops
runningTotal:	0				# Summation of numbers
prompt:		.asciiz	"Enter a number: "	# Stores a prompt
sumPrompt:	.asciiz	"The sum is: "		# Stores a prompt
numIntsPrompt:	.asciiz "The number of integers entered was: "	# Stores a prompt
space:		.asciiz "\n"			# Stores Newline
		.text
start:		lw	$t0,runningTotal	# Load value from memory
		add	$a0,$v0,$t0		# Add t0 + v0 into a0
		sw	$a0,runningTotal	# Store result in runningTotal
		la	$a0,prompt		# Load address of prompt to show
		li	$v0,SysPrintString	# Load print function
		syscall
		lw	$t1,counter		# Load value of counter
		li	$t2,1			# Load value to add
		add	$a1,$t1,$t2		# Add t1 + t2 into a1
		sw	$a1,counter		# Store result in counter
		li	$v0,SysReadInt		# Ask for integer
		syscall
		bnez	$v0,start		# Loop back to start
		lw	$t0,counter		# Load value of counter
		li	$t1,1			# Load value to subtract
		sub	$a0,$t0,$t1		# t0 - t1 stored in a0
		sw	$a0,counter		# Store result in counter
		la	$a0,sumPrompt		# Load address of prompt for result
		li	$v0,SysPrintString	# Load print function
		syscall
		lw	$a0,runningTotal	# Load value of runningTotal
		li	$v0,SysPrintInt		# Load print function
		syscall
		la	$a0,space		# Load address of newline
		li	$v0,SysPrintString	# Load print function
		syscall
		la	$a0,numIntsPrompt	# Load address of string to print
		li	$v0,SysPrintString	# Load print function
		syscall
		lw	$a0,counter		# Load value of counter
		li	$v0,SysPrintInt		# Load print function
		syscall
		li	$v0,SysExit		# Load exit function
		syscall				# Exit