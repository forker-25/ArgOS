[bits 16]
[org 0x1000]

start:
    mov si, hello_msg
    call print_string
    call wait_key
    ret

print_string:
    mov ah, 0x0e
    .loop:
        lodsb
        cmp al, 0
        je .done
        int 0x10
        jmp .loop
    .done:
        ret

wait_key:
    mov ah, 0x00
    int 0x16
    ret

hello_msg db 'Hello world!', 0x0d, 0x0a, 'Press any key to return...', 0x0d, 0x0a, 0
