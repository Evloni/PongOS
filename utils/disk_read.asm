; disk read

disk_load:
    push dx
    mov ah, 0x02
    mov al, 0x0
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02

    int 0x13

    jc disk_read_error
    pop dx
    cmp dh,al
    jne disk_read_error
    ret

disk_read_error:
    mov bx, Disk_read_error_msg
    call halt

Disk_read_error_msg: db 'Failed to read disk!', 0x0D, 0x0A, 0