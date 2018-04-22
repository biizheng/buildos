start:
	bochs -f ../config/bochsrc

printstr_loa:../bin/print_mbr.bin ../bin/print_loader.bin ../img/hd60.img
	dd if=../bin/print_mbr.bin of=../img/hd60.img bs=512 count=1 conv=notrunc
	-dd if=../bin/print_loader.bin of=../img/hd60.img bs=512 count=1 seek=2 conv=notrunc

printstr_mbr:print_mbr.S print_loader.S
	nasm print_mbr.S -I ../include/ -o ../bin/print_mbr.bin
	nasm print_loader.S -I ../include/ -o ../bin/print_loader.bin
