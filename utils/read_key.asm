wait_for_key:
    call read_key
    cmp ah, 0x19 ;ScanCode for "A/a"
    ret

read_key:
    mov ah, 0x00
    int 16h
    ret