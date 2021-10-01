build = ./build
config = ./config
src=./src

boot = $(src)/boot
device = $(src)/device
include = $(src)/include
kernel = $(src)/kernel
lib = $(src)/lib
thread = $(src)/thread
userprog = $(src)/userprog

lib_kernel = $(lib)/kernel
lib_usr = $(lib)/usr

bin = $(build)/bin
log = $(build)/log
lst = $(build)/lst
obj = $(build)/obj

INCLUDE = -I $(kernel) -I $(lib_kernel) -I $(device) -I $(lib) -I $(thread) -I $(userprog)
CFLAGS = -m32 -c -fno-builtin -fno-stack-protector -g

clean:
	@rm $(obj)/*.o
	@rm $(bin)/*.bin
	@rm $(lst)/*.lst

run: mbr.bin of
	@bochs -f $(config)/bochsrc.disk.properties -rc $(config)/run.cfg

run-gui: mbr.bin of
	@bochs -f $(config)/bochsrc.gui.properties -rc $(config)/run.cfg

######## 汇编
mbr.bin:
	@nasm -o $(bin)/mbr.bin $(boot)/mbr.S -I $(boot)/include -l $(lst)/mbr.lst

loader.bin:
	@nasm -o $(bin)/loader.bin $(boot)/loader.S -I $(boot)/include -l $(lst)/loader.lst

print.o:
	@nasm -f elf -o $(obj)/print.o $(lib_kernel)/print.S

kernel.o:
	@nasm -f elf -o $(obj)/kernel.o $(kernel)/kernel.S

switch.o:
	@nasm -f elf -o $(obj)/switch.o $(thread)/switch.S

######## gcc
main_32.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/main_32.o $(kernel)/main.c

premain.o:
	@gcc -E $(CFLAGS) $(INCLUDE) -o $(obj)/main_pre_32.c $(kernel)/main.c

compilemain.o:
	@gcc -S $(CFLAGS) $(INCLUDE) -o $(obj)/main_pre_32.asm $(kernel)/main.c

interrupt.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/interrupt.o $(kernel)/interrupt.c

init.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/init.o $(kernel)/init.c

debug.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/debug.o $(kernel)/debug.c

memory.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/memory.o $(kernel)/memory.c

timer.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/timer.o $(device)/timer.c

string.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/string.o $(lib)/string.c

bitmap.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/bitmap.o $(lib_kernel)/bitmap.c

thread.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/thread.o $(thread)/thread.c

list.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/list.o $(lib_kernel)/list.c

syscall.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/syscall.o $(lib_usr)/syscall.c

sync.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/sync.o $(thread)/sync.c

console.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/console.o $(device)/console.c

keyboard.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/keyboard.o $(device)/keyboard.c

ioqueue.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/ioqueue.o $(device)/ioqueue.c

tss.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/tss.o $(userprog)/tss.c

process.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/process.o $(userprog)/process.c

syscall-init.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/syscall-init.o $(userprog)/syscall-init.c

kernel.bin: main_32.o print.o kernel.o interrupt.o init.o timer.o debug.o string.o memory.o bitmap.o thread.o \
switch.o list.o sync.o console.o keyboard.o ioqueue.o tss.o process.o syscall-init.o syscall.o
#	添加待链接文件时，需要尽可能保持调用在前，实现在后的书写顺序，注 main_32.o 必须放到输入文件参数的最前面
	@ld -m elf_i386 -Ttext 0xc0001500 -e main \
	-o $(bin)/kernel.bin \
	$(obj)/main_32.o $(obj)/sync.o $(obj)/syscall-init.o $(obj)/thread.o $(obj)/string.o $(obj)/debug.o \
	$(obj)/init.o $(obj)/list.o $(obj)/syscall.o \
	$(obj)/keyboard.o $(obj)/process.o $(obj)/interrupt.o $(obj)/timer.o $(obj)/tss.o \
	$(obj)/kernel.o $(obj)/print.o $(obj)/memory.o $(obj)/bitmap.o $(obj)/switch.o $(obj)/console.o \
	$(obj)/ioqueue.o

	@ls -lh $(bin)/kernel.bin
# 	换行
	@echo "========================================================================"

of:	mbr.bin loader.bin kernel.bin
	@dd if=$(bin)/mbr.bin of=$(build)/hd60M.img bs=512 count=1 conv=notrunc
	@dd if=$(bin)/loader.bin of=$(build)/hd60M.img bs=512 count=5 seek=2 conv=notrunc
	@dd if=$(bin)/kernel.bin of=$(build)/hd60M.img bs=512 count=400 seek=9 conv=notrunc
	@echo "========================================================================"

dump_kernel:
	objdump -d -l -M intel -S build/bin/kernel.bin > kernel_map.txt
