.global ldr_test

// exp_1:
// S1: Load 0x80000 to X1 register using the MOV instruction.
// S2: Load 16 to X3 register using the MOV instruction.
// S3: Read the value of the address from X1 register, write the value to X0, using the LDR instruction.
// S4: Read the value of the address + 8 from X1 register, write the value to X2, using the LDR instruction.
// S5: Read the values of the address from X1 register adding the value of the address in X3 register, write the value to X4.
// S6: Samely, read the (X1+X3<<3), write to the X5 register.

// exp_2:

ldr_test:
	// exp_1
	mov x1, 0x80000
	mov x3, 16

	ldr x0, [x1]   // the illegle method is ldr x0, [0x80000]
	ldr x2, [x1, #8]
	ldr x4, [x1, x3]
	ldr x5, [x1, x3, lsl #3]

	// exp_2, pre-index mode and post-index mode.
	mov x0, 0x80000
	mov x3, 0x80000
	ldr x0, [x1, #8]	  // x0 should be 0x80008's value, x1 should be 0x80000
	ldr x0, [x1, #8]!	  // x0 should be 0x80008's value, x1 should be 0x80008, pre-index mode.
	ldr x2, [x3],#8		  // x2 should be 0x80000's value, x3 should be 0x80008, post-index mode.

	ret
