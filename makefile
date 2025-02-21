ASM=fasm

SRC_DIR = src

BUILD_DIR = build


os: clean bootloader pong floppy_image run

bootloader: $(BUILD_DIR)/bootloader.bin
$(BUILD_DIR)/bootloader.bin:
	$(ASM) $(SRC_DIR)/bootloader.asm $(BUILD_DIR)/bootloader.bin

pong: $(BUILD_DIR)/pong.bin
$(BUILD_DIR)/pong.bin:
	$(ASM) $(SRC_DIR)/pong.asm $(BUILD_DIR)/pong.bin

floppy_image: $(BUILD_DIR)/main.img
$(BUILD_DIR)/main.img: bootloader
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/pong.bin of=$(BUILD_DIR)/main.img bs=512 seek=1 conv=notrunc
	
	
run:
	qemu-system-i386 -fda ./build/main.img



clean:
	rm -rf ./build/*