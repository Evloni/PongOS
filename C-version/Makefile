# Compiler and linker settings
CC = gcc
LD = ld
NASM = nasm
OBJCOPY = objcopy
QEMU = qemu-system-i386

# Compiler flags
CFLAGS = -m32 -ffreestanding -fno-pie -nostdlib -Wall -Wextra -O2
CFLAGS_DEBUG = $(CFLAGS) -g -O0

# Assembler flags
ASMFLAGS = -f bin
ASMFLAGS_ELF = -f elf32

# Linker flags
LDFLAGS = -m elf_i386 -nostdlib -T linker.ld

# Directories
SRC_DIR = src
BUILD_DIR = build

# Files
BOOTLOADER = $(SRC_DIR)/bootloader.asm
KERNEL_ENTRY = $(SRC_DIR)/kernel_entry.asm
KERNEL_C = $(SRC_DIR)/kernel.c
VGA_C = $(SRC_DIR)/vga.c

# Output files
BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_ENTRY_OBJ = $(BUILD_DIR)/kernel_entry.o
KERNEL_OBJ = $(BUILD_DIR)/kernel.o
VGA_OBJ = $(BUILD_DIR)/vga.o
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
DISK_IMG = disk.img

# Default target
all: setup $(DISK_IMG) run

# Create build directory
setup:
	mkdir -p $(BUILD_DIR)

# Create disk image
$(DISK_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	# Create a new disk image (10MB)
	dd if=/dev/zero of=$(DISK_IMG) bs=1M count=10
	# Write the bootloader to the first sector
	dd if=$(BOOTLOADER_BIN) of=$(DISK_IMG) bs=512 conv=notrunc
	# Write the kernel starting from the second sector (sector 2)
	dd if=$(KERNEL_BIN) of=$(DISK_IMG) bs=512 seek=1 conv=notrunc

# Compile bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER)
	$(NASM) $(ASMFLAGS) -o $(BOOTLOADER_BIN) $(BOOTLOADER)

# Compile kernel entry
$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY)
	$(NASM) $(ASMFLAGS_ELF) -o $(KERNEL_ENTRY_OBJ) $(KERNEL_ENTRY)

# Compile VGA driver
$(VGA_OBJ): $(VGA_C)
	$(CC) $(CFLAGS) -c $(VGA_C) -o $(VGA_OBJ)

# Compile kernel C code
$(KERNEL_OBJ): $(KERNEL_C)
	$(CC) $(CFLAGS) -c $(KERNEL_C) -o $(KERNEL_OBJ)

# Link kernel
$(KERNEL_ELF): $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ) $(VGA_OBJ)
	$(LD) $(LDFLAGS) -o $(KERNEL_ELF) $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ) $(VGA_OBJ)

# Convert kernel to binary
$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)

# Run in QEMU
run: $(DISK_IMG)
	$(QEMU) -drive file=$(DISK_IMG),format=raw -monitor stdio

# Run with debugging support
debug: CFLAGS = $(CFLAGS_DEBUG)
debug: clean all
	$(QEMU) -drive file=$(DISK_IMG),format=raw -s -S -monitor stdio

# Clean build files
clean:
	rm -rf $(BUILD_DIR) *.bin *.o *.img *.elf

.PHONY: all setup run debug clean
