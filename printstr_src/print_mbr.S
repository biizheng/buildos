section mbr vstart=0x7c00

	mov ax,cs
	mov ds,ax
	mov ss,ax

	mov sp,0x7c00

	mov ax,0xb800
	mov gs,ax

	mov ax,message
	mov si,ax
	mov di,0

	xor cx,cx
	mov byte cl,str_len
	
print:
	mov al,[si]	
	mov byte [gs:di],al

	inc di
	inc si

	mov byte [gs:di],0x70
	inc di

	loop print


;------------------------

	mov eax,0x2   		;start sector number LBA adddress
	mov bx,loaded_addr	;distinct address
	mov cx,1			;sector count

	call read_disk

	jmp stop_here

;----------------

read_disk:

	push eax
	
	;-----------------------sector counter
	mov dx,0x1f2
	mov al,cl
	out dx,al

	pop eax

	;-------------------------------write LBA addr 0~7
	mov dx,0x1f3
	out dx,al
	
	;----------------------storge cx
	push cx
	mov cl,0x8
	
	;--------------------------------write LBA address 8~15
	shr eax,cl
	mov dx,0x1f4
	out dx,al
	
	;-------------------------write LBA addr 16~23
	shr eax,cl
	mov dx,0x1f5
	out dx,al

	;---------------------write LBA addr 24~27
	shr eax,cl
	and al,0x0f
	or al,0xe0
	mov dx,0x1f6
	out dx,al

	;write read command to 0x1f7 port

	mov dx,0x1f7
	mov al,0x20
	out dx,al

.not_ready:
	nop
	in al,dx
	and al,0x88

	cmp al,0x08
	jnz .not_ready

	pop cx
	mov ax,cx
	mov dx,256
	mul dx
	mov cx,ax


	mov dx,0x1f0

.go_on_read:
	in ax,dx
	mov [bx],ax
	add bx,2

	mov byte [gs:di],'.'
	inc di
	inc di

	loop .go_on_read
	ret
	


stop_here:
	jmp $


message	 db 'master booting record...'
str_len equ $-message

loaded_addr:

times 510-($-$$) db 0
db 0x55,0xaa

