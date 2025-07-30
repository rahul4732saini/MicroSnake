ASM	= nasm
ASM_FLAGS = -f bin

OUT_DIR = bin

BIN = $(OUT_DIR)/snake.bin
SRC = src/main.asm

.PHONY = all clean

build: $(BIN)

$(OUT_DIR):
	mkdir bin

$(BIN): $(SRC) | $(OUT_DIR)
	$(ASM) $(ASM_FLAGS) -o $@ $^

clean:
	@if [ -e $(OUT_DIR) ]; then \
		rm -r $(OUT_DIR); \
	fi
