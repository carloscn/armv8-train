#include "uart.h"

extern void test_adr(void);

void kernel_main(void)
{
	unsigned long ret = 0;
	uart_init();
	uart_send_string("start test!\r\n");
	test_adr();
	uart_send_string("end test!\r\n");

	while (1) {
		uart_send(uart_recv());
	}
}
