[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10
    
    mov si, title
    call print_string
    
    call get_memory_info
    
    call show_memory_map
    
    mov si, press_key
    call print_string
    mov ah, 0
    int 0x16
    
    ret

get_memory_info:
    int 0x12
    mov [base_memory], ax
    
    mov ah, 0x88
    int 0x15
    mov [extended_memory], ax
    ret

show_memory_map:
    mov si, base_mem_label
    call print_string
    mov ax, [base_memory]
    call print_number
    mov si, kb_suffix
    call print_string
    
    mov si, ext_mem_label
    call print_string
    mov ax, [extended_memory]
    call print_number
    mov si, kb_suffix
    call print_string
    
    mov si, memory_map_header
    call print_string
    
    mov si, conventional_area
    call print_string
    
    mov si, upper_area
    call print_string
    
    mov si, extended_area
    call print_string
    
    mov si, bios_area
    call print_string
    
    ret

print_number:
    mov bx, 10
    xor cx, cx
    
.convert:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne .convert

.print:
    pop dx
    mov ah, 0x0e
    mov al, dl
    int 0x10
    dec cx
    jnz .print
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

title:              db 'Memory Information', 13, 10, 13, 10, 0
base_mem_label:     db 'Base Memory: ', 0
ext_mem_label:      db 'Extended Memory: ', 0
kb_suffix:          db ' KB', 13, 10, 0
memory_map_header:  db 13, 10, 'Memory Map:', 13, 10, 0
conventional_area:  db '0x00000-0x9FFFF: Conventional Memory', 13, 10, 0
upper_area:         db '0xA0000-0xFFFFF: Upper Memory Area', 13, 10, 0
extended_area:      db '0x100000+: Extended Memory', 13, 10, 0
bios_area:          db '0xF0000-0xFFFFF: BIOS ROM', 13, 10, 0
press_key:          db 13, 10, 'Press any key to return...', 0

base_memory:        dw 0
extended_memory:    dw 0

times 512-($-$$) db 0
