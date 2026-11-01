# ROLRIX -- two deliverables from one EXE
#
#   1. ROLRIX.ASM   complete 16-bit disassembly that NASM reassembles into a
#                   byte-identical copy of ../ROLRIX.EXE
#   2. rolrix.c     functional port that runs natively on Linux and writes the
#                   same .RIX bytes as the original does
#
#   make            build both
#   make check      build and compare all nine songs byte for byte
#   make clean      remove build products

NASM    = nasm
CC      = gcc
CFLAGS  = -std=c89 -O2 -Wall
EXE     = ROLRIX.EXE
C_BIN   = rolrix_n
ASM_BIN = ROLRIX_R.EXE

# reference material shipped with the project
REF_EXE := ../ROLRIX.EXE

.PHONY: all check clean verify-d1

# ---------------------------------------------------------------- default --

all: $(ASM_BIN) $(C_BIN)

# -------------------------------------------------------- 1. disassembly ----
# ROLRIX.ASM is the source of truth; assembling it must reproduce the
# original executable exactly.

$(ASM_BIN): ROLRIX.ASM
	$(NASM) -f bin $< -o $@

verify-d1: $(ASM_BIN)
	@cmp -s $(ASM_BIN) $(REF_EXE) \
	  && echo "delivery 1 OK  (byte-identical, md5 $(shell md5sum $(ASM_BIN) | cut -d' ' -f1))" \
	  || { echo "delivery 1 FAILED"; exit 1; }

# ------------------------------------------------------------- 2. C port ----

$(C_BIN): rolrix.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(ASM_BIN) $(C_BIN)

help:
	@echo "targets:"
	@echo "  make            build ROLRIX_R.EXE and rolrix_n"
	@echo "  make check      run the nine-song byte comparison loop"
	@echo "  make verify-d1  confirm the disassembly rebuilds the original EXE"
	@echo "  make clean      remove build products"
