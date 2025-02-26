clear_pong_screen:
     ; Set up video memory
    mov ax, VIDMEM
    mov es, ax           ; ES for video memory
    xor ax, ax
    xor di, di
    mov cx, 80*25
    rep stosw
    