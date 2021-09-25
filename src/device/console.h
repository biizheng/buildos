#ifndef __DEVICE_CONSOLE_H
#define __DEVICE_CONSOLE_H
#include "stdint.h"
void console_init(void);
void console_acquire(void);
void console_release(void);

void console_put_str(char *str);

void console_put_char(uint8_t char_asci);
void console_put_char_lpos(uint8_t char_asci, uint32_t l_pos);
void console_put_char_pos(uint8_t char_asci, uint32_t x, uint32_t y);

void console_put_int(uint32_t num);
void console_put_int_pos(uint32_t num, uint32_t x, uint32_t y);

void clear_screen();
void clear_screen_row(uint32_t row);
#endif
