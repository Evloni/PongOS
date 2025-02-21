
; This is the print_string function
print:
    push ax               ; Save registers that will be modified
    push bx
    push si

print_loop:
    lodsb                  ; Load the byte at DS:SI into AL and increment SI
    or al, al              ; Check if AL is null (end of string)
    jz done_print          ; If AL is 0, jump to done_print
    mov ah, 0x0E           ; BIOS teletype function (print character in AL)
    mov bh, 0x00           ; Page number (0 for the default page)
    mov bl, 0x07           ; Text attribute (light gray on black)
    int 0x10               ; Call BIOS interrupt to print character
    jmp print_loop         ; Repeat for next character

done_print:
    pop si                 ; Restore registers
    pop bx
    pop ax
    ret     