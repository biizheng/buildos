start:
	bochs -f ../config/bochsrc

mbr:mbr.S
	nasm mbr.S -o ../bin/ mbr.bin

writembr:../bin/mbr.bin ../img/hd60.img
	dd if=../bin/mbr.bin of=../img/hd60.img bs=512 count=1 conv=notrunc
