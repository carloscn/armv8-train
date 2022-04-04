#include "uart.h"

extern unsigned long func_addr[];
extern char func_str[];
extern unsigned long func_num;
extern int add_f(int a, int b, int c);

static int print_func_name(unsigned long addr)
{
	int i = 0;
	char *p, *str;

	for (i = 0; i < func_num; i++) {
		if (addr == func_addr[i]) {
			goto found;
		}
	}
	uart_send_string("not found func\n");

found:
	p = (char *)&func_str;
	while(1) {
		p++;
		if (*p == '\0') {
			i--;
		}
		if (i == 0) {
			p++;
			str = p;
			uart_send_string(str);
			break;
		}
	}
	return 0;
}

void kernel_main(void)
{
	int out;
	uart_init();
	uart_send_string("Welcome BenOS!\r\n");
	print_func_name(0x800880);
	print_func_name(0x800860);
	print_func_name(0x800800);

	out = add_f(1,2, 1);
	if (out == 4) {
		uart_send_string("test add_f 1 pass!\n");
	} else {
		uart_send_string("test add_f 1 fail!\n");
	}
	out = add_f(1,3, 2);
	if (out == 6) {
		uart_send_string("test add_f 2 pass!\n");
	} else {
		uart_send_string("test add_f 2 fail!\n");
	}
	uart_send_string("test finish\n");
	while (1) {
		uart_send(uart_recv());
	}
}
