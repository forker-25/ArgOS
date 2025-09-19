[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10
    
    mov si, title
    call print_string
    
    call show_text_colors
    
    call show_background_colors
    
    mov si, press_key
    call print_string
    mov ah, 0
    int 0x16
    
    ret

show_text_colors:
    mov si, text_colors_header
    call print_string
    
    mov cx, 16
    mov bl, 0
    
.loop:
    push cx
    push bx
    
    mov ah, 0x09
    mov al, 'A'
    mov bh, 0
    mov cx, 3
    int 0x10
    
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    
    pop bx
    pop cx
    inc bl
    loop .loop
    
    call newline
    call newline
    ret

show_background_colors:
    mov si, bg_colors_header
    call print_string
    
    mov cx, 8
    mov bl, 0
    
.loop:
    push cx
    push bx
    
    shl bl, 4
    or bl, 0x0f
    
    mov ah, 0x09
    mov al, ' '
    mov bh, 0
    mov cx, 4
    int 0x10
    
    shr bl, 4
    
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    
    pop bx
    pop cx
    inc bl
    loop .loop
    
    call newline
    call newline
    ret

print_string:
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

newline:
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

title:               db 'Color Palette', 13, 10, 13, 10, 0
text_colors_header:  db 'Text Colors (0-15):', 13, 10, 0
bg_colors_header:    db 'Background Colors (0-7):', 13, 10, 0
press_key:          db 13, 10, 'Press any key to return...', 0

times 512-($-$$) db 0
