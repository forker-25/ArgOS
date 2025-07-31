[org 0x1000]
[bits 16]

start:
    mov ax,0x0003
    int 0x10

    xor eax,eax
    db 0x0F,0xA2           ; CPUID
    mov [vendor],ebx
    mov [vendor+4],edx
    mov [vendor+8],ecx
    mov byte [vendor+12],0
    mov si,vendor
    call print_string

    mov eax,1
    db 0x0F,0xA2           ; CPUID
    test edx,1
    jz .fpu0
    mov si,fpu1
    call print_string
    jmp .fpu_done
.fpu0:
    mov si,fpu0
    call print_string
.fpu_done:

    test edx,1<<23
    jz .mmx0
    mov si,mmx1
    call print_string
    jmp .mmx_done
.mmx0:
    mov si,mmx0
    call print_string
.mmx_done:

    test edx,1<<25
    jz .sse0
    mov si,sse1
    call print_string
    jmp .sse_done
.sse0:
    mov si,sse0
    call print_string
.sse_done:

    test edx,1<<26
    jz .sse20
    mov si,sse21
    call print_string
    jmp .end
.sse20:
    mov si,sse20
    call print_string

.end:
    mov si,press_key
    call print_string
    mov ah,0
    int 0x16
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

vendor     db '............',13,10,0
fpu1       db 'FPU: Yes',13,10,0
fpu0       db 'FPU: No',13,10,0
mmx1       db 'MMX: Yes',13,10,0
mmx0       db 'MMX: No',13,10,0
sse1       db 'SSE: Yes',13,10,0
sse0       db 'SSE: No',13,10,0
sse21      db 'SSE2: Yes',13,10,0
sse20      db 'SSE2: No',13,10,0
press_key  db 'Press any key...',0

times 512-($-$$) db 0
