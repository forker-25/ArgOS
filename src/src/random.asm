[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10
    
    mov si, title
    call print_string
    
    call init_random

main_loop:
    mov si, menu
    call print_string
    
    mov ah, 0
    int 0x16
    
    cmp al, '1'
    je generate_number
    cmp al, '2'
    je generate_dice
    cmp al, '3'
    je generate_coin
    cmp al, '4'
    je generate_password
    cmp al, 27
    je exit_program
    
    jmp main_loop

generate_number:
    mov si, random_number_label
    call print_string
    call get_random_word
    call print_number
    call newline
    call newline
    jmp main_loop

generate_dice:
    mov si, dice_label
    call print_string
    call get_random_word
    mov bx, 6
    xor dx, dx
    div bx
    inc dx
    mov ax, dx
    call print_number
    call newline
    call newline
    jmp main_loop

generate_coin:
    mov si, coin_label
    call print_string
    call get_random_word
    test al, 1
    jz .heads
    mov si, tails_msg
    jmp .print_coin
.heads:
    mov si, heads_msg
.print_coin:
    call print_string
    call newline
    jmp main_loop

generate_password:
    mov si, password_label
    call print_string
    mov cx, 8  
.pass_loop:
    call get_random_word
    mov bx, 26
    xor dx, dx
    div bx
    add dl, 'A'
    mov ah, 0x0e
    mov al, dl
    int 0x10
    loop .pass_loop
    call newline
    call newline
    jmp main_loop

exit_program:
    ret

init_random:
    mov ah, 0x00
    int 0x1a
    mov [random_seed], dx
    ret

get_random_word:
    mov ax, [random_seed]
    mov bx, 25173
    mul bx
    add ax, 13849
    mov [random_seed], ax
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

newline:
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

title:               db 'NaOS Random Generator', 13, 10, 13, 10, 0
menu:                db '1 - Random Number (0-65535)', 13, 10
                     db '2 - Dice Roll (1-6)', 13, 10
                     db '3 - Coin Flip', 13, 10
                     db '4 - Random Password (8 chars)', 13, 10
                     db 'ESC - Exit', 13, 10, 13, 10
                     db 'Choice: ', 0
random_number_label: db 'Random Number: ', 0
dice_label:          db 'Dice Roll: ', 0
coin_label:          db 'Coin Flip: ', 0
heads_msg:           db 'HEADS', 13, 10, 0
tails_msg:           db 'TAILS', 13, 10, 0
password_label:      db 'Password: ', 0

random_seed:         dw 0

times 512-($-$$) db 0