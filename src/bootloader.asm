org 0x7C00

jmp short main
nop

bdb_oem: db 'MSWIN4.1'
bdb_bytes_per_sector: dw 512
bdb_sector_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_fat_count: db 2
bdb_dir_enteries_count: dw 0E0h
bdb_total_sectors: dw 2880
bdb_media_descriptor_type: db 0F0h
bdb_sector_per_fat: dw 9
bdb_sector_per_track: dw 18
bdb_heads: dw 2
bdb_hidden_sectors: dd 0
bdb_large_sector_count: dd 0

ebr_drive_number: db 0 
db 0
ebr_signature db 29h
ebr_volume_id: db 12h,34h,56h,78h
ebr_volume_label: db 'PongOS     '
ebr_system_id: db 'FAT12      '



main:
    call clear_screen

    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10

    mov si, PongOS_Booted_Msg
    call print
    call load_Pong
    
load_Pong:
    mov si, Loading_Pong_Msg
    call print
    mov ah, 0x00
    int 0x1A
    add dx, 92   
    mov [time_end], dx
    call sleep_bios
    call disk_read

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
include "./utils/disk_read.asm"
include "./utils/sleep.asm"

PongOS_Booted_Msg:
    db '#####################################', 0x0D, 0x0A
    db 'PongOS has booted! Welcome to PongOS!', 0x0D, 0x0A
    db '#####################################', 0x0D, 0x0A
    db 0x0A, 0  ; Add a newline at the end and a null terminator

Loading_Pong_Msg: db 'Loading Pong.....', 0x0D, 0x0A, 0
time_end dw 0

RB 510-($-$$)    ; Adjust size for 512-byte boot sector
DW 0xAA55        ; Boot signature