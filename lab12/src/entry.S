/*
| `VBAR_ELn + 0x000` | Synchronous    | Current EL with SP0 |
| `+ 0x080`          | IRQ/vIRQ       | Current EL with SP0 |
| `+ 0x100`          | FIQ/vFIQ       | Current EL with SP0 |
| `+ 0x180`          | SError/vSError | Current EL with SP0 |
 */
#define BAD_SYNC 0
#define BAD_IRQ 1
#define BAD_FIQ 2
#define BAD_ERROR 3

//.global user_str0
// .align 3
// user_str0:
//     .string "entry.S: join inv_entry \n"
/*
 * inv_entry el, reason
 */
    .macro	inv_entry el, reason
	//adrp x0, user_str0
	//add x0, x0, :lo12:user_str0
	//bl put_string_uart
    mov x0, SP
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
/*
| Current EL with SP0
| ------------------ | -------------- | ---------------------- |
| `VBAR_ELn + 0x000` | Synchronous    | Current EL with SP0    |
| `+ 0x080`          | IRQ/vIRQ       | Current EL with SP0    |
| `+ 0x100`          | FIQ/vFIQ       | Current EL with SP0    |
| `+ 0x180`          | SError/vSError | Current EL with SP0    |
| ------------------ | -------------- | ---------------------- |
 */
    vtentry el1_sync_invalid
    vtentry el1_irq_invalid
    vtentry el1_fiq_invalid
    vtentry el1_error_invalid
 /*
| Current EL with SPx
| ------------------ | -------------- | ---------------------- |
| `+ 0x200`          | Synchronous    | Current EL with SPx    |
| `+ 0x280`          | IRQ/vIRQ       | Current EL with SPx    |
| `+ 0x300`          | FIQ/vFIQ       | Current EL with SPx    |
| `+ 0x380`          | SError/vSError | Current EL with SPx    |
| ------------------ | -------------- | ---------------------- |
  */
    vtentry el1_sync_invalid
    vtentry el1_irq_invalid
    vtentry el1_fiq_invalid
    vtentry el1_error_invalid
/*
| Lower EL using AArch64
| ------------------ | -------------- | ---------------------- |
| `+ 0x400`          | Synchronous    | Lower EL using AArch64 |
| `+ 0x480`          | IRQ/vIRQ       | Lower EL using AArch64 |
| `+ 0x500`          | FIQ/vFIQ       | Lower EL using AArch64 |
| `+ 0x580`          | SError/vSError | Lower EL using AArch64 |
| ------------------ | -------------- | ---------------------- |
 */
    vtentry el0_sync_invalid
    vtentry el0_irq_invalid
    vtentry el0_fiq_invalid
    vtentry el0_error_invalid
/*
| Lower EL using AArch32
| ------------------ | -------------- | ---------------------- |
| `+ 0x600`          | Synchronous    | Lower EL using AArch32 |
| `+ 0x680`          | IRQ/vIRQ       | Lower EL using AArch32 |
| `+ 0x700`          | FIQ/vFIQ       | Lower EL using AArch32 |
| `+ 0x780`          | SError/vSError | Lower EL using AArch32 |
| ------------------ | -------------- | ---------------------- |
 */
    vtentry el0_sync_invalid
    vtentry el0_irq_invalid
    vtentry el0_fiq_invalid
    vtentry el0_error_invalid

el1_sync_invalid:
    inv_entry 1, BAD_SYNC
el1_irq_invalid:
    inv_entry 1, BAD_IRQ
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

/* make 2 byte bias */
string_test:
    .string "t001"

.global assert_alignment
assert_alignment:
    ldr x0, =0x80002
    ldr x1, [x0]
    ret