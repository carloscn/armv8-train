#include "uart.h"

extern void init_printk_done(void);
extern int printk(const char *fmt, ...);

void kernel_main(void)
{
	uart_init();
	init_printk_done();
	uart_send_string("Welcome BenOS!\r\n");
	// only using the on EL1
	// printk("heelelkl %d\n", 12);
	uart_send_string("end BenOS!\r\n");
	while (1) {
		uart_send(uart_recv());
	}
}
