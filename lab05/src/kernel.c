#include "uart.h"

extern void test_cmn(void);
extern void test_cmn_jump(void);
extern unsigned long test_csel(unsigned long a, unsigned long b);
extern void test_bl(void);

void kernel_main(void)
{
	unsigned long ret = 0;
	uart_init();
	uart_send_string("start test!\r\n");
	test_cmn();
	test_cmn_jump();
	ret = test_csel(0, 2);
	if (ret == 4) {
		uart_send_string("test pass! 0,2\r\n");
	}
	ret = test_csel(1,5);
	if (ret == 4) {
		uart_send_string("test pass! 1,5\r\n");
	}

	test_bl();
	uart_send_string("end test!\r\n");

	while (1) {
		uart_send(uart_recv());
	}
}
