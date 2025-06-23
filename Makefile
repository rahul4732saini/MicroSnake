ASM	= nasm
ASM_FLAGS = -f bin

BIN = bin/snake.bin
SRC = src/main.asm

build: $(BIN)

$(BIN): $(SRC)
	mkdir -p bin
	$(ASM) $(ASM_FLAGS) -o $@ $^

clean:
	rm -r bin
