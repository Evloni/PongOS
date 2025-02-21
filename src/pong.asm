
main: 
    call clear_screen
    mov si, Pong_Msg
    call print
    jmp halt

clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10
    ret

halt:
    cli
    hlt
    jmp halt

include "./utils/print_string.asm"

Pong_Msg: db 'Pong Loaded', 0x0D, 0x0A, 0

times 512-($-$$) db 0
dw 0AA55h