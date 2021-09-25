#include "print.h"
#include "init.h"
#include "thread.h"
#include "interrupt.h"
#include "console.h"

void k_thread_a(void *);
void k_thread_b(void *);

int main(void)
{
    put_str("\nI am kernel\n");
    init_all();

    // clear_screen_row(5);

    thread_start("a_thread_k", 32, k_thread_a, "argA ");
    thread_start("b_thread_k", 10000, k_thread_b, "argB ");
    clear_screen();
    intr_enable(); // 打开中断,使时钟中断起作用
    int i = 0;
    while (1)
    {
        intr_disable();
        put_char('M');
        intr_enable();
        // i > 60000 ? i = 0 : i++;
        // console_put_int_pos(i, 0, 0);
        // console_put_char('m');
    };
    return 0;
}

/* 在线程中运行的函数 */
void k_thread_a(void *arg)
{
    /* 用void*来通用表示参数,被调用的函数知道自己需要什么类型的参数,自己转换再用 */
    char *para = arg;
    int i = 0;
    while (1)
    {
        intr_disable();
        put_char('a');
        intr_enable();
        // console_put_int_pos(i, 2, 0);
        // i > 60000 ? i = 0 : i++;
    }
}

/* 在线程中运行的函数 */
void k_thread_b(void *arg)
{
    /* 用void*来通用表示参数,被调用的函数知道自己需要什么类型的参数,自己转换再用 */
    char *para = arg;
    // int i = 0;
    while (1)
    {
        intr_disable();
        put_char('b');
        intr_enable();
        // console_put_int_pos(i, 4, 0);
        // console_put_char('b');
        // i > 60000 ? i = 0 : i++;
    }
}
