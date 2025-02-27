[BITS 32]
[GLOBAL start]
[EXTERN main]

section .text.start
start:
    ; Call the C main function
    call main
    
    ; If main returns, halt the CPU
    cli
    hlt
    jmp $

; Reserve 16KB for the stack
section .bss
align 16
stack_bottom:
    resb 16384
stack_top: 