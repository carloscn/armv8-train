#include "uart.h"

// weak symbol
__attribute__((weak)) int symbol = 1;
__attribute__((weak)) int extern_func(int a, int b);

void kernel_main(void)
{
    static int var_1 = 85;
    static int var_2;
    int c = 6;
    int d;

	uart_init();
	uart_send_string("test weak symbol!\r\n");
    if (extern_func) {
        extern_func(c, d);
        uart_send_string("extern.c: extern_func impl\n");
    } else {
        uart_send_string("no extern_func impl\n");
    }

	while (1) {
		uart_send(uart_recv());
	}
}
