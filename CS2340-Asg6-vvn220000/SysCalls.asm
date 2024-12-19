# Definitions of multiple different system calls for MIPS assembly
# This file must be included using .include "SysCalls.asm" rather
# than being assembled as a separate module.
	.eqv	SysPrintInt		1
	.eqv	SysPrintFloat		2
	.eqv	SysPrintDouble		3
	.eqv	SysPrintString		4
	.eqv	SysReadInt		5
	.eqv	SysReadFloat		6
	.eqv	SysReadDouble		7
	.eqv	SysReadString		8
	.eqv	SysAlloc		9
	.eqv	SysExit			10
	.eqv	SysPrintChar		11
	.eqv	SysReadChar		12
	.eqv	SysOpenFile		13
	.eqv	SysReadFile		14
	.eqv	SysWriteFile		15
	.eqv	SysCloseFile		16
	.eqv	SysExitValue		17
