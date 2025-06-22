BITS    16
ORG     0x7C00

; The snake is initially placed in the center of
; the 16x10 board at x=7 and y=4 (0-indexed).

SNAKE_START     equ 0x74
SNAKE_MAX_LEN   equ 100

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

; Initial length of the snake.
len     DB  1

; Stores the position of all the snake blocks. Initially,
; only the 1st byte holds the valid position of the head.
snake:
    DB  SNAKE_START
    DB  SNAKE_MAX_LEN - 1   dup(0)

DB  510 - ($ - $$)  dup(0)
DW  0xAA55
