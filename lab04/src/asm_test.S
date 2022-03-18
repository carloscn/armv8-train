.global addx_test
.global cmp_test
.global cmp_and_return_test
.global ands_return_test
.global test_orr
.global test_eor
.global test_bfi
.global test_ubfx

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

ands_return_test:
	msr NZCV, xzr	   // clear the NZCV
	ldr x1, =0xAA
	ldr x2, =0x0
	// test AND, no Z flag. x1 = x1&x2
	and x1, x1, x2
	mrs x0, NZCV

	// test ANDS, z flag, if the result is 0, Z is 1
	msr NZCV, xzr	   // clear the NZCV
	mov x0, xzr
	ldr x1, =0xAA
	ands x1, x1, x2
	mrs x0, NZCV

	ret

test_orr:
	// ORR test  0xAA oor 0x55 = 0xFF
	//           0xFF oor 0x00 = 0xFF
	//           0xFF oor 0xFF = 0xFF
	//           0x00 oor 0x00 = 0x00
	mov x0, xzr
	mov x1, #0xAA
	mov x2, #0x55
	orr x1, x1, x2

	mov x1, #0xFF
	orr x1, x1, xzr

	mov x1, #0xFF
	orr x1, x1, x1

	orr x1, xzr, xzr

	ret

test_eor:
	// test 2 exchange the value x1 = 0x07, x2 = 0xAA
    // using the orr, just use two register.
	// x1 = x1^x2
	// x2 = x2^x1
	// x1 = x1^x2
	ldr x1, =0x07
	ldr x2, =0xAA
	eor x1, x1, x2
	eor x2, x2, x1
	eor x1, x1, x2
	ret

test_bfi:
	// 0000 0000 0000 1010
	//                 |
	//                 V
	//           0000 0000 0000 0000  ->  0000 1010 0000 0000
	ldr x1, =0x000A
	mov x2, xzr
	bfi x2, x1, #0x8, #0x4

	// 0000 0000 0000 1010
	//                 |
	//                 V
	//           0000 0101 0000 0000  ->  0000 1010 0000 0000
	ldr x1, =0x000A
	mov x2, #0x0500
	bfi x2, x1, #0x8, #0x4

	ret

test_ubfx:
	// x1: 0000 0000 0000 0000  ->  0000 0000 0000 1111
	//                     ^
	//                     |
	// x2:      0000 0000 1111 0000
	mov x1, xzr
	mov x2, #0x00F0
	ubfx x1, x2, #0x4, #0x4

	// x1: 0000 0000 0000 0000  ->  1111 1111 1111 1111
	//                     ^
	//                     |
	//          1000 0000 1111 0000
	mov x1, xzr
	mov x2, #0x80F0
	sbfx x1, x2, #0x4, #0x4

	ret