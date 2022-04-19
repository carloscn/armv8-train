


static int s0(void) {
    return 0;
}

static int s1(void) {
    return s0();
}

static int s2(void) {
    return s1();
}
static int s3(void) {
    return s2();
}
static int s4(void) {
    return s3();
}
static int s5(void) {
    return s4();
}
static int s6(void) {
    return s5();
}
static int s7(void) {
    return s6();
}
static int s8(void) {
    return s7();
}
static int s9(void) {
    return s8();
}
static int s10(void){
    return s9();
}

static int s11( long a1,
                char a2,
                int a3,
                int a4,
                int a5,
                int a6,
                int a7,
                int a8,
                int a9,
                int a10
                )
{
    return  \
    a1 +    \
    a2 +    \
    a3 +    \
    a4 +    \
    a5 +    \
    a6 +    \
    a7 +    \
    a8 +    \
    a9 +    \
    a10;
}

int call_stack(void) {
    int a = 0;
    int c = 8;
    //a = s11(1,2,3,4,5,6,7,8,9,10);
    c = s10();

    return a + c;
}