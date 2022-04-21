
#define BAD_SYNC 0
#define BAD_IRQ 1
#define BAD_FIQ 2
#define BAD_ERROR 3
#define PT_REGS_SIZE 272
#define S_X0 0
#define S_X1 8
#define S_X2 16
#define S_X3 24
#define S_X4 32
#define S_X5 40
#define S_X6 48
#define S_X7 56
#define S_X8 64
#define S_X9 72
#define S_X10 80
#define S_X11 88
#define S_X12 96
#define S_X13 104
#define S_X14 112
#define S_X15 120
#define S_X16 128
#define S_X17 136
#define S_X18 144
#define S_X19 152
#define S_X20 160
#define S_X21 168
#define S_X22 176
#define S_X23 184
#define S_X24 192
#define S_X25 200
#define S_X26 208
#define S_X27 216
#define S_X28 224
#define S_FR 232
#define S_LR 240
#define S_SP 248
#define S_PC 256
#define S_PSTATE 264

/*
 * kernel_entry
 */
    .macro kernel_entry
    sub sp, sp, #PT_REGS_SIZE
    /* 1. backup the x0-x29 to pt_regs->x[0..29]*/
    stp x0, x1, [sp, #16 * 0]
    stp x2, x3, [sp, #16 * 1]
    stp x4, x5, [sp, #16 * 2]
    stp x6, x7, [sp, #16 * 3]
    stp x8, x9, [sp, #16 * 4]
    stp x10, x11, [sp, #16 * 5]
    stp x12, x13, [sp, #16 * 6]
    stp x14, x15, [sp, #16 * 7]
    stp x16, x17, [sp, #16 * 8]
    stp x18, x19, [sp, #16 * 9]
    stp x20, x21, [sp, #16 * 10]
    stp x22, x23, [sp, #16 * 11]
    stp x24, x25, [sp, #16 * 12]
    stp x26, x27, [sp, #16 * 13]
    stp x28, x29, [sp, #16 * 14]

    /* 2. read sp/elr_el1/spsr_el1 */
    add x21, sp, #PT_REGS_SIZE
    mrs x22, elr_el1
    mrs x23, spsr_el1

    /* 3. save lr, sp, elr_el1, spsr_el1 to stack */
    stp lr, x21, [sp, #S_LR]
    stp x22, x23, [sp, #S_PC]
    .endm

    .macro kernel_exit
    ldp x21, x22, [sp, #S_PC]
    msr elr_el1, x21
    msr spsr_el1, x22

    ldp x0, x1, [sp, #16 * 0]
    ldp x2, x3, [sp, #16 * 1]
    ldp x4, x5, [sp, #16 * 2]
    ldp x6, x7, [sp, #16 * 3]
    ldp x8, x9, [sp, #16 * 4]
    ldp x10, x11, [sp, #16 * 5]
    ldp x12, x13, [sp, #16 * 6]
    ldp x14, x15, [sp, #16 * 7]
    ldp x16, x17, [sp, #16 * 8]
    ldp x18, x19, [sp, #16 * 9]
    ldp x20, x21, [sp, #16 * 10]
    ldp x22, x23, [sp, #16 * 11]
    ldp x24, x25, [sp, #16 * 12]
    ldp x26, x27, [sp, #16 * 13]
    ldp x28, x29, [sp, #16 * 14]

    ldr lr, [sp, #S_LR]
    add sp, sp, #PT_REGS_SIZE
    eret
    .endm

    .macro inv_entry el, reason
    mov x0, sp
    mov x1, #\reason
    mrs x2, ESR_EL1
    b bad_mode
    .endm

/*
 * vector_table entry label
 */
    .macro	vtentry label
    .align 7
    b \label
    .endm

/*
| ------------------ | -------------- | ---------------------- |
| `VBAR_ELn + 0x000` | Synchronous    | Current EL with SP0    |
| `+ 0x080`          | IRQ/vIRQ       | Current EL with SP0    |
| `+ 0x100`          | FIQ/vFIQ       | Current EL with SP0    |
| `+ 0x180`          | SError/vSError | Current EL with SP0    |
| ------------------ | -------------- | ---------------------- |
| `+ 0x200`          | Synchronous    | Current EL with SPx    |
| `+ 0x280`          | IRQ/vIRQ       | Current EL with SPx    |
| `+ 0x300`          | FIQ/vFIQ       | Current EL with SPx    |
| `+ 0x380`          | SError/vSError | Current EL with SPx    |
| ------------------ | -------------- | ---------------------- |
| `+ 0x400`          | Synchronous    | Lower EL using AArch64 |
| `+ 0x480`          | IRQ/vIRQ       | Lower EL using AArch64 |
| `+ 0x500`          | FIQ/vFIQ       | Lower EL using AArch64 |
| `+ 0x580`          | SError/vSError | Lower EL using AArch64 |
| ------------------ | -------------- | ---------------------- |
| `+ 0x600`          | Synchronous    | Lower EL using AArch32 |
| `+ 0x680`          | IRQ/vIRQ       | Lower EL using AArch32 |
| `+ 0x700`          | FIQ/vFIQ       | Lower EL using AArch32 |
| `+ 0x780`          | SError/vSError | Lower EL using AArch32 |
| ------------------ | -------------- | ---------------------- |
 */
.align 11
.global vectors
vectors:

    vtentry el1_sync_invalid
    vtentry el1_irq_invalid
    vtentry el1_fiq_invalid
    vtentry el1_error_invalid

    vtentry el1_sync_invalid
    vtentry el1_irq
    vtentry el1_fiq_invalid
    vtentry el1_error_invalid

    vtentry el0_sync_invalid
    vtentry el0_irq_invalid
    vtentry el0_fiq_invalid
    vtentry el0_error_invalid

    vtentry el0_sync_invalid
    vtentry el0_irq_invalid
    vtentry el0_fiq_invalid
    vtentry el0_error_invalid

el1_sync_invalid:
	//inv_entry 1, BAD_SYNC
	kernel_entry
	mov x0, sp
	mov x1, 0
	mrs x2, esr_el1
	bl bad_mode
	kernel_exit

el1_irq_invalid:
	inv_entry 1, BAD_IRQ
el1_irq:
    kernel_entry
    bl irq_handle
    kernel_exit

el1_fiq_invalid:
    inv_entry 1, BAD_FIQ
el1_error_invalid:
    inv_entry 1, BAD_ERROR
el0_sync_invalid:
    inv_entry 0, BAD_SYNC
el0_irq_invalid:
    inv_entry 0, BAD_IRQ
el0_fiq_invalid:
    inv_entry 0, BAD_FIQ
el0_error_invalid:
    inv_entry 0, BAD_ERROR
