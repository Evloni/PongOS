use16

jmp short setup_pong

; Constants
VIDMEM		 equ 0B800h	; Color text mode VGA memory location
ROWLEN		 equ 160	; 80 Character row * 2 bytes each
PLAYERX		 equ 4		; Player X position
CPUX		 equ 154	; CPU X position
KEY_W		 equ 11h	; Keyboard scancodes...
KEY_S		 equ 1Fh
KEY_C		 equ 2Eh	
KEY_R		 equ 13h
SCREENW		 equ 80
SCREENH		 equ 24
PADDLEHEIGHT equ 5
TIMER        equ 046Ch

; VARIABLES -----------
drawColor: dw 0F020h
playerY:   dw 10	; Start player Y position 
cpuY:	   dw 10	; Start cpu Y position 
ballX:	   dw 66	; Starting ball X position
ballY:	   dw 7		; Starting ball Y position
ballVelX:  db -2	; Ball X direction
ballVelY:  db 1		; Ball Y direction
playerScore: db 0
cpuScore:	 db 0
cpuTimer:	 db 0	; # of cycles before CPU allowed to move
cpuDifficulty: db 1	; CPU "difficulty" level


setup_pong:
    ; Set graphics mode
    mov ax, 03h        ; Set mode 13h (320x200, 256 colors)
    int 10h

    ; Set up video memory
    mov ax, VIDMEM
    mov es, ax           ; ES for video memory

 

game_loop:
    xor ax, ax
    xor di, di
    mov cx, 80*25
    rep stosb

    ;Draw the middle line
    mov ax, [drawColor]
    mov di, 78
    mov cl, 13
    .draw_middle_line_loop:
        stosw
        add di, 2*ROWLEN-2
        loop .draw_middle_line_loop

    ;draw player and cpu paddle
    imul di, [playerY], ROWLEN
    imul bx, [cpuY], ROWLEN
    mov cl, PADDLEHEIGHT
    .draw_player_and_cpu_loop:
        mov [es:di+PLAYERX], ax
        mov [es:bx+CPUX], ax
        add di, ROWLEN
        add bx, ROWLEN
        loop .draw_player_and_cpu_loop


    .get_player_input:
        mov ah, 0
        int 16h
        jz move_cpu_up

        cbw
        int 16h
        
        cmp al, 77h
        je w_pressed
        cmp ah, KEY_S
        je s_pressed

        s_pressed:
            cmp word [playerY], SCREENH - PADDLEHEIGHT
            jg move_cpu_up
            inc word [playerY]
            jmp move_cpu_up

        w_pressed:
            dec word [playerY]
            jge move_cpu_up
            inc word [playerY]
            jmp move_cpu_up

        move_cpu_up:
            dec word [cpuY]

    ;mov bx, [TIMER]
    ;inc bx
    ;inc bx
    ;.delay:
     ;   cmp [TIMER], bx
      ;  jl .delay

jmp game_loop