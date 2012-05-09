NAME := DisableTurboBoost
TEST := /tmp/$(NAME).kext
DIR  := Contents/MacOS
BIN  := $(DIR)/$(NAME)
INFO := Contents/Info.plist

$(BIN): $(DIR) $(NAME).c Makefile
	$(CC) -Xlinker -kext -static $(NAME).c -o $@ -fno-builtin -nostdlib -lkmod -r -mlong-branch -I/System/Library/Frameworks/Kernel.framework/Headers -Wall

$(DIR):; mkdir -p $(DIR)

test: $(TEST)/$(BIN) $(TEST)/$(INFO)
	sudo chown -R root:wheel $(TEST)
	sudo kextutil -v $(TEST)

untest: $(TEST)/$(BIN) $(TEST)/$(INFO)
	sudo kextunload -v $(TEST)

$(TEST):; mkdir -p $@
$(TEST)/$(DIR):; mkdir -p $@

$(TEST)/$(INFO): $(TEST) $(INFO)
	sudo cp $(INFO) $@

$(TEST)/$(BIN): $(TEST)/$(DIR) $(BIN)
	sudo cp $(BIN) $@
