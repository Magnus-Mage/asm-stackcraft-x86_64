# Usage: make FILE=small-asm/hello-world

FILE ?= main
SRC := $(FILE).s
OBJ := $(FILE).o
OUT := $(FILE)

all:
	@echo "[*] Assembling $(SRC) -> $(OBJ)"
	gcc -c -masm=intel -o $(OBJ) $(SRC)
	@echo "[*] Linking $(OBJ) -> $(OUT)"
	gcc -nostdlib -no-pie -o $(OUT) $(OBJ)

run: all
	@echo "[*] Running ./$(OUT)"
	./$(OUT)

clean:
	@echo "[*] Cleaning"
	rm -f $(OBJ) $(OUT)

.PHONY: all run clean

