nasm -f bin -o bootloader.bin bootloader.asm
dd status=noxfer conv=notrunc if=bootloader.bin of=main.img
qemu-system-i386 -fda bootloader.bin


