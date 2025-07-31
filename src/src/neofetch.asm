[org 0x1000]
[bits 16]

start:
    mov ax,0x0003
    int 0x10

    mov si,logo
    call print_line

    mov si,os_info
    call print_line
    mov si,version_info
    call print_line

    call cpuid_read
    mov si,vendor_str
    call print_string
    mov si,vendor
    call print_line

    call get_memory_info
    mov si,base_mem_label
    call print_string
    mov ax,[base_memory]
    call print_number
    mov si,kb_suffix
    call print_line

    mov si,ext_mem_label
    call print_string
    mov ax,[extended_memory]
    call print_number
    mov si,kb_suffix
    call print_line

    mov si,colors_header
    call print_line
    call show_colors

    mov si,press_key
    call print_line
    mov ah,0
    int 0x16
    ret

cpuid_read:
    xor eax,eax
    db 0x0F,0xA2
    mov [vendor],ebx
    mov [vendor+4],edx
    mov [vendor+8],ecx
    mov byte [vendor+12],0
    ret

get_memory_info:
    int 0x12
    mov [base_memory],ax
    mov ah,0x88
    int 0x15
    mov [extended_memory],ax
    ret

print_string:
    mov ah,0x0E
.loop:
    lodsb
    test al,al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

print_line:
    call print_string
    mov al,13
    mov ah,0x0E
    int 0x10
    mov al,10
    int 0x10
    ret

print_number:
    mov bx,10
    xor cx,cx
.next:
    xor dx,dx
    div bx
    add dl,'0'
    push dx
    inc cx
    cmp ax,0
    jne .next
.print:
    pop dx
    mov ah,0x0E
    mov al,dl
    int 0x10
    dec cx
    jnz .print
    ret

show_colors:
    mov cx,16
    mov ah,0x0E
    mov bh,0
    xor bl,bl
.loopc:
    mov al,bl
    add al,'0'
    cmp al,'9'
    jle .pd
    add al,7
.pd:
    int 0x10
    mov ah,0x09
    mov al,' '
    int 0x10
    mov ah,0x0E
    mov al,' '
    int 0x10
    inc bl
    loop .loopc
    ret

logo          db 'NaOS Boot',0
os_info       db 'FS: Cirno Fumo File System',0
version_info  db 'Version: 1.0 (July 2025)',0
vendor_str    db 'CPU Vendor: ',0
vendor        times 13 db 0
base_mem_label db 'Base Memory: ',0
ext_mem_label  db 'Extended Memory: ',0
kb_suffix     db ' KB',0
colors_header db 'Available Colors:',0
press_key     db 'Press any key...',0

base_memory     dw 0
extended_memory dw 0

times 512-($-$$) db 0
