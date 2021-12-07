NAME := DisableTurboBoost
#KEXT := /System/Library/Extensions/$(NAME).kext
KEXT := /tmp/$(NAME).kext
DIR  := Contents/MacOS
BIN  := $(DIR)/$(NAME)
INFO := Contents/Info.plist

# detect current kernel architecture
CPU  := $(shell uname -m)
ifeq ($(CPU),i386)
CPPFLAGS += -m32
else
ifeq ($(CPU),x86_64)
CPPFLAGS += -m64
endif
endif

KERNELDIR := $(shell xcrun --sdk macosx --show-sdk-path)/System/Library/Frameworks/Kernel.framework/Headers

$(BIN): $(DIR) $(NAME).c Makefile
	$(CC) $(CFLAGS) $(CPPFLAGS) $(MARCH) -Xlinker -kext --include-directory=$(KERNELDIR) -static $(NAME).c -o $@ -fno-builtin -nostdlib -lkmod -r -Wall

$(DIR):; mkdir -p $(DIR)

load: $(KEXT) $(KEXT)/$(BIN) $(KEXT)/$(INFO)
	sudo chown -R root:wheel $(KEXT)
	sudo kextutil -v $(KEXT)

unload:
	sudo kextunload -v $(KEXT)

$(KEXT):; mkdir -p $@
$(KEXT)/$(DIR):; mkdir -p $@

$(KEXT)/$(INFO): $(KEXT) $(INFO)
	sudo cp $(INFO) $@

$(KEXT)/$(BIN): $(KEXT)/$(DIR) $(BIN)
	sudo cp $(BIN) $@
