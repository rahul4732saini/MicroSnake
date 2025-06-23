BITS    16
ORG     0x7C00

; The snake is initially placed in the center of
; the 16x10 board at x=7 and y=4 (0-indexed).

SNAKE_START     equ 0x74
SNAKE_MAX_LEN   equ 100

; Display component sizes are stored in pixels.
BLOCK_SIZE      equ 20
ROW_SIZE        equ 320 * BLOCK_SIZE    ; 320 (screen width) x 20 (Block Size)

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

; Initial length of the snake.
len     DB  1

; Stores the position of all the snake blocks. Initially,
; only the 1st byte holds the valid position of the head.
snake:
    DB  SNAKE_START
    DB  SNAKE_MAX_LEN - 1   dup(0)

DB  510 - ($ - $$)  dup(0)
DW  0xAA55
