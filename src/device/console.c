#include "console.h"
#include "print.h"
#include "stdint.h"
#include "sync.h"
#include "thread.h"
#include "interrupt.h"
static struct lock console_lock; // 控制台锁

/* 初始化终端 */
void console_init()
{
    lock_init(&console_lock);
}

/* 获取终端 */
void console_acquire()
{
    lock_acquire(&console_lock);
}

/* 释放终端 */
void console_release()
{
    lock_release(&console_lock);
}

/* 终端中输出字符串 */
void console_put_str(char *str)
{
    console_acquire();
    // put_str(str);
    console_release();
}

/* 终端中输出字符 */
void console_put_char(uint8_t char_asci)
{
    console_acquire();
    put_char(char_asci);
    console_release();
}

/* linear position */
void console_put_char_lpos(uint8_t char_asci, uint32_t l_pos)
{
    console_acquire();
    set_cursor(l_pos);
    put_char(char_asci);
    console_release();
}

/* 终端中输出字符 */
void console_put_char_pos(uint8_t char_asci, uint32_t x, uint32_t y)
{
    console_acquire();
    set_cursor(x * 80 + y);
    put_char(char_asci);
    console_release();
}

/* 终端中输出16进制整数 */
void console_put_int(uint32_t num)
{
    console_acquire();
    put_int(num);
    console_release();
}

/* 终端中输出16进制整数 */
void console_put_int_pos(uint32_t num, uint32_t x, uint32_t y)
{
    console_acquire();
    // enum intr_status old_status = intr_disable();
    set_cursor(x + y * 80);
    put_int(num);
    console_release();
    // intr_set_status(old_status);
}

void clear_screen()
{
    set_cursor(0);
    int cursor_pos = 0;
    while (cursor_pos < 2000)
    {
        put_char(' ');
        cursor_pos++;
    }
}

// row 指定从第几行开始
void clear_screen_row(uint32_t row)
{
    set_cursor(0);
    int cursor_pos = row * 80;
    while (cursor_pos > 0)
    {
        put_char(' ');
        cursor_pos--;
    }
}
