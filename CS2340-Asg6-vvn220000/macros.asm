# Macros file for encryption/decryption assignment
# Contains macros for printing
# Created by Varun Natarajan on 11/13/2024
# NetID: vvn220000

# Macro for printing
		.macro	PrintString(%string)
		la	$a0, %string
		li	$v0, SysPrintString
		syscall
		.end_macro
		
# Macro for allocating stack space and storing return address
		.macro	AllocStack
		subi	$sp, $sp, 4
		sw	$ra, 4($sp)
		.end_macro

# Macro for deallocating stack space and getting return address
		.macro	DeallocStack
		lw	$ra, 4($sp)
		addi	$sp, $sp, 4
		.end_macro
		
# Macro for taking input
		.macro	UserInputInt
		li	$v0, SysReadInt
		syscall
		.end_macro
