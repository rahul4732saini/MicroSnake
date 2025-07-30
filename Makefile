ASM	= nasm
ASM_FLAGS = -f bin

OUT_DIR = bin

BIN = $(OUT_DIR)/snake.bin
SRC = src/main.asm

.PHONY = all clean

build: $(BIN)

$(BIN): $(SRC)
	mkdir -p bin
	$(ASM) $(ASM_FLAGS) -o $@ $^

clean:
	@if [ -e $(OUT_DIR) ]; then \
		rm -r $(OUT_DIR); \
	fi
