[org 0x1000]
[bits 16]

start:
    mov ax, 0x03
    int 0x10
    
    mov si, header_msg
    call print
    
    mov si, 0x1000
    mov cx, 32
    mov dl, 0
.dump_loop:
    call print_hex_word
    mov al, ' '
    mov ah, 0x0e
    int 0x10
    add si, 2
    inc dl
    cmp dl, 8
    jne .no_newline
    call newline
    mov dl, 0
.no_newline:
    loop .dump_loop
    
    call newline
    mov si, return_msg
    call print
    mov ah, 0
    int 0x16
    ret

print:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp .loop
.done:
    popa
    ret

newline:
    mov al, 13
    mov ah, 0x0e
    int 0x10
    mov al, 10
    mov ah, 0x0e
    int 0x10
    ret

print_hex_word:
    push ax
    push dx
    mov dx, [si]
    mov al, dh
    call print_hex_byte
    mov al, dl
    call print_hex_byte
    pop dx
    pop ax
    ret

print_hex_byte:
    push ax
    shr al, 4
    call print_hex_digit
    pop ax
    and al, 0x0F
    call print_hex_digit
    ret

print_hex_digit:
    cmp al, 10
    jl .digit
    add al, 'A' - 10
    jmp .print
.digit:
    add al, '0'
.print:
    mov ah, 0x0e
    int 0x10
    ret

header_msg:
    db 'RAM Dump Utility', 13, 10
    db 'Memory from 0x1000:', 13, 10, 13, 10, 0

return_msg:
    db 13, 10, 'Press any key to return...', 0