start:
	bochs -f ../config/bochsrc

make_bin:mbr.S
	nasm mbr.S -I include/ -o ../bin/mbr.bin
	nasm loader.S -I include/ -o ../bin/loader.bin
	ls -l ../bin/

write_bin:../bin/mbr.bin ../bin/loader.bin ../img/hd60.img
	dd if=../bin/mbr.bin of=../img/hd60.img bs=512 count=1 conv=notrunc
	dd if=../bin/loader.bin of=../img/hd60.img bs=512 count=4 seek=2 conv=notrunc
	
