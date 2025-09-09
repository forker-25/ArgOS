[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10
    
    mov si, title
    call print_string
    
    call show_ascii_table
    
    mov si, press_key
    call print_string
    mov ah, 0
    int 0x16
    
    ret

show_ascii_table:
    mov al, 32  
    mov bl, 0   
    
.loop:
    cmp al, 126
    ja .done
    
    push ax
    mov ah, 0
    call print_decimal_3
    pop ax
    
    push ax
    mov al, ':'
    call print_char
    pop ax
    
    call print_char
    
    push ax
    mov al, ' '
    call print_char
    call print_char
    pop ax
    
    inc bl
    cmp bl, 8
    jne .continue
    
    call newline
    mov bl, 0
    
.continue:
    inc al
    jmp .loop

.done:
    call newline
    ret

print_decimal_3:
    mov bx, 100
    xor dx, dx
    div bx
    
    test al, al
    jz .tens_check
    add al, '0'
    call print_char
    jmp .tens
    
.tens_check:
    mov al, ' '
    call print_char
    
.tens:
    mov ax, dx
    mov bl, 10
    xor dx, dx
    div bl
    
    cmp ax, 0
    je .units_check
    add al, '0'
    call print_char
    jmp .units
    
.units_check:
    mov al, ' '
    call print_char
    
.units:
    mov al, dl
    add al, '0'
    call print_char
    ret

print_char:
    mov ah, 0x0e
    int 0x10
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

title:      db 'NaOS ASCII Table (32-126)', 13, 10, 13, 10, 0
press_key:  db 13, 10, 'Press any key to return...', 0

times 512-($-$$) db 0
