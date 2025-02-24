; disk read

disk_read:
    mov bx, 0x2000
    mov es, bx
    mov bx, 0x0

    mov ah, 0x02    ; BIOS read function
    mov al, 0x01    ; Read 1 sector
    mov ch, 0x00    ; Cylinder 0
    mov cl, 0x02    ; Sector 2 (where Pong is stored)
    mov dh, 0x00    ; Head 0
    mov dl, 0x00    ; Drive 0 (floppy)
    int 0x13        ; Call BIOS to read

    jc disk_read_error

    mov ax, 0x2000
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0xFFFE

    jmp 0x2000:0x0

disk_read_error:
    mov si, Disk_read_error_msg
    call print
    call halt
    

Disk_read_error_msg: db 'Failed to read disk!', 0x0D, 0x0A, 0