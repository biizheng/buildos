build = ./build
config = ./config
src=./src

boot = $(src)/boot
device = $(src)/device
include = $(src)/include
kernel = $(src)/kernel
lib = $(src)/lib

lib_kernel = $(lib)/kernel

bin = $(build)/bin
log = $(build)/log
lst = $(build)/lst
obj = $(build)/obj

INCLUDE = -I $(kernel) -I $(lib_kernel) -I $(device) -I $(lib) 
CFLAGS = -m32 -c -fno-builtin -fno-stack-protector

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
	@nasm -o $(bin)/mbr.bin $(boot)/mbr.S -I $(boot)/include -l $(bin)/mbr.lst

loader.bin:
	@nasm -o $(bin)/loader.bin $(boot)/loader.S -I $(boot)/include -l $(lst)/loader.lst

print.o:
	@nasm -f elf -o $(obj)/print.o $(lib_kernel)/print.S

kernel.o:
	@nasm -f elf -o $(obj)/kernel.o $(kernel)/kernel.S

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

timer.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/timer.o $(device)/timer.c

debug.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/debug.o $(kernel)/debug.c

string.o:
	@gcc $(CFLAGS) $(INCLUDE) -o $(obj)/string.o $(lib)/string.c

kernel.bin: main_32.o print.o kernel.o interrupt.o init.o timer.o debug.o string.o
#	添加待链接文件时，最好保持调用在前，实现在后的书写顺序
	@ld -m elf_i386 -Ttext 0xc0001500 -e main \
	-o $(bin)/kernel.bin \
	$(obj)/main_32.o $(obj)/string.o $(obj)/debug.o $(obj)/init.o  $(obj)/interrupt.o $(obj)/timer.o \
	$(obj)/kernel.o $(obj)/print.o 

	@ls -lh $(bin)/kernel.bin
# 	换行
	@echo "========================================================================"

of:	mbr.bin loader.bin kernel.bin
	@dd if=$(bin)/mbr.bin of=$(build)/hd60M.img bs=512 count=1 conv=notrunc
	@dd if=$(bin)/loader.bin of=$(build)/hd60M.img bs=512 count=5 seek=2 conv=notrunc
	@dd if=$(bin)/kernel.bin of=$(build)/hd60M.img bs=512 count=200 seek=9 conv=notrunc
	@echo "========================================================================"

