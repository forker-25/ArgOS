[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10
    
    mov si, title
    call print_string
    
    mov si, cpu_info
    call print_string
    
    mov si, features_info
    call print_string
    
    mov si, press_key
    call print_string
    mov ah, 0
    int 0x16
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

title:         db 'NaOS CPU Info', 13, 10, 13, 10, 0
cpu_info:      db 'CPU: x86 Compatible', 13, 10
               db 'Mode: Real Mode (16-bit)', 13, 10, 13, 10, 0
features_info: db 'Features:', 13, 10
               db '- Math Coprocessor Support', 13, 10
               db '- Protected Mode Ready', 13, 10, 13, 10, 0
press_key:     db 'Press any key...', 0

times 512-($-$$) db 0