kernel:main.c
	gcc -m32 -c -o ../obj/main.o main.c
	ld ../obj/main.o -m elf_i386 -Ttext 0xc0001500 -e main -o ../bin/kernel.bin
	dd if=../bin/kernel.bin of=../img/hd60.img bs=512 count=200 seek=9 conv=notrunc
	bochs -f ../config/bochsrc
