#define PBASE           0xFE000000
#define U_BASE          (PBASE+0x00201000)
#define U_DATA_REG      (U_BASE)
#define U_FR_REG        (U_BASE+0x18)
#define U_IBRD_REG      (U_BASE+0x24)
#define U_FBRD_REG      (U_BASE+0x28)
#define U_LCRH_REG      (U_BASE+0x2C)
#define U_CR_REG        (U_BASE+0x30)
#define U_IMSC_REG      (U_BASE+0x38)
#define GPFSEL1         (PBASE+0x00200004)
#define GPSET0          (PBASE+0x0020001C)
#define GPCLR0          (PBASE+0x00200028)
#define GPPUD           (PBASE+0x00200094)
#define GPPUDCLK0       (PBASE+0x00200098)
#define GPIO_PUP_PDN_CNTRL_REG0 (PBASE+0x002000E4)

.align 2
.global asm_uart_recv
.global asm_uart_send

asm_uart_send:
    ldr x1, =U_FR_REG               // load FR register address.
    ldr x1, [x1]                    // load address content to x2
    mov x2, #0x01
    and x2, x1, x2, lsl #5          //  get TXFF bit flag.
    cmp x2, #0x0
    b.gt asm_uart_send
    ldr x1, =U_DATA_REG
    str x0, [x1]
    ret

asm_uart_recv:
    ldr x1, =U_FR_REG
    ldr x1, [x1]
    mov x2, #0x01
    and x2, x1, x2, lsl #4
    cmp x2, #0x0
    b.gt asm_uart_recv
    ldr x1, =U_DATA_REG
    ldr x0, [x1]
    and x0, x0, #0xFF