#include "uart.h"

extern void test_memcpy(void);
extern void test_memset(void);

void kernel_main(void)
{
	uart_init();
	uart_send_string("Welcome BenOS!\r\n");
	/* my test*/
	test_memcpy();
	while (1) {
		uart_send(uart_recv());
	}
}
