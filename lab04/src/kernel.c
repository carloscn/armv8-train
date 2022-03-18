#include "uart.h"

extern void addx_test(void);
extern void cmp_test(void);
/*
 * The function cmp_and_return_test:
 * if a >= b return 0
 * if a < b return 1
*/
extern unsigned int cmp_and_return_test(int a, int b);

extern void ands_return_test(void);
extern void test_orr(void);
extern void test_eor(void);
extern void test_bfi(void);
extern void test_ubfx(void);

void kernel_main(void)
{
	uart_init();
	uart_send_string("This is the addx lab!\r\n");
	/* my test*/
	addx_test();
	cmp_test();
	if (cmp_and_return_test(20, 21) == 1) {
		uart_send_string("20,21 the compare result is correct!\r\n");
	} else {
		uart_send_string("20,21 the compare result is wrong!\r\n");
	}
	if (cmp_and_return_test(21, 20) == 0) {
		uart_send_string("20,21 the compare result is correct!\r\n");
	} else {
		uart_send_string("21,20 the compare result is wrong!\r\n");
	}
	if (cmp_and_return_test(20, 20) == 0) {
		uart_send_string("20,21 the compare result is correct!\r\n");
	} else {
		uart_send_string("20,20 the compare result is wrong!\r\n");
	}
	uart_send_string("Test finish, join the loop!\r\n");

	//ands_return_test
	ands_return_test();

	// test orr
	test_orr();
	test_eor();
	test_bfi();
	test_ubfx();

	while (1) {
		uart_send(uart_recv());
	}
}
