# Cross-platform Makefile for DERIX.C and derix262.c
# Supports: Linux, MinGW, DJGPP

CC ?= gcc

DERIX_SRC := DERIX.C
DERIX262_SRC := derix262.c

DERIX_BASE ?= derix
DERIX262_BASE ?= derix262

TRIPLET := $(shell $(CC) -dumpmachine 2>/dev/null || echo unknown)

IS_DJGPP := $(findstring djgpp,$(TRIPLET))
IS_MINGW := $(findstring mingw,$(TRIPLET))

CFLAGS_COMMON := -ggdb -O0 -Wall -Wextra -x c
LDFLAGS_COMMON := -static -static-libgcc -static-libstdc++
LDLIBS_COMMON :=

ifeq ($(IS_DJGPP),djgpp)
PLATFORM := djgpp
EXE := .exe
CFLAGS_PLATFORM :=
LDFLAGS_PLATFORM :=
LDLIBS_PLATFORM :=
else ifneq ($(IS_MINGW),)
PLATFORM := mingw
EXE := .exe
CFLAGS_PLATFORM := -pthread
LDFLAGS_PLATFORM :=
LDLIBS_PLATFORM :=
else
PLATFORM := linux
EXE :=
CFLAGS_PLATFORM := -pthread
LDFLAGS_PLATFORM :=
LDLIBS_PLATFORM :=
endif

CFLAGS := $(CFLAGS_COMMON) $(CFLAGS_PLATFORM)
LDFLAGS := $(LDFLAGS_COMMON) $(LDFLAGS_PLATFORM)
LDLIBS := $(LDLIBS_COMMON) $(LDLIBS_PLATFORM)

DERIX_TARGET := $(DERIX_BASE)$(EXE)
DERIX262_TARGET := $(DERIX262_BASE)$(EXE)
TARGETS := $(DERIX_TARGET) $(DERIX262_TARGET)

DERIX262_LDLIBS := $(LDLIBS) -lm

.PHONY: all clean info

all: $(TARGETS)

$(DERIX_TARGET): $(DERIX_SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)
	sudo setcap cap_sys_rawio+ep $@

$(DERIX262_TARGET): $(DERIX262_SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(DERIX262_LDLIBS)
	sudo setcap cap_sys_rawio+ep $@

info:
	@echo CC=$(CC)
	@echo TRIPLET=$(TRIPLET)
	@echo PLATFORM=$(PLATFORM)
	@echo TARGETS=$(TARGETS)
	@echo CFLAGS=$(CFLAGS)
	@echo LDFLAGS=$(LDFLAGS)
	@echo LDLIBS=$(LDLIBS)

clean:
	rm -f $(DERIX_BASE) $(DERIX_BASE).exe $(DERIX262_BASE) $(DERIX262_BASE).exe
