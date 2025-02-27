#include "vga.h"

// Pointer to the start of the VGA buffer
volatile vga_char_t* const vga_buffer = (vga_char_t*)VGA_ADDRESS;

// Function to write a character at a specific position
void vga_write_char(int x, int y, char character, unsigned char color) {
    // Calculate the position in the buffer
    int index = y * VGA_WIDTH + x;
    // Set the character and its attribute (color)
    vga_buffer[index].character = character;
    vga_buffer[index].attribute = color;
}

// Function to clear the screen
void vga_clear_screen(unsigned char color) {
    for (int y = 0; y < VGA_HEIGHT; ++y) {
        for (int x = 0; x < VGA_WIDTH; ++x) {
            vga_write_char(x, y, ' ', color);
        }
    }
}

// Function to print a string to the screen
void vga_print_string(int x, int y, const char* string, unsigned char color) {
    while (*string) {
        vga_write_char(x, y, *string, color);
        ++x;
        if (x >= VGA_WIDTH) {
            x = 0;
            ++y;
        }
        ++string;
    }
}
