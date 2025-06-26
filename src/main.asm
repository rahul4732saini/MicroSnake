; MicroSnake
; Author: Rahul Saini (github.com/rahul4732saini)
;
; A minimal, bootable implemenation of the classic snake game in x86 Assembly,
; designed to run directly from the 512-byte MBR of legacy BIOS systems. 

BITS    16
ORG     0x7C00

; The snake is initially placed in the center of
; the 16x10 board at x=7 and y=4 (0-indexed).

SNAKE_START     equ 0x74
SNAKE_MAX_LEN   equ 100

; Display component sizes are stored in pixels.
BLOCK_SIZE      equ 20
ROW_SIZE        equ 320 * BLOCK_SIZE    ; 320 (screen width) x 20 (Block Size)

; VGA color indices used in the game
COLOR_BLACK     equ 0
COLOR_GREEN     equ 2
COLOR_RED       equ 4

; Displacements to move the snake in the associated direction.
DIR_NONE        equ 0
DIR_RIGHT_DOWN  equ 1
DIR_LEFT_UP     equ -1

; ASCII code associated with the keyboard keys.
KEY_W   equ 'w'
KEY_S   equ 's'
KEY_A   equ 'a'
KEY_D   equ 'd'

; Compares the 1st argument with the ASCII code stored in AL and
; jumps to the memory location in the 2nd argument if they are equal.
%macro cmp_key 2
    CMP     al, %1
    JE      %2
%endmacro

; Sets the snake movement direction based on the specified
; arguments and jumps to the snake updation routine.
%macro set_dir 2
    MOV     [dir_y], byte %1
    MOV     [dir_x], byte %2
    JMP     _update_snake
%endmacro

start:

setup:
    MOV     ax, 0
    MOV     ds, ax

    ; Sets up the Extra Segment to access the VGA
    ; mapped memory region (0xA0000 - 0xAFFFF).
    MOV     ax, 0xA000
    MOV     es, ax

    ; The memory region (0x7E00 - 0x17DFF) is used
    ; for the Stack Segment.
    MOV     ax, 0x7E0
    MOV     ss, ax

    MOV     ax, 0xFFFF
    MOV     bp, ax
    MOV     sp, ax

    ; Switches to 320x200 VGA mode to effectively
    ; draw the game components on the screen.
    MOV     ax, 0x0013
    INT     0x10

game_exec:
    ; Places the food and snake head block at their initial positions.
    MOV     bl, SNAKE_START
    MOV     cl, COLOR_GREEN

    CALL    draw_block
    CALL    place_food

_game_exec_loop:

    ; Compares the snake head with the food block and calls
    ; the associated handler routine if the above holds true.
    MOV     al, [snake]
    CMP     al, [food]
    JE      _capture_food

    ; Extracts the last snake block index and moves it into DI.
    MOV     di, [len]
    DEC     di

    ; Removes the last snake block to indicate movement.
    MOV     bl, snake[di]
    MOV     cl, COLOR_BLACK
    CALL    draw_block

    JMP     _fetch_keypress

_capture_food:
    ; Places another food block and increases the snake length.
    CALL    place_food
    INC     word [len]

    ; Restarts the game if the snake reaches its max length
    ; indicating a victory.
    CMP     [len], word SNAKE_MAX_LEN
    JE      game_over

_fetch_keypress:
    ; Checks for available keys in the BIOS keyboard buffer.
    MOV     ah, 1
    INT     0x16

    JZ      _update_snake   ; Skips if no keys are currently available

    ; Extracts the most recent key from the buffer.
    MOV     ah, 0
    INT     0x16

    ; Compares the extracted key with the movement keys and sets the
    ; direction using the corresponding macro if a match is found.
    cmp_key KEY_W, _set_dir_up
    cmp_key KEY_S, _set_dir_down
    cmp_key KEY_A, _set_dir_left
    cmp_key KEY_D, _set_dir_right

    JMP     _update_snake

_set_dir_up:
    set_dir DIR_LEFT_UP, DIR_NONE

_set_dir_down:
    set_dir DIR_RIGHT_DOWN, DIR_NONE

_set_dir_left:
    set_dir DIR_NONE, DIR_LEFT_UP

_set_dir_right:
    set_dir DIR_NONE, DIR_RIGHT_DOWN

_update_snake:
    ; Moves len - 1 into CX as the loop only updates the snake blocks
    ; positioned after the head, which will be calculated separately.
    MOV     cx, [len]
    DEC     cl

    ; Skips the process if the length is 1 indicating that only the
    ; new head has to be calculated.
    OR      cl, cl
    JZ      _update_snake_head

    ; The loop proceeds in reverse order moving the value from lower
    ; index (source) to the higher index (target = source + 1).

    MOV     di, snake
    ADD     di, cx  ; Pointer to the target index. Initally, the last block.

    MOV     si, di
    DEC     si  ; Pointer to the source index.

_update_snake_loop:
    MOV     al, [si]
    MOV     [di], al    ; Moves the value from source to target.

    ; Decrements the pointers to move the snake blocks with lower indices.
    DEC     di
    DEC     si

    LOOP    _update_snake_loop

_update_snake_head:
    MOV     al, [snake]
    MOV     bl, al  ; Saves the position into BL to update the X coordinate.
    
    AND     al, 0xF ; Clears the upper nibble comprising the older X coordinate.
    ADD     al, [dir_y] ; Updates the Y coordinate.

    ; Wraps the Y coordindate into the valid (0-9) range.
    CALL    wrap_y_pos

    ; Shifts the X coordinate in the lower nibble, updates it and
    ; re-positions it in the upper nibble.
    SHR     bl, 4
    ADD     bl, [dir_x]
    SHL     bl, 4

    OR      bl, al  ; Stores the final result in BL.

    MOV     [snake], bl ; Updates the snake head position in memory.

    ; Checks if the head has collided with any other snake block.
    CALL    check_collision

    ; Draws the snake head at the updated position.
    MOV     cl, COLOR_GREEN
    CALL    draw_block  ; BL already has the position of the block.

_game_delay:
    ; Creates an delay of approximately 196.6 ms to ease gameplay speed.
    MOV     ah, 0x86
    MOV     cx, 0x1
    MOV     dx, 0xFFFF
    INT     0x15

    JMP     _game_exec_loop

draw_block:
    ; Stores the block position in DL for calculation.
    MOV     dl, bl
    AND     dx, 0xF ; Extracts the lower nibble (vertical position).

    ; Skips the rows reserved for blocks prior to
    ; the current vertical position.
    MOV     ax, ROW_SIZE
    MUL     dx
    MOV     di, ax  ; Saves the result into DI

    ; Extracts the upper nibble (X coordinate), computes the
    ; offset, and adds it to DI to get the final position.
    SHR     bl, 4
    MOV     ax, BLOCK_SIZE
    MUL     bl
    ADD     di, ax  ; Final result is stored in DI

    ; Saves the color in AL to directly support loading
    ; at ES:DI, since CX will be used for loop control.
    MOV     al, cl
    MOV     cx, 20

_draw_block_loop_outer:
    ; Saves the outer loop iteration number as CX
    ; will be used for the inner loop.
    PUSH    cx
    MOV     cx, 20

_draw_block_loop_inner:
    STOSB
    LOOP    _draw_block_loop_inner

    ; Adds an offset to get back at the starting
    ; position in the next row.
    ADD     di, 300
    POP     cx  ; Restores the outer loop iteration number.

    LOOP    _draw_block_loop_outer

    RET

place_food:
    ; Extracts and uses the System Time as the pseudo random number.
    MOV     ah, 0
    INT     0x1A
    
    MOV     ax, dx  ; Stores in AX for division
    MOV     bx, dx  ; Temporarily saves a copy in BX for future usage.

    MOV     cx, 16
    XOR     dx, dx
    DIV     cx      ; Extracts the column index

    MOV     ax, bx  ; Stores the saved number in AX for division.

    ; BX is used for storing the final result. Being divided
    ; by 16, the result is ensured to fit in the lower nibble.
    MOV     bx, dx
    SHL     bx, 4   ; Moves the column index to the upper nibble.

    MOV     cx, 10
    XOR     dx, dx
    DIV     cx      ; Extracts the row index

    ; Moves the row index in the lower nibble of BX
    ; to get the final position.
    OR      bx, dx

    ; Moves the length into CX to iterate through the
    ; snake and check for conflicting positions.
    MOV     cx, [len]
    MOV     di, 0   ; Stores the current index to check

_place_food_check_loop:

    ; If the food position conflicts with any snake
    ; block position, it is re-calculated.
    CMP     bl, snake[di]
    JE      place_food

    ; Increments and loops to compare with the next snake block.
    INC     di
    LOOP    _place_food_check_loop

    MOV     [food], bl ; Stores the food position for future usage.

    ; The food is finally drawn if the extracted position is empty.
    MOV     cl, COLOR_RED
    CALL    draw_block  ; BL already has the position of the block.

    RET

wrap_y_pos:
    CMP     al, 0xA
    JE      _wrap_y_down    ; Wraps downward to 0 if overflows

    CMP     al, 0xFF
    JE      _wrap_y_up      ; Wraps upward to 9 if underflows

    RET

_wrap_y_down:
    MOV     al, 0
    RET

_wrap_y_up:
    MOV     al, 9
    RET

check_collision:
    ; Moves len - 1 as the collision is to be checked for
    ; blocks other than the head itself.
    MOV     cx, [len]
    DEC     cl

    ; Skips the process if the length is 1 as in such, the
    ; snake cannot collide with itself.
    OR      cl, cl
    JE      _check_collision_end

    MOV     di, 1   ; Stores the initial block index to check.
    MOV     al, snake[0]

_check_collision_loop:
    ; Compares the block with the head and restarts the game if equal.
    CMP     al, snake[di]
    JE      game_over

    INC     di  ; Increments to check the next index.
    LOOP    _check_collision_loop

_check_collision_end:
    RET

game_over:
    ; Resets the labels to their initial values to restart the game.
    MOV     [len], word 1
    MOV     [snake], byte SNAKE_START
    MOV     [dir_x], word 0 ; dir_x = 0, dir_y = 0

    JMP     start

len     DW  1   ; Initial length of the snake.
food    DB  0   ; Location of the food block. Initially, a garbage value.

; Stores the direction of the snake. Initally, the snake
; moves horizontally from left to right.
dir_x   DB  DIR_NONE
dir_y   DB  DIR_NONE

; Stores the position of all the snake blocks. Initially,
; only the 1st byte holds the valid position of the head.
snake:
    DB  SNAKE_START
    DB  SNAKE_MAX_LEN - 1   dup(0)

DB  510 - ($ - $$)  dup(0)
DW  0xAA55
