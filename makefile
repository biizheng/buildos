build = ./build
config = ./config
src=./src

boot = $(src)/boot
include = $(src)/include
kernel = $(src)/kernel
lib = $(src)/lib

lib_kernel = $(lib)/kernel

bin = $(build)/bin
log = $(build)/log
lst = $(build)/lst
obj = $(build)/obj

clean:
	@rm $(obj)/*.o
	@rm $(bin)/*.bin
	@rm $(lst)/*.lst

run: mbr.bin of
	@bochs -f $(config)/bochsrc.disk.properties -rc $(config)/run.cfg

run-gui: mbr.bin of
	@bochs -f $(config)/bochsrc.gui.properties -rc $(config)/run.cfg

mbr.bin:
	@nasm -o $(bin)/mbr.bin $(boot)/mbr.S -I $(boot)/include -l $(bin)/mbr.lst
	@ls -lh $(bin)/mbr.bin
# 	换行
	@echo "========================================================================"

loader.bin:
	@nasm -o $(bin)/loader.bin $(boot)/loader.S -I $(boot)/include -l $(lst)/loader.lst
	@ls -lh $(bin)/loader.bin
# 	换行
	@echo "========================================================================"

main_32.o:
	@gcc -m32 -c -fno-builtin -fno-stack-protector -I $(lib_kernel)  -I $(lib) -I $(kernel)  \
	-o $(obj)/main_32.o ./src/kernel/main.c

print.o:
	@nasm -f elf -o $(obj)/print.o $(lib_kernel)/print.S

kernel.o:
	@nasm -f elf -o $(obj)/kernel.o $(kernel)/kernel.S

interrupt.o:
	@gcc -m32 -c -fno-builtin -fno-stack-protector -I $(lib_kernel) -I $(lib) -I $(kernel) \
	-o $(obj)/interrupt.o \
	$(kernel)/interrupt.c

init.o:
	@gcc -m32 -c -fno-builtin -fno-stack-protector -I $(lib_kernel) -I $(lib) -I $(kernel) \
	-o $(obj)/init.o \
	$(kernel)/init.c

kernel.bin: main_32.o print.o kernel.o interrupt.o init.o
# 	添加待链接文件时，最好保持调用在前，实现在后的书写顺序
	@ld -m elf_i386 -Ttext 0xc0001500 -e main \
	-o $(bin)/kernel.bin \
	$(obj)/main_32.o $(obj)/print.o $(obj)/kernel.o $(obj)/interrupt.o \
	$(obj)/init.o

	@ls -lh $(bin)/kernel.bin
# 	换行
	@echo "========================================================================"

of:	mbr.bin loader.bin kernel.bin
	@dd if=$(bin)/mbr.bin of=$(build)/hd60M.img bs=512 count=1 conv=notrunc
	@dd if=$(bin)/loader.bin of=$(build)/hd60M.img bs=512 count=5 seek=2 conv=notrunc
	@dd if=$(bin)/kernel.bin of=$(build)/hd60M.img bs=512 count=200 seek=9 conv=notrunc
	@echo "========================================================================"

