; bootloader.asm
[BITS 16]
[ORG 0x7C00]  ; The bootloader is loaded at 0x7C00 in memory

; Constants
KERNEL_OFFSET equ 0x1000  ; Memory offset to load the kernel

start:
    ; Set up segments
    cli             ; Disable interrupts
    xor ax, ax      ; Clear AX (set to 0)
    mov ds, ax      ; Data segment
    mov es, ax      ; Extra segment
    mov ss, ax      ; Stack segment
    mov sp, 0x7C00  ; Stack pointer at bootloader start
    sti             ; Enable interrupts

    ; Save boot drive number
    mov [BOOT_DRIVE], dl

    ; Print bootloader message
    mov si, boot_msg
    call print_string
    
    ; Load kernel from disk
    mov si, load_msg
    call print_string
    
    ; Load kernel to KERNEL_OFFSET
    call load_kernel
    
    ; Switch to protected mode
    mov si, switch_msg
    call print_string
    
    ; Switch to protected mode
    call switch_to_pm
    
    ; We never get here
    jmp $

; Load kernel from disk to memory at KERNEL_OFFSET
load_kernel:
    pusha
    
    ; Set up parameters for disk read
    mov ah, 0x02        ; BIOS read function
    mov al, 20          ; Read 20 sectors (10KB, enough for our kernel)
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2 (1-indexed)
    mov dh, 0           ; Head 0
    mov dl, [BOOT_DRIVE]; Drive number
    
    ; Set up memory location to read to
    mov bx, KERNEL_OFFSET
    
    ; Perform the read
    int 0x13
    
    ; Check for errors
    jc disk_error
    
    ; Check if we read the right number of sectors
    cmp al, 20
    jne disk_error
    
    popa
    ret

disk_error:
    mov si, error_msg
    call print_string
    jmp $               ; Infinite loop

; Function to print a null-terminated string
; Input: SI = pointer to string
print_string:
    pusha
    mov ah, 0x0E        ; BIOS teletype function
.loop:
    lodsb               ; Load byte at SI into AL and increment SI
    test al, al         ; Check if AL is 0 (end of string)
    jz .done            ; If zero, we're done
    int 0x10            ; Print the character
    jmp .loop           ; Repeat for next character
.done:
    popa
    ret

; Function to switch to protected mode
switch_to_pm:
    cli                 ; Disable interrupts
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Far jump to 32-bit code
    jmp CODE_SEG:init_pm

[BITS 32]
; Initialize protected mode
init_pm:
    ; Set up segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up stack
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Jump to kernel
    call KERNEL_OFFSET
    
    ; If we get here, something went wrong
    jmp $

; GDT
gdt_start:
    ; Null descriptor
    dd 0
    dd 0
    
    ; Code segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0            ; Base (bits 0-15)
    db 0            ; Base (bits 16-23)
    db 10011010b    ; Access byte
    db 11001111b    ; Flags + Limit (bits 16-19)
    db 0            ; Base (bits 24-31)
    
    ; Data segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0            ; Base (bits 0-15)
    db 0            ; Base (bits 16-23)
    db 10010010b    ; Access byte
    db 11001111b    ; Flags + Limit (bits 16-19)
    db 0            ; Base (bits 24-31)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT
    dd gdt_start                ; Address of GDT

; Constants
CODE_SEG equ 0x08   ; Code segment selector
DATA_SEG equ 0x10   ; Data segment selector

; Variables
BOOT_DRIVE db 0     ; Boot drive number

; Messages
boot_msg db 'Booting PongOS...', 13, 10, 0
load_msg db 'Loading kernel...', 13, 10, 0
switch_msg db 'Switching to protected mode...', 13, 10, 0
error_msg db 'Disk error!', 13, 10, 0

times 510 - ($ - $$) db 0  ; Fill the rest of the bootloader with zeros
dw 0xAA55               ; Bootloader signature (0xAA55)
