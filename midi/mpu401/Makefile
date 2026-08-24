NASM   ?= nasm
PYTHON ?= python3

ASM  = mpu401.asm
BIN  = mpu401.drv

.PHONY: all gen full verify clean

all: $(BIN)

$(BIN): $(ASM) $(ORIG)
	$(NASM) -f bin -o $@ $(ASM)

clean:
	rm -f $(BIN)
