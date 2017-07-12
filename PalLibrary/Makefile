OSNAME = $(shell uname -s)

SHAREDLIBLINKEXT = .so
ifeq ($(OS),Windows_NT)
    SHAREDLIBLINKEXT = .dll
else
    ifeq ($(OSNAME),Darwin)
        SHAREDLIBLINKEXT = .dylib
        SHAREDLIBLDFLAGS += -flat_namespace -undefined suppress
    endif
endif

TARGET=libpallib$(SHAREDLIBLINKEXT)

CPPFILES = $(wildcard src/*.cpp)
CPPFILES := $(filter-out src/mov.cpp, $(CPPFILES)) #not complete?
OBJFILES = $(CPPFILES:.cpp=.o)

CFLAGS = -Iinclude
CPPFLAGS = $(CFLAGS)
LDFLAGS = -g -O2 $(DYLIB)

all: $(TARGET)

clean:
	$(RM) $(TARGET) $(OBJFILES)

.cpp.o:
	@echo CXX $@
	@$(CXX) $(CPPFLAGS) -c $< -fPIC -o $@

$(TARGET): $(OBJFILES)
	@echo LD $@
	@$(CXX) $(LDFLAGS) $^ -dynamiclib -o $@