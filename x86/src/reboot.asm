[org 0x1000]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10
    
    mov si, title_msg
    call print
    
    mov si, warning_msg
    call print
    
    mov si, confirm_msg
    call print

    mov ah, 0
    int 0x16
    
    cmp al, 'y'
    je do_reboot
    cmp al, 'Y' 
    je do_reboot
    
    mov si, cancel_msg
    call print
    call wait_key
    ret

do_reboot:
    mov si, rebooting_msg
    call print
    
    mov cx, 0xFFFF
.delay_loop:
    nop
    loop .delay_loop
    
    mov al, 0xFE
    out 0x64, al
    
    mov ax, 0x0040
    mov ds, ax
    mov word [0x0072], 0x1234
    jmp 0xFFFF:0x0000          

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

wait_key:
    mov ah, 0
    int 0x16
    ret

title_msg: db 'System Reboot', 13, 10, 13, 10, 0
warning_msg: db 'This will restart the system immediately!', 13, 10, 0
confirm_msg: db 'Press Y to reboot, any other key to cancel: ', 0
cancel_msg: db 13, 10, 'Reboot cancelled.', 13, 10, 'Press any key...', 0
rebooting_msg: db 13, 10, 'Rebooting system...', 13, 10, 0

times 512-($-$$) db 0
