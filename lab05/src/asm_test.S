.global test_cmn
.global test_cmn_jump
.global test_csel
.global test_bl

test_cmn:

	// test1: cmn x1 > x2
	mov x0, xzr
	msr NZCV, xzr
	mov x1, #-0x01
	mov x2, #-0x0E
	cmn x1, x2
	mrs x0, NZCV   // nzcv = 1010

	// test2: cmn x1 = x2
	mov x0, xzr
	msr NZCV, xzr
	mov x1, #0
	cmn x1, #0
	mrs x0, NZCV	// nzcv = 0100

	// test3: cmn x1 < x2
	mov x0, xzr
	msr NZCV, xzr
	mov x1, #-0x0F
	mov x2, #-0x01
	cmn x1, x2
	mrs x0, NZCV   // nzcv = 1010

	// test4: cmn x1 + x2 > 0 and x1 < 0
	mov x0, xzr
	msr NZCV, xzr
	mov x1, #0x0F
	mov x2, #-0x01
	cmn x1, x2
	mrs x0, NZCV   // nzcv = 0010

	// test5: cmn x1 + x2 < 0 and x2 > 0
	mov x0, xzr
	msr NZCV, xzr
	mov x1, #-0x0F
	mov x2, #0x01
	cmn x1, x2
	mrs x0, NZCV   // nzcv = 1000

	// test6: cmn x1 + x2 = 0
	mov x0, xzr
	msr NZCV, xzr
	mov x1, #-0x01
	mov x2, #0x01
	cmn x1, x2
	mrs x0, NZCV   // nzcv = 0110
	ret

// The test is:
// suppose the x1 = 1, x2 = -3
// Use the `cmn` instruction to compare the x1 and x2
// When the result is neg number, make x2 += 1;
// until the result is zero, then return the function.
test_cmn_jump:

	msr NZCV, xzr
	mov x0, xzr
	mov x1, #0x0
loop:
	add x1, x1, #0x1
	mov x2, #-0x3
	cmn x1, x2		// NZCV = 1000
	mrs x0, NZCV
	b.mi loop

	ret

/*
 * use assembly to implement the c function.
 * unsigned long cel_test(unsigned long a, unsigned long b)
 * {
 * 	if (a == 0) {
 *   	return b + 2;
 * 	} else {
 *   	return b - 1;
 * 	}
 * }
 */
test_csel:

	mov x2, #0x2
	mov x3, #-0x1
	cmp x0, #0
	csel x4, x2, x3, EQ
	add x0, x1, x4
	ret

test_bl:
	mov x8, x30
	mov x0, 1
	mov x1, 3
	bl test_csel
	mov x30, x8
	ret