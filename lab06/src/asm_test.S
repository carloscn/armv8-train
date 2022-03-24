.global test_adr
.align 3
.global my_test_data

// add-symbol-file benos.elf 0x000000080030 -s .text.boot 0x000000080000 -s .rodata 0x0000000802e8

my_test_data:
	.dword 0x12345678abcdabcd

test_adr:
	adr x1, my_test_data
	adrp x2, my_test_data
	// read back offset
	add x2, x2, #:lo12:my_test_data
	ldr x3, [x1]

	// using ldr read label
	// my_test_data -> x4
	ldr x4, =my_test_data
	// *my_test_data -> x4
	ldr x5, my_test_data

	// read init_pg_dir address
	adrp x6, init_pg_dir
	ldr x7, =init_pg_dir
	ret
