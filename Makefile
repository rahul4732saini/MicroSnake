ASM	= nasm
ASM_FLAGS = -f bin

OUT_DIR = bin

TARGET = $(OUT_DIR)/snake.bin
SRC = src/main.asm

.PHONY = all clean

build: $(TARGET)

$(OUT_DIR):
	mkdir bin

$(TARGET): $(SRC) | $(OUT_DIR)
	$(ASM) $(ASM_FLAGS) -o $@ $^

clean:
	@if [ -e $(OUT_DIR) ]; then \
		rm -r $(OUT_DIR); \
	fi
