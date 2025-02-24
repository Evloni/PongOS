sleep_bios:
    mov ah, 0x00
    int 0x1A
    add dx, 364

wait_loop:
    int 0x1A
    cmp dx, [time_end]
    jb wait_loop
    ret

