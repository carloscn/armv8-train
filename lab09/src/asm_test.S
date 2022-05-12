.align 3
.global func_addr
func_addr:
	.quad 0x800800
	.quad 0x800860
	.quad 0x800880

.align 3
.global func_str
func_str:
	.asciz "func_a\n"
	.asciz "func_b\n"
	.asciz "func_c\n"

.align 3
.global func_num
func_num:
	.quad 3


.align 3
add_1:
	add x0, x0, #1
	add x0, x0, x1
	ret

.align 3
add_2:
	add x0, x0, #2
	add x0, x0, x1
	ret

.global add_func
.macro add_func a, b, label
.align 3
	mov x0, \a
	mov x1, \b
	bl add_\()\label
.endm


macro1:
	mov x9, x30
	add_func x0, x1, 1
	mov x30, x9
	ret

macro2:
	mov x9, x30
	add_func x0, x1, 2
	mov x30, x9
	ret

.global add_f
.align 3
add_f:
	mov x9, x30
	cmp x2, 1
	b.eq macro1

	cmp x2, 2
	b.eq macro2

	mov x30, x9
	ret