[org 0x1000]
[bits 16]

start:
    mov si, credits_text
    call print
    
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

credits_text:
    db 'Author: Cirnik(sociophatia)', 13, 10
    db 'Version: prealpha-1.0', 13, 10, 13, 10, 0

return_msg:
    db 'Press any key to return...', 0
