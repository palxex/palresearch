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
DERIX_SDL2_TARGET := $(DERIX_BASE)_sdl2$(EXE)
DERIX_SDL3_TARGET := $(DERIX_BASE)_sdl3$(EXE)

SDL2_CFLAGS ?= $(shell sdl2-config --cflags 2>/dev/null)
SDL2_LIBS ?= $(shell sdl2-config --libs 2>/dev/null)
SDL3_CFLAGS ?= $(shell pkg-config --cflags sdl3 2>/dev/null)
SDL3_LIBS ?= $(shell pkg-config --libs sdl3 2>/dev/null)

DERIX262_LDLIBS := $(LDLIBS) -lm

.PHONY: all clean info derix-sdl2 derix-sdl3

all: $(TARGETS)

$(DERIX_TARGET): $(DERIX_SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)
	sudo setcap cap_sys_rawio+ep $@

$(DERIX262_TARGET): $(DERIX262_SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(DERIX262_LDLIBS)
	sudo setcap cap_sys_rawio+ep $@

$(DERIX_SDL2_TARGET): $(DERIX_SRC)
	$(CC) $(CFLAGS) $(SDL2_CFLAGS) -DUSE_SDL2_TIMER $(LDFLAGS) -o $@ $< $(LDLIBS) $(SDL2_LIBS)

$(DERIX_SDL3_TARGET): $(DERIX_SRC)
	$(CC) $(CFLAGS) $(SDL3_CFLAGS) -DUSE_SDL3_TIMER $(LDFLAGS) -o $@ $< $(LDLIBS) $(SDL3_LIBS)

derix-sdl2: $(DERIX_SDL2_TARGET)

derix-sdl3: $(DERIX_SDL3_TARGET)

info:
	@echo CC=$(CC)
	@echo TRIPLET=$(TRIPLET)
	@echo PLATFORM=$(PLATFORM)
	@echo TARGETS=$(TARGETS)
	@echo DERIX_SDL2_TARGET=$(DERIX_SDL2_TARGET)
	@echo DERIX_SDL3_TARGET=$(DERIX_SDL3_TARGET)
	@echo CFLAGS=$(CFLAGS)
	@echo LDFLAGS=$(LDFLAGS)
	@echo LDLIBS=$(LDLIBS)

clean:
	rm -f $(DERIX_BASE) $(DERIX_BASE).exe $(DERIX262_BASE) $(DERIX262_BASE).exe $(DERIX_BASE)_sdl2 $(DERIX_BASE)_sdl2.exe $(DERIX_BASE)_sdl3 $(DERIX_BASE)_sdl3.exe
