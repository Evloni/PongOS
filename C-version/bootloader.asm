org 0x7c00
use16

start:
    mov ah, 0x0e
    mov al, 'H'
    int 0x10
    mov ah, 0x0e
    mov al, 'e'
    int 0x10
    mov ah, 0x0e
    mov al, 'l'
    int 0x10
    mov ah, 0x0e
    mov al, 'l'
    int 0x10
    mov ah, 0x0e
    mov al, 'o'
    int 0x10

    cli
    hlt


times 510-($-$$) db 0

dw 0xAA55
