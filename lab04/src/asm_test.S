.global addx_test
.global cmp_test
.global cmp_and_return_test

addx_test:
	// test add instruction
	mov x1, 0x1
	mov x2, 0x2
	add x3, x1, x2

	// test add with lsb
	mov x0, 0x0
	msr NZCV, x0	   // clear the NZCV
	add x3, x1, x2, lsl #2   // 0000 0001B + ( 0000 0010B << 2) -> 0000 1001 (0x09)
	ldr x1, =0xffffffffffffffff
	mov x2, 0x1
	add x3, x1, x2           // the x3 result is 0, and C = 0
	mrs x0, NZCV       // detail the system register.  NZCV: 0000B

	// test adds, zc flag
	mov x0, 0x0
	msr NZCV, x0	   // clear the NZCV
	mov x1, 0xffffffffffffffff
	mov x2, 0x2
	adds x3, x1, x2     // the x3 result is 1, and C = 0
	mrs x0, NZCV       // detail the system register.  NZCV: 0010B

	mov x0, 0x0
	msr NZCV, x0	   // clear the NZCV
	mov x1, 0xffffffffffffffff
	mov x2, 0x1
	adds x3, x1, x2     // the x3 result is 0, and C = 0
	mrs x0, NZCV       // detail the system register.  NZCV: 0110B

	mov x1, 0x1
	mov x2, 0x2
	adds x3, x1, x2     // the x3 result is 0, adds is x3 = x1 + x2
	mrs x0, NZCV        // detail the system register.  NZCV: 0000B

	// test adcs:
	// Add with Carry, setting flags, adds two register values and the Carry flag value,
	// and writes the result to the destination register.
	// It updates the condition flags based on the result.
	mov x1, 0x1        // 0001
	mov x2, 0x2        // 0010
	mov x0, 0x0
	msr NZCV, x0	   // clear the NZCV
	adcs x3, x1, x2    // the x3 result is 0x3 (0011) [x3 = x1 + x2 + c], the c is 0.
	mrs x0, NZCV       // detail the system register.  NZCV: 0000B
	mov x0, 0x60000000 // let c is 0 on the NZCV.
	msr NZCV, x0       // let c is 0 on the NZCV.
	adcs x3, x1, x2    // the x3 result is 0x4 (0100) [x3 = x1 + x2 + c], the c is 1.
	mrs x0, NZCV

    // test for NZCV
	mov x1, 0xffffffffffffffff
	mov x2, 0x1
	adcs x3, x1, x2    // the x3 result is 0x0 (0000)
	mrs x0, NZCV       // detail the system register.  the NZCV: 0110B

	// test adds
	ret

cmp_test:
	// in fact the cmp is sub instruction
	// a - b < 0: the N flag is enabled, but the C flag is disabled.
	// a - b = 0: the Z flag is enabled.
	// a - b > 0: a + (-b) overflow, so the C is enabled.

	// test 1: a > b
	mov x0, 0x0
	msr NZCV, x0	   // clear the NZCV
	mov x1, 0xf
	mov x2, 0x0
	cmp x1, x2         // x1 > x2: C is 1
	mrs x0, NZCV       // details NZCV 0010

	// test 2: a = b
	mov x0, 0x0
	msr NZCV, x0	   // clear the NZCV
	mov x2, 0xf
	cmp x1, x2         // x1 = x2: C is 1 Z is 1
	mrs x0, NZCV       // NZCV 0110

	// test 3: a < b
	mov x0, 0x0
	msr NZCV, x0	   // clear the NZCV
	mov x1, 0x1
	cmp x1, x2         // x1 = x2: C is 0
	mrs x0, NZCV       // NZCV 1000

cmp_and_return_test:
	// if x0 >= x1, the c shall be 1
	// the sbc is the x1 - x2 - 1 + 1, the result is 0

	// if x0 < x1, the c shall be 0
	// the sbc is the x1 - x2 - 1 + 0, the result is -1
	cmp x0, x1
	sbc x0, xzr, xzr
	sub x0, xzr, x0
	ret