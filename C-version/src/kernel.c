#include "vga.h"

void main() {
    vga_clear_screen(0x0);
    vga_print_string(0, 0, "Hello, VGA World!", 0x0F);
}