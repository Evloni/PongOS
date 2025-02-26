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
ballVelX:  db -1	; Ball X direction
ballVelY:  db 1		; Ball Y direction
playerScore: db 0
cpuScore:	 db 0
cpuTimer:	 db 0	; # of cycles before CPU allowed to move
cpuDifficulty: db 10	; Increased CPU difficulty (higher = slower CPU movement)
gameSpeed:   dw 10   ; Controls game speed (higher = slower)
ballMoveCounter: db 0   ; Counter to slow down ball movement
ballMoveDelay: db 30    ; Increased delay for ball movement (higher = slower ball)
frameDelay: dw 5000h   ; Main frame delay (higher = slower game)


setup_pong:
    ; Set graphics mode
    mov ax, 0003h        ; Set mode 03h (80x25 text mode)
    int 10h

    ; Set up video memory
    mov ax, VIDMEM
    mov es, ax           ; ES for video memory

    ;Hiding cursor
    mov ax, 0100h
    mov cx, 2607h
    int 10h

game_loop:
    ; Clear screen
    mov ax, 0720h        ; Space character with normal attribute
    xor di, di
    mov cx, 80*25
    rep stosw

    ; Draw the middle line
    mov ax, [drawColor]
    mov di, 78
    mov cl, 13
    .draw_middle_line_loop:
        stosw
        add di, 2*ROWLEN-2
        loop .draw_middle_line_loop

    ; Draw player and cpu paddle
    imul di, [playerY], ROWLEN
    imul bx, [cpuY], ROWLEN
    mov cl, PADDLEHEIGHT
    .draw_player_and_cpu_loop:
        mov [es:di+PLAYERX], ax
        mov [es:bx+CPUX], ax
        add di, ROWLEN
        add bx, ROWLEN
        loop .draw_player_and_cpu_loop

    ; Draw the ball
    imul di, [ballY], ROWLEN
    add di, [ballX]
    add di, [ballX]     ; Multiply by 2 since each character takes 2 bytes
    mov [es:di], ax

    ; Move the ball (only every few frames)
    inc byte [ballMoveCounter]
    mov al, [ballMoveDelay]
    cmp [ballMoveCounter], al
    jl .skip_ball_movement
    
    ; Reset counter
    mov byte [ballMoveCounter], 0
    
    ; Move the ball
    mov al, [ballVelX]
    cbw                 ; Convert byte to word (sign extend AL into AX)
    add [ballX], ax
    
    mov al, [ballVelY]
    cbw
    add [ballY], ax
    
    ; Check for ball collision with top/bottom walls
    cmp word [ballY], 0
    jg .check_bottom
    neg byte [ballVelY]
    mov word [ballY], 1
    
    .check_bottom:
    cmp word [ballY], SCREENH-1
    jl .check_paddles
    neg byte [ballVelY]
    mov word [ballY], SCREENH-2
    
    .check_paddles:
    ; Check collision with player paddle
    cmp word [ballX], PLAYERX+2
    jne .check_cpu_paddle
    
    mov ax, [ballY]
    sub ax, [playerY]
    cmp ax, 0
    jl .check_cpu_paddle
    cmp ax, PADDLEHEIGHT
    jge .check_cpu_paddle
    
    neg byte [ballVelX]
    add word [ballX], 2
    
    .check_cpu_paddle:
    ; Enhanced CPU paddle collision detection
    mov ax, [ballX]
    
    ; First check: Is the ball in the horizontal collision zone?
    cmp ax, CPUX-3      ; Expanded left collision boundary
    jl .check_scoring   ; Ball is too far left
    cmp ax, CPUX        ; Right collision boundary
    jg .check_scoring   ; Ball is too far right
    
    ; Second check: Is the ball moving toward the paddle?
    ; We only need this check if the ball is approaching from the left
    cmp byte [ballVelX], 1
    jne .check_y_overlap  ; If moving left or stationary, still check Y overlap
    
    ; If we're here, the ball is in the horizontal zone and moving right
    
    .check_y_overlap:
    ; Third check: Is the ball within the paddle's vertical range?
    mov ax, [ballY]
    mov bx, [cpuY]
    
    ; Is ball above the paddle?
    cmp ax, bx
    jl .check_scoring
    
    ; Is ball below the paddle?
    mov cx, bx
    add cx, PADDLEHEIGHT-1
    cmp ax, cx
    jg .check_scoring
    
    ; Ball hit the CPU paddle!
    
    ; 1. Reverse ball direction
    mov byte [ballVelX], -1
    
    ; 2. Position the ball just to the left of the paddle to prevent sticking
    mov word [ballX], CPUX-3
    
    ; 3. Add a small random vertical deflection for more interesting gameplay
    mov ax, [ballY]
    add ax, [cpuTimer]  ; Use cpuTimer as a pseudo-random value
    and ax, 1           ; Get just the lowest bit (0 or 1)
    jz .no_y_change
    
    ; Change Y direction slightly based on where the ball hit the paddle
    mov ax, [ballY]
    sub ax, [cpuY]      ; Calculate relative position on paddle
    cmp ax, PADDLEHEIGHT/2
    jl .hit_top_half
    
    ; Hit bottom half - ensure downward movement
    cmp byte [ballVelY], 0
    jg .no_y_change     ; Already moving down
    neg byte [ballVelY] ; Change to moving down
    jmp .no_y_change
    
    .hit_top_half:
    ; Hit top half - ensure upward movement
    cmp byte [ballVelY], 0
    jl .no_y_change     ; Already moving up
    neg byte [ballVelY] ; Change to moving up
    
    .no_y_change:
    ; Skip scoring check after collision
    jmp .skip_ball_movement

    .check_scoring:
    ; Check if ball went out of bounds and reset it
    cmp word [ballX], 0
    jg .check_right_bound
    ; Ball went past left edge, reset to center
    mov word [ballX], 66
    mov word [ballY], 7
    mov byte [ballVelX], 1  ; Start moving right
    jmp .skip_ball_movement
    
    .check_right_bound:
    cmp word [ballX], SCREENW*2
    jl .skip_ball_movement
    ; Ball went past right edge, reset to center
    mov word [ballX], 66
    mov word [ballY], 7
    mov byte [ballVelX], -1  ; Start moving left

    .skip_ball_movement:
    .check_keyboard:
        ; Check keyboard buffer
        mov ah, 1       ; Check if key is available
        int 16h
        jz .move_cpu    ; If no key, skip to CPU movement
        
        ; Get key from buffer
        xor ah, ah      ; Function 0 - get keystroke
        int 16h
        
        ; Check which key was pressed
        cmp ah, KEY_W
        je .w_pressed
        cmp ah, KEY_S
        je .s_pressed
        cmp ah, KEY_R   ; Add restart option
        je setup_pong
        jmp .move_cpu   ; If not W or S, just move CPU
        
    .w_pressed:
        cmp word [playerY], 0
        jle .move_cpu
        dec word [playerY]
        jmp .move_cpu
            
    .s_pressed:
        cmp word [playerY], SCREENH - PADDLEHEIGHT
        jge .move_cpu
        inc word [playerY]
            
    .move_cpu:
        ; Simple AI: CPU follows the ball
        dec byte [cpuTimer]
        jnz .delay
        
        mov al, [cpuDifficulty]  ; Load cpuDifficulty into AL first
        mov [cpuTimer], al       ; Then move it to cpuTimer
        
        mov ax, [ballY]
        cmp ax, [cpuY]
        jl .cpu_move_up
        
        mov ax, [cpuY]
        add ax, PADDLEHEIGHT/2
        cmp ax, [ballY]
        jl .cpu_move_down
        jmp .delay
        
    .cpu_move_up:
        cmp word [cpuY], 0
        jle .delay
        dec word [cpuY]
        jmp .delay
            
    .cpu_move_down:
        cmp word [cpuY], SCREENH - PADDLEHEIGHT
        jge .delay
        inc word [cpuY]

    .delay:
        ; Use a nested loop for a much longer delay
        mov cx, 0FFh    ; Outer loop count
    .outer_delay_loop:
        push cx         ; Save outer loop counter
        mov cx, [frameDelay]  ; Inner loop count
    .inner_delay_loop:
        loop .inner_delay_loop
        pop cx          ; Restore outer loop counter
        loop .outer_delay_loop

jmp game_loop