#include "uart.h"

extern int my_test_data;
extern void test_adr(void);
extern int my_atomic_write(int x);

void kernel_main(void)
{
	int ret = 0;

	uart_init();
	uart_send_string("start test!\r\n");
	ret = my_test_data;
	my_atomic_write(0x34);
	ret = my_test_data;
	if (ret == 0x34) {
		uart_send_string("pass test!\r\n");
	}
	uart_send_string("end test!\r\n");
	while (1) {
		uart_send(uart_recv());
	}
}
