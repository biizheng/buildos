;Main Boot Record
;-----------------------------------
%include "boot.inc"

SECTION MBR vstart=0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
    mov ax,0xb800
    mov gs,ax

;clear screen 
;by using function 0x06 , wrap all line to clear screen 
;---------------------------------------------------------
;INT 0x10   function code:0x06 description:
;input:
;AH function code=0x60
;AL = lines to wrap(if you set AL with zero it means all  )
;BH = attribute of lines to wrap

	
    mov ax,0x600
    mov bx,0x700
    mov cx,0
    mov dx,0x184f

    int 0x10
    
	
	;output string
	mov byte [gs:0x00],'1'
	mov byte [gs:0x01],0xA4

	mov byte [gs:0x02],' '
	mov byte [gs:0x03],0xA4

	mov byte [gs:0x04],'M'
	mov byte [gs:0x05],0xA4

	mov byte [gs:0x06],'B'
	mov byte [gs:0x07],0xA4

	mov byte [gs:0x08],'R'
	mov byte [gs:0x09],0xA4
	
   	mov eax,LOADER_START_SECTOR	;address of start sector
	mov bx,LOADER_BASE_ADDR
	mov cx,4					;number of sector to be read

	call rd_disk_m_16

	jmp LOADER_BASE_ADDR

;------------------------
;function: read 'n' sectors form disk
rd_disk_m_16:
;eax=LBA sector number
;bx=memory address to write
;cx=sector count to read in


;read disk:
;first:  set sector number to read

	mov esi,eax
	mov di,cx

	mov dx,0x1f2
	mov al,cl
	out dx,al

	mov eax,esi
	
;second put LBA addr into 0x1f3~0x1f6

	;write LBA addr 7~0bit in port 0x1f3
	mov dx,0x1f3
    out dx,al

	;write LBA addr 15~8bit into port 0x1f4
	mov cl,8	
	shr eax,cl	;shift logical right 8 bit
	mov dx,0x1f4
	out dx,al

	shr eax,cl
	mov dx,0x1f5
	out dx,al

	shr eax,cl
	and al,0x0f	;LBA addr 24bit ~27bit
	or al,0xe0
	mov dx,0x1f6
	out dx,al
	
	mov dx,0x1f7
	mov al,0x20
	out dx,al

.not_ready:
	nop
	in al,dx
	and al,0x88

	cmp al,0x08
	jnz .not_ready

	mov ax,di
	mov dx,256
	mul dx
	mov cx,ax

	mov dx,0x1f0
.go_on_read:
	in ax,dx
	mov [bx],ax
	add bx,2
	loop .go_on_read
	ret

    times 510-($-$$) db 0
    db 0x55,0xaa    
