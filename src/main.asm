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

draw_block:
    ; Stores the block position in DL for calculation.
    MOV     dl, bl
    AND     dx, 0xF ; Extracts the lower nibble (vertical position).

    ; Skips the rows reserved for blocks prior to
    ; the current vertical position.
    MOV     ax, ROW_SIZE
    MUL     dx
    MOV     di, ax

    ; Extracts the upper nibble (horizontal position), computes
    ; the offset, and adds it to DI to get the final position.
    SHR     bl, 4
    MOV     ax, BLOCK_SIZE
    MUL     bl
    ADD     di, ax

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

len     DW  1   ; Initial length of the snake.
food    DB  0   ; Location of the food block. Initially, a garbage value.

; Stores the direction of the snake. Initally, the snake
; moves horizontally from left to right.
dir_x   DB  DIR_RIGHT_DOWN
dir_y   DB  DIR_NONE

; Stores the position of all the snake blocks. Initially,
; only the 1st byte holds the valid position of the head.
snake:
    DB  SNAKE_START
    DB  SNAKE_MAX_LEN - 1   dup(0)

DB  510 - ($ - $$)  dup(0)
DW  0xAA55
