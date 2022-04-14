#include "uart.h"

#define  __u64  unsigned long
#define  u64 	__u64

extern void assert_alignment();

struct user_pt_regs {
	__u64		regs[31];
	__u64		sp;
	__u64		pc;
	__u64		pstate;
};

struct pt_regs {
	union {
		struct user_pt_regs user_regs;
		struct {
			u64 regs[31];
			u64 sp;
			u64 pc;
			u64 pstate;
		};
	};
	u64 orig_x0;
	u64 syscallno;
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

extern void init_printk_done(void);
extern int printk(const char *fmt, ...);

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

void kernel_main(void)
{
	uart_init();
	init_printk_done();
	printk("hello benos %x!\n", 0x12);
	printk("try assert alignment exceptions...\n");
	assert_alignment();
	printk("checking exceptions...\n");
	while (1) {
		uart_send(uart_recv());
	}
}
