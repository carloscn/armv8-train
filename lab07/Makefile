ifeq ($(shell uname),Darwin)
PLATFORM="MacOS"
ARMGNU ?= aarch64-none-elf
else
PLATFORM="Unix-Like"
ARMGNU ?= aarch64-linux-gnu
endif

board ?= rpi4

ifeq ($(board), rpi3)
COPS += -DCONFIG_BOARD_PI3B
QEMU_FLAGS  += -machine raspi3
else ifeq ($(board), rpi4)
COPS += -DCONFIG_BOARD_PI4B
ifeq ($(shell uname),Darwin)
QEMU_FLAGS  += -machine raspi4b2g
else
QEMU_FLAGS  += -machine raspi4
endif
endif

COPS += -g -Wall -nostdlib -nostdinc -Iinclude
ASMOPS = -g -Iinclude

BUILD_DIR = build
SRC_DIR = src

all : benos.bin
	@echo $(PLATFORM)

clean :
	rm -rf $(BUILD_DIR) *.bin *.elf

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@

C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

benos.bin: $(SRC_DIR)/linker.ld $(OBJ_FILES)
	$(ARMGNU)-ld -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/benos.elf  $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/benos.elf -O binary benos.bin
	cp $(BUILD_DIR)/benos.elf benos.elf

QEMU_FLAGS  += -nographic

run: benos.bin benos.elf
	@echo $(PLATFORM)
	qemu-system-aarch64 $(QEMU_FLAGS) -kernel benos.bin

debug: benos.bin benos.elf
	@echo $(PLATFORM)
	qemu-system-aarch64 $(QEMU_FLAGS) -kernel benos.bin -S -s

ifeq ($(shell uname),Darwin)
cmd_qemu = aarch64-none-elf-gdb --tui benos.elf -x gdb_qemu.sh
cmd_jlink = aarch64-none-elf-gdb --tui benos.elf -x gdb_jlink.sh
else
cmd_qemu = gdb-multiarch --tui benos.elf -x gdb_qemu.sh
cmd_jlink = gdb-multiarch --tui benos.elf -x gdb_jlink.sh
endif

gdbq:
	$(cmd_qemu)
gdbj:
	$(cmd_jlink)
