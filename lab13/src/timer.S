#include "sysregs.h"

.global timer_ps0_init
.global timer_ps0_enable
.global timer_ps0_set_value
.global arch_enable_daif


/*
void timer_ps0_init(void);
void timer_ps0_enable(void);
void timer_ps0_set_value(int val);
 */

.align 3

arch_enable_daif:
	msr	daifclr, #2
    ret

timer_ps0_set_value:
    //mov x10, x30
    msr cntp_tval_el0, x0
    //mov x30, x10
    ret

timer_ps0_enable:
    //mov x10, x30
    ldr x4, =TIMER_CNTRL0_REG_ADDR
    mov x5, #1
    str x5, [x4]
    ldr x6, [x4]
    //mov x30, x10
    ret
/*
 * > timer_ps0_init:
 * 1. config CNTP_CTRL_EL0 bit[0],en; bit[1],dis;
 * 2. config set init value to CNTP_TVAL_EL0
 * 3. config TIMER_CNTRLx bit[0],en;
 * 4. enbale PSTATE DAIF.
 */
timer_ps0_init:

    ldr x5, =CNTP_CTRL_EL0_TIMER_EN
    msr cntp_ctl_el0, x5

    ret