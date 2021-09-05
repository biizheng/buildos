run: mbr.bin of
	bochs -f ./config/bochsrc.disk.properties -rc ./config/run.cfg

run-gui: mbr.bin of
	bochs -f ./config/bochsrc.gui.properties -rc ./config/run.cfg

mbr.bin:
	@nasm -o ./bin/mbr.bin ./src/boot/mbr.S -I ./src/boot -l ./bin/mbr.lst
	@ls -lh ./bin/mbr.bin
# 	换行
	@echo "========================================================================"

loader.bin:
	@nasm -o ./bin/loader.bin ./src/boot/loader.S -I ./src/boot -l ./bin/loader.lst
	@ls -lh ./bin/loader.bin
# 	换行
	@echo "========================================================================"

kernel.bin:
	@nasm -f elf -o ./bin/print.o ./src/lib/kernel/print.S
	@gcc -m32 -c -I ./src/lib/kernel/ -o ./bin/main_32.o ./src/kernel/main.c
# 	添加待链接文件时，最好保持调用在前，实现在后的书写顺序
	@ld -m elf_i386 ./bin/main_32.o ./bin/print.o -Ttext 0xc0001500 -e main \
	-o ./bin/kernel.bin
	@ls -lh ./bin/kernel.bin
# 	换行
	@echo "========================================================================"

of:	mbr.bin loader.bin kernel.bin
	@dd if=./bin/mbr.bin of=./bin/hd60M.img bs=512 count=1 conv=notrunc
	@dd if=./bin/loader.bin of=./bin/hd60M.img bs=512 count=5 seek=2 conv=notrunc
	@dd if=./bin/kernel.bin of=./bin/hd60M.img bs=512 count=200 seek=9 conv=notrunc
	@echo "========================================================================"

