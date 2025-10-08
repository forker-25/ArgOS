[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10

    mov si, title
    call print

    mov si, floppy_msg
    call print

    mov dl, 0x00
.check_floppy:
    cmp dl, 0x04
    jae .floppy_done
    
    call check_drive
    inc dl
    jmp .check_floppy

.floppy_done:
    mov si, hdd_msg
    call print

    mov dl, 0x80
.check_hdd:
    cmp dl, 0x88
    jae .hdd_done
    
    call check_drive
    inc dl
    jmp .check_hdd

.hdd_done:
    mov si, done_msg
    call print

    mov si, exit_msg
    call print

.wait:
    mov ah, 0
    int 0x16
    
    mov ax, 0x0003
    int 0x10
    
    ret

check_drive:
    pusha
    
    push dx
    
    mov ah, 0x15
    int 0x13
    jc .not_found
    
    cmp ah, 0
    je .not_found
    cmp ah, 3
    je .found
    cmp ah, 2
    je .found
    cmp ah, 1
    je .found
    jmp .not_found

.found:
    pop dx
    push dx
    
    mov si, found_str
    call print
    
    pop dx
    push dx
    
    mov al, dl
    call print_hex
    
    mov si, space
    call print
    
    pop dx
    push dx
    
    cmp dl, 0x80
    jb .is_floppy
    
    mov si, type_hdd
    call print
    jmp .get_params

.is_floppy:
    mov si, type_floppy
    call print

.get_params:
    pop dx
    push dx
    
    push es
    push di
    
    mov ah, 0x08
    xor di, di
    mov es, di
    int 0x13
    
    pop di
    pop es
    
    jc .no_params
    
    and cx, 0x3f
    
    mov si, sectors_msg
    call print
    
    mov ax, cx
    call print_dec
    
    mov si, heads_msg
    call print
    
    xor ax, ax
    mov al, dh
    inc al
    call print_dec

.no_params:
    call newline
    pop dx
    popa
    ret

.not_found:
    pop dx
    popa
    ret

print_hex:
    push ax
    push bx
    
    mov ah, al
    shr al, 4
    and al, 0x0f
    add al, '0'
    cmp al, '9'
    jbe .first_digit
    add al, 7
.first_digit:
    mov bx, hex_buf
    mov [bx], al
    
    mov al, ah
    and al, 0x0f
    add al, '0'
    cmp al, '9'
    jbe .second_digit
    add al, 7
.second_digit:
    mov [bx+1], al
    
    mov si, hex_prefix
    call print
    mov si, hex_buf
    call print
    
    pop bx
    pop ax
    ret

print_dec:
    push ax
    push bx
    push cx
    push dx
    
    xor cx, cx
    mov bx, 10
    
.divide_loop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .divide_loop
    
.print_loop:
    pop ax
    mov ah, 0x0e
    int 0x10
    loop .print_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
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
    push ax
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    pop ax
    ret

title:          db '=== Device Scanner ===', 13, 10, 13, 10, 0
floppy_msg:     db 'Floppy Drives:', 13, 10, 0
hdd_msg:        db 13, 10, 'Hard Disks / USB:', 13, 10, 0
found_str:      db '  Drive ', 0
type_floppy:    db '(Floppy)', 0
type_hdd:       db '(HDD/USB)', 0
sectors_msg:    db ', Sectors: ', 0
heads_msg:      db ', Heads: ', 0
done_msg:       db 13, 10, 'Scan complete!', 13, 10, 0
exit_msg:       db 'Press any key to return...', 0
hex_prefix:     db '0x', 0
space:          db ' ', 0

hex_buf:        times 3 db 0

times 4096-($-$$) db 0
