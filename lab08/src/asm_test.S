.section .data
.align 3
.global my_test_data
my_test_data:
	.dword 0
// add-symbol-file benos.elf 0x000000080030 -s .text.boot 0x000000080000 -s .rodata 0x0000000802e8

.section .text
.global my_atomic_write
my_atomic_write:
	// get my_test_data addr atomicl
	ldr x2, =my_test_data
1:
	ldxr x1, [x2]
	orr x1, x1, x0
	// save x0 to x2, the result on w0
	stxr w0, x1, [x2]
	cbnz w0, 1b
	mov x0, x2
	ret
