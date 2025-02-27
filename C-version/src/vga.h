#ifndef VGA_H
#define VGA_H

// VGA text mode buffer is located at 0xB8000
#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// Structure to represent a VGA character (character and its attribute)
typedef struct {
    unsigned char character;
    unsigned char attribute;
} vga_char_t;

// Define some simple colors for text attributes
#define VGA_COLOR_BLACK 0x0
#define VGA_COLOR_LIGHT_GRAY 0x7
#define VGA_COLOR_WHITE 0xF

// Pointer to the start of the VGA buffer
extern volatile vga_char_t* const vga_buffer;

// Function prototypes
void vga_write_char(int x, int y, char character, unsigned char color);
void vga_clear_screen(unsigned char color);
void vga_print_string(int x, int y, const char* string, unsigned char color);

#endif // VGA_H
