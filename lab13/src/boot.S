#include "mm.h"
#include "sysregs.h"
.section ".text.boot"

/*
 * define string of booting at el.
 * map it on .rodata section.
 */
.section .rodata
.align 3
.global el_string1
el_string1:
	.string "Booting at EL"
/*
 * map it on .text.boot section.
 */
.section ".text.boot"
.global _start
_start:
	mrs	x0, mpidr_el1
	and	x0, x0,#0xFF		// Check processor id

	cbz	x0, master			// Hang for all non-primary CPU
	b	proc_hang

proc_hang:
	b 	proc_hang

master:
	/* init uart and print the string */
	bl __init_uart

	/* check current EL */
	mrs x5, CurrentEL
	cmp x5, #CurrentEL_EL3
	b.eq el3_entry
	b el2_entry
	//b el1_entry

el3_entry:
	eret

el2_entry:
	bl print_el

	/* config some registers */
	/* 1. config EL1 is aarch64 execute state */
	ldr x0, =HCR_HOST_NVHE_FLAGS
	msr hcr_el2, x0

	/* 2. config EL1 MMU disable and LEndian on sctlr */
	ldr x0, =SCTLR_VALUE_MMU_DISABLED
	msr sctlr_el1, x0

	/* 3. config EL1 mask DAIF bits on SPSR_EL1 */
	ldr x0, =SPSR_EL1
	msr spsr_el2, x0

	/* 4. point the entry link for el2 */
	adr x0, el1_entry
	msr elr_el2, x0

	eret

el1_entry:
	bl print_el
	/* register the exception vector */
	// adrp x0, el_string3
	// add x0, x0, :lo12:el_string3
	// bl put_string_uart

	ldr x5, =vectors
	msr VBAR_EL1, x5
	isb

	adr	x0, _bss
	adr	x1, _ebss
	sub x1, x1, x0
	bl memzero

	mov sp, #LOW_MEMORY
	bl kernel_main
	b proc_hang

print_el:
	/* back return address */
	mov x10, x30
	adrp x0, el_string1
	add x0, x0, :lo12:el_string1
	bl put_string_uart

	mrs x5, CurrentEL
	/* get the currentEL value */
	lsr x2, x5, #2
	mov x0, #48
	add x0, x0, x2
	bl put_uart
	/* print the new line tab */
	mov x0, #10
	bl put_uart

	mov x30, x10
	ret