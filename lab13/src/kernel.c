#include "uart.h"
#include "sysregs.h"
#include "io.h"

#define  __u64  unsigned long
#define  u64 	__u64

#define HZ 250
#define NSEC_PER_SEC    1000000000L

static unsigned int val = NSEC_PER_SEC / HZ;

extern void timer_ps0_init(void);
extern void timer_ps0_enable(void);
extern void timer_ps0_set_value(int val);
extern void arch_enable_daif();
extern int call_stack(void);

struct user_pt_regs {
	__u64		regs[31];
	__u64		sp;
	__u64		pc;
	__u64		pstate;
};

#define read_sysreg(reg) ({ \
		unsigned long _val; \
		asm volatile("mrs %0," #reg \
		: "=r"(_val)); \
		_val; \
})

#define write_sysreg(val, reg) ({ \
		unsigned long _val = (unsigned long)val; \
		asm volatile("msr " #reg ", %x0" \
		:: "rZ"(_val)); \
})

static const char * const bad_mode_handler[] = {
	"Sync Abort",
	"IRQ",
	"FIQ",
	"SError"
};

void bad_mode(struct pt_regs *regs, int reason, unsigned int esr)
{
	printk("Bad mode for %s handler detected, far:0x%x esr:0x%x\n",
			bad_mode_handler[reason], read_sysreg(far_el1),
			esr);
}

// IRQ_SOURCE0_REG_ADDR
void irq_handle(void)
{
	unsigned int irq = 0;
	unsigned int regs = IRQ_SOURCE0_REG_ADDR;

	irq = readl(IRQ_SOURCE0_REG_ADDR);
	switch (irq) {
		case (CNT_PNS_IRQ):
		handle_timer_irq(100);
		break;

		default:
		printk("Unkown IRQ 0x%x\n", irq);
		break;
	}
}

void handle_timer_irq(unsigned int val)
{
	timer_ps0_set_value(val);
	printk("Core0 timer interrupt recved\n\r");
}

// load_image /Users/carlos/workspace/work/armv8-train/lab12/benos.bin 0x80000

void kernel_main(void)
{
	// uart_init();
	// init_printk_done();
	// printk("call : timer_ps0_init\n");
	// timer_ps0_init();
	// printk("call timer_ps0_setvalue\n");
	// timer_ps0_set_value(val);
	// printk("call timer_ps0_enable\n");
	// timer_ps0_enable();
	// printk("enable daif\n");
	// //arch_enable_daif();
	// printk("wait for interrupt\n");
	call_stack();
	while (1) {
		//uart_send(uart_recv());
	}
}