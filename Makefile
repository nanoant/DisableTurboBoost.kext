NAME := DisableTurboBoost
#KEXT := /System/Library/Extensions/$(NAME).kext
KEXT := /tmp/$(NAME).kext
DIR  := Contents/MacOS
BIN  := $(DIR)/$(NAME)
INFO := Contents/Info.plist

$(BIN): $(DIR) $(NAME).c Makefile
	$(CC) -Xlinker -kext -static $(NAME).c -o $@ -fno-builtin -nostdlib -lkmod -r -mlong-branch -I/System/Library/Frameworks/Kernel.framework/Headers -Wall

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
