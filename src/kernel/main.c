#include "print.h"
#include "init.h"
#include "debug.h"
int main(void)
{
    put_char('\n');
    put_str("I am kernel\n");
    put_int(*(uint32_t *)(0xb00));
    put_char('\n');
    init_all();
    while (1)
        ;
    return 0;
}