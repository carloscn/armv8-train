
void test_memcpy(void)
{
    unsigned long src_addr = 0x80000, dest_addr = 0x200000;
    unsigned long sz = 32;

    asm volatile (
    "       mov x6, %x[_src_addr]\n"
    "       mov x7, %x[_dest_addr]\n"
    "       add x8, x6, %x[_sz]\n"
    "   1:  ldr x9, [x6], #8\n"
    "       str x9, [x7], #8\n"
    "       cmp x6, x8\n"
    "       b.cc 1b\n"
    :
    : [_src_addr] "r" (src_addr), [_dest_addr] "r" (dest_addr), [_sz] "r" (sz)
    : "cc", "memory"
    );
}

void test_memset(void)
{
    unsigned long addr = 0x80000;
    unsigned long sz = 16;
    unsigned long i = 0;

    asm volatile (
    "       mov x4, #0\n"
    "   1:  stp %x[_count], %x[_count], [%x[_addr]], #16\n"
    "       add %x[_sz], %x[_sz], #16\n"
    "       cmp %x[_sz], %x[_addr]\n"
    "       bne 1b\n"
    : [_addr] "+r" (addr), [_sz] "+r" (sz), [_count] "+r" (i)
    :
    : "memory"
    );
}

#define MY_OPS(ops, asm_ops)                                        \
static inline void my_asm_##ops(unsigned long mask, void *p) {      \
    unsigned long tmp;                                              \
    asm volatile (                                                  \
        "       ldr %1, [%0]\n"                                     \
        "       "#asm_ops" %1, %1, %2\n"                            \
        "       str %1, [%0]\n"                                     \
        : "+r" (p), "+r" (tmp)                                      \
        : "r" (mask)                                                \
        : "memory"                                                  \
    );                                                              \
}

MY_OPS(or, orr)
MY_OPS(and, and)
MY_OPS(andnot, bic)