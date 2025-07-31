[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10
    
    mov ah, 0x02
    mov bh, 0
    mov dx, 0x0202
    int 0x10
    
    mov si, logo
    call print_colored
    
    mov si, os_info
    call print_line
    
    mov si, version_info  
    call print_line
    
    mov si, cpu_info
    call print_line
    
    mov si, gpu_info
    call print_line
    
    mov si, memory_info
    call print_line
    
    mov si, colors_header
    call print_line
    call show_colors
    
    mov si, press_key
    call print_line
    
    mov ah, 0
    int 0x16
    
    ret

print_colored:
    pusha
    mov bl, 0x0A  
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp .loop
.done:
    call newline
    popa
    ret

print_line:
    pusha
    mov bl, 0x07  
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp .loop
.done:
    call newline
    popa
    ret

show_colors:
    pusha
    mov cx, 16    
    mov bl, 0     
    
.color_loop:
    push cx
    push bx
    
    mov al, bl
    add al, '0'
    cmp al, '9'
    jle .print_digit
    add al, 7     
.print_digit:
    mov ah, 0x0e
    int 0x10
    
    mov cx, 3
.space_loop:
    mov al, ' '
    mov ah, 0x09
    int 0x10
    loop .space_loop
    
    mov al, ' '
    mov ah, 0x0e
    mov bl, 0x07
    int 0x10
    
    pop bx
    pop cx
    inc bl
    loop .color_loop
    
    call newline
    call newline
    popa
    ret

newline:
    pusha
    mov al, 13
    mov ah, 0x0e
    int 0x10
    mov al, 10
    int 0x10
    popa
    ret

logo:        db '.                        ', 13, 10
             db '    _   _       ___  ____', 13, 10
             db '   | \ | |     / _ \/ ___|', 13, 10  
             db '   |  \| |    | | | \___ \', 13, 10
             db '   | |\  |    | |_| |___) |', 13, 10
             db '   |_| \_|     \___/|____/', 13, 10, 0

os_info:     db 'FS: Cirno Fumo File System', 0
version_info: db 'Version: 1.0 (July 2025)', 0
cpu_info:    db 'CPU: x86 Compatible', 0
gpu_info:    db 'GPU: VGA Compatible', 0 
memory_info: db 'Memory: Real Mode (< 1MB)', 0
colors_header: db 'Available Colors:', 0
press_key:   db 'Press any key to return...', 0

times 512-($-$$) db 0
