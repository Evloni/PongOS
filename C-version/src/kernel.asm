[BITS 32]
[ORG 0x1000]

; Kernel entry point
start:
    ; Set up video memory for text mode (0xB8000)
    mov ebx, 0xB8000
    
    ; Write "Hello, Kernel World!" to video memory
    mov byte [ebx], 'H'
    mov byte [ebx+1], 0x0F
    mov byte [ebx+2], 'e'
    mov byte [ebx+3], 0x0F
    mov byte [ebx+4], 'l'
    mov byte [ebx+5], 0x0F
    mov byte [ebx+6], 'l'
    mov byte [ebx+7], 0x0F
    mov byte [ebx+8], 'o'
    mov byte [ebx+9], 0x0F
    mov byte [ebx+10], ','
    mov byte [ebx+11], 0x0F
    mov byte [ebx+12], ' '
    mov byte [ebx+13], 0x0F
    mov byte [ebx+14], 'K'
    mov byte [ebx+15], 0x0F
    mov byte [ebx+16], 'e'
    mov byte [ebx+17], 0x0F
    mov byte [ebx+18], 'r'
    mov byte [ebx+19], 0x0F
    mov byte [ebx+20], 'n'
    mov byte [ebx+21], 0x0F
    mov byte [ebx+22], 'e'
    mov byte [ebx+23], 0x0F
    mov byte [ebx+24], 'l'
    mov byte [ebx+25], 0x0F
    mov byte [ebx+26], ' '
    mov byte [ebx+27], 0x0F
    mov byte [ebx+28], 'W'
    mov byte [ebx+29], 0x0F
    mov byte [ebx+30], 'o'
    mov byte [ebx+31], 0x0F
    mov byte [ebx+32], 'r'
    mov byte [ebx+33], 0x0F
    mov byte [ebx+34], 'l'
    mov byte [ebx+35], 0x0F
    mov byte [ebx+36], 'd'
    mov byte [ebx+37], 0x0F
    mov byte [ebx+38], '!'
    mov byte [ebx+39], 0x0F
    
    ; Halt the CPU
    cli
    hlt
    jmp $                  ; Infinite loop 