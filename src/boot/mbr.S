;主引导程序 
;------------------------------------------------------------
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

; 清屏 利用0x06号功能，上卷全部行，则可清屏。
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0           ; 左上角: (0, 0)
    mov dx, 0x184f      ; 右下角: (80,25),
    int 0x10            ; int 0x10

;  获取光标位置
;  output:  ch=光标开始行,cl=光标结束行
;           dh=光标所在行号,dl=光标所在列号
    mov ah, 3
    mov bh, 0
    int 0x10

;打印字符串
    mov ax, message 
    mov bp, ax
    mov cx, 5 
    mov ax, 0x1301
    mov bx, 0x2
    int 0x10    

    mov eax,LOADER_START_SECTOR	;address of start sector
    mov bx,LOADER_BASE_ADDR
    mov cx,4					;number of sector to be read

    call rd_disk_m_16
    jmp LOADER_BASE_ADDR + 0x300

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
    shr eax,cl    ;shift logical right 8 bit
    mov dx,0x1f4
    out dx,al

    shr eax,cl
    mov dx,0x1f5
    out dx,al

    shr eax,cl
    and al,0x0f    ;LBA addr 24bit ~27bit
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
    
    message db "1 MBR"
    times 510-($-$$) db 0
    db 0x55,0xaa

