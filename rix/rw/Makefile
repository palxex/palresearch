CC ?= cc
CFLAGS ?= -std=c99 -O2 -Wall -Wextra
CPPFLAGS ?= -I..

SRC := rw_to_io.c
TARGET_BASE := rw_to_io

TRIPLET := $(shell $(CC) -dumpmachine 2>/dev/null || echo unknown)
IS_MINGW := $(findstring mingw,$(TRIPLET))

EXE :=
ifneq ($(IS_MINGW),)
EXE := .exe
endif

TARGET := $(TARGET_BASE)$(EXE)

RW ?= IoSDF00.rw
START ?= 0
END ?= 255
SLEEP_MS ?= 0

EFI_SRC := rw_to_io_efi.c
EFI_OBJ := rw_to_io_efi.o
EFI_SO := rw_to_io_efi.so
EFI_APP := rw_to_io.efi

EFI_ARCH ?= x86_64
GNU_EFI_DIR ?= /usr
EFI_INC := $(GNU_EFI_DIR)/include/efi
EFI_ARCH_INC := $(GNU_EFI_DIR)/include/efi/$(EFI_ARCH)
EFI_LIBDIR ?= $(GNU_EFI_DIR)/lib
EFI_CRT := $(EFI_LIBDIR)/crt0-efi-$(EFI_ARCH).o
EFI_LDS := $(EFI_LIBDIR)/elf_$(EFI_ARCH)_efi.lds

EFI_CC ?= gcc
EFI_LD ?= ld
EFI_OBJCOPY ?= objcopy
EFI_CFLAGS ?= -fpic -fshort-wchar -ffreestanding -fno-stack-protector -fno-strict-aliasing -mno-red-zone -maccumulate-outgoing-args -DEFI_FUNCTION_WRAPPER -Wall -Wextra

.PHONY: all clean run info efi efi-clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $<

run: $(TARGET)
	./$(TARGET) "$(RW)" "$(START)" "$(END)" "$(SLEEP_MS)"

efi: $(EFI_APP)

$(EFI_OBJ): $(EFI_SRC)
	$(EFI_CC) -I$(EFI_INC) -I$(EFI_ARCH_INC) $(EFI_CFLAGS) -c $< -o $@

$(EFI_SO): $(EFI_OBJ)
	$(EFI_LD) -nostdlib -znocombreloc -T $(EFI_LDS) -shared -Bsymbolic $(EFI_CRT) $< -L$(EFI_LIBDIR) -lefi -lgnuefi -o $@

$(EFI_APP): $(EFI_SO)
	$(EFI_OBJCOPY) -S \
		-j .text -j .sdata -j .data -j .dynamic -j .dynsym \
		-j .rel -j .rela -j .reloc \
		-O efi-app-$(EFI_ARCH) $< $@

info:
	@echo CC=$(CC)
	@echo TRIPLET=$(TRIPLET)
	@echo TARGET=$(TARGET)
	@echo CPPFLAGS=$(CPPFLAGS)
	@echo CFLAGS=$(CFLAGS)
	@echo EFI_APP=$(EFI_APP)
	@echo EFI_ARCH=$(EFI_ARCH)
	@echo GNU_EFI_DIR=$(GNU_EFI_DIR)

clean:
	rm -f $(TARGET_BASE) $(TARGET_BASE).exe

efi-clean:
	rm -f $(EFI_OBJ) $(EFI_SO) $(EFI_APP)
