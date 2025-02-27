#include "vga.h"
#include "stdint.h"
#define FULL_BLOCK 0xDB
// Define the key codes (scan codes) for W and S keys
#define KEY_W    0x11  // Scan code for 'W'
#define KEY_S    0x1F  // Scan code for 'S'

// Define the timer interrupt frequency
#define TIMER_FREQUENCY 100  // 10 ms = 100 Hz for smoother timing

// Set the timer divisor to achieve 10 ms interrupt
#define TIMER_DIVISOR (1193180 / TIMER_FREQUENCY)  // 1193180 Hz is the PIT clock

// Variable to track time intervals
volatile uint32_t ticks = 0;
volatile uint32_t delay_counter = 0;
volatile uint32_t random_seed = 0;  // Seed for random number generation

// Function to output a byte to an I/O port
static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

// Function to input a byte from an I/O port
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// Simple random number generator
uint32_t rand() {
    random_seed = (random_seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return random_seed;
}

// Get a random number within a range
int rand_range(int min, int max) {
    return min + (rand() % (max - min + 1));
}

// Function to set a random ball position and direction
void randomize_ball(int* ball_x, int* ball_y, int* ball_dx, int* ball_dy) {
    // Set random position in the middle third of the screen
    *ball_x = rand_range(VGA_WIDTH / 3, 2 * VGA_WIDTH / 3);
    *ball_y = rand_range(5, VGA_HEIGHT - 5);
    
    // Random direction (left or right)
    *ball_dx = (rand() % 2) ? 1 : -1;
    
    // Random vertical direction (up or down)
    *ball_dy = (rand() % 2) ? 1 : -1;
}

// Function to draw a number on the screen
void draw_number(int x, int y, int number, unsigned char color) {
    char digit = '0' + (number % 10);
    vga_write_char(x, y, digit, color);
    
    if (number >= 10) {
        digit = '0' + ((number / 10) % 10);
        vga_write_char(x-1, y, digit, color);
    }
}

void draw_filled_paddle(int x, int y) {
    for (int i = 0; i < 5; i++) {
        vga_write_char(x, y + i, FULL_BLOCK, 0x0F);
    }
}

void draw_filled_ball(int x, int y) {
    vga_write_char(x, y, FULL_BLOCK, 0x0F);
}

// Simple delay function using a busy-wait loop
void delay(uint32_t milliseconds) {
    // Each iteration takes roughly 1 microsecond on a modern CPU
    // So we multiply by 1000 to get milliseconds
    uint32_t count = milliseconds * 10000;  // Increased by 10x for slower speed
    for (uint32_t i = 0; i < count; i++) {
        // This empty loop will be a busy-wait
        __asm__ volatile ("nop");
    }
}

void setup_timer() {
    // Send the command byte to the PIT (Programmable Interval Timer)
    outb(0x43, 0x36);  // Command: square wave, mode 3, LSB first, MSB first

    // Set the timer divisor (10 ms delay)
    outb(0x40, (uint8_t)(TIMER_DIVISOR & 0xFF));  // Low byte
    outb(0x40, (uint8_t)((TIMER_DIVISOR >> 8) & 0xFF));  // High byte
}

// Check if a key is pressed using direct port I/O
int key_pressed() {
    return (inb(0x64) & 0x01);  // Check if there's data in the keyboard buffer
}

// Read a key from the keyboard buffer
char read_key() {
    if (key_pressed()) {
        uint8_t scancode = inb(0x60);  // Read the scancode from port 0x60
        return scancode;
    }
    return 0;
}

// Move paddle up/down based on key press
void handle_keyboard_input(int* paddle_y) {
    if (key_pressed()) {
        char key = read_key();
        if (key == KEY_W && *paddle_y > 0) {
            (*paddle_y)--;  // Move paddle up with W key
        }
        if (key == KEY_S && *paddle_y < VGA_HEIGHT - 5) {
            (*paddle_y)++;  // Move paddle down with S key
        }
    }
}

// Function to draw a striped line in the middle of the screen
void draw_center_line() {
    // Use the same filled block character as paddles and ball
    char line_char = FULL_BLOCK;  // Full block character
    unsigned char line_color = 0x0F;  // White color (same as paddles and ball)
    
    // Draw a dashed line down the center of the screen
    for (int y = 0; y < VGA_HEIGHT; y++) {
        // Skip every other position to create a dashed/striped effect
        if (y % 2 == 0) {
            vga_write_char(VGA_WIDTH / 2, y, line_char, line_color);
        }
    }
}

void main() {
    int ball_x = 40, ball_y = 12;
    int ball_dx = 1, ball_dy = 1;
    int paddle1_y = 10, paddle2_y = 10;  // Example positions for paddles
    int frame_counter = 0;  // Counter to slow down ball movement
    int player1_score = 0;  // Score for player 1
    int player2_score = 0;  // Score for player 2
    int paddle_size = 5;    // Size of the paddle

    // Initialize random seed using timer value
    random_seed = 12345;  // Starting seed
    
    // Setup the timer
    setup_timer();

    // Clear the screen at the start
    vga_clear_screen(0x0);

    // Draw initial scores
    draw_number(VGA_WIDTH/2 - 5, 2, player1_score, 0x0F);
    draw_number(VGA_WIDTH/2 + 5, 2, player2_score, 0x0F);
    
    // Draw the center line
    draw_center_line();
    
    // Set random initial ball position and direction
    randomize_ball(&ball_x, &ball_y, &ball_dx, &ball_dy);

    // Main game loop
    while (1) {
        // Handle keyboard input for paddle movement
        if (key_pressed()) {
            char key = read_key();
            if (key == KEY_W && paddle1_y > 0) {
                paddle1_y--;  // Move paddle up with W key
            }
            if (key == KEY_S && paddle1_y < VGA_HEIGHT - paddle_size) {
                paddle1_y++;  // Move paddle down with S key
            }
        }
        
        // Simple AI for right paddle (follows the ball)
        // Only move the AI paddle every 3 frames for slower movement
        if (frame_counter % 3 == 0) {
            // Make AI slightly imperfect by adding a small offset
            int target_y = ball_y - 2;
            
            if (target_y + 2 < paddle2_y && paddle2_y > 0) {
                paddle2_y--;
            } else if (target_y + 2 > paddle2_y && paddle2_y < VGA_HEIGHT - paddle_size) {
                paddle2_y++;
            }
        }

        // Clear previous ball position, but don't clear the center line
        if (ball_x != VGA_WIDTH / 2) {
            // Only clear if not on the center line
            vga_write_char(ball_x, ball_y, ' ', 0x0);
        } else {
            // If on center line, redraw the center line at this position if needed
            if (ball_y % 2 == 0) {
                vga_write_char(ball_x, ball_y, FULL_BLOCK, 0x0F);
            } else {
                vga_write_char(ball_x, ball_y, ' ', 0x0);
            }
        }

        // Store previous ball position for collision detection
        int prev_ball_x = ball_x;
        int prev_ball_y = ball_y;

        // Update ball position only every 2 frames for slower movement
        if (frame_counter % 2 == 0) {
            ball_x += ball_dx;
            ball_y += ball_dy;
        }

        // Ball bounce logic (on top and bottom borders)
        if (ball_y <= 0) {
            ball_y = 0;
            ball_dy = 1;  // Force ball to go down
        } 
        else if (ball_y >= VGA_HEIGHT - 1) {
            ball_y = VGA_HEIGHT - 1;
            ball_dy = -1;  // Force ball to go up
        }
        
        // Enhanced ball bounce logic (on paddles)
        // Left paddle collision
        if (ball_x <= 1 && prev_ball_x > 1 && ball_y >= paddle1_y && ball_y < paddle1_y + paddle_size) {
            // Calculate where on the paddle the ball hit (0 to 4)
            int hit_position = ball_y - paddle1_y;
            
            // Change ball direction based on where it hit the paddle
            ball_dx = 1;  // Always bounce to the right
            ball_x = 1;   // Ensure ball doesn't get stuck in paddle
            
            // Adjust vertical direction based on hit position
            if (hit_position < 2) {
                // Hit top part of paddle - go up
                ball_dy = -1;
            } else if (hit_position > 2) {
                // Hit bottom part of paddle - go down
                ball_dy = 1;
            } else {
                // Hit middle of paddle - keep current vertical direction
                // but make it slightly random
                if ((frame_counter % 2) == 0) {
                    ball_dy = -ball_dy;
                }
            }
        }
        // Right paddle collision
        else if (ball_x >= VGA_WIDTH - 2 && prev_ball_x < VGA_WIDTH - 2 && 
                ball_y >= paddle2_y && ball_y < paddle2_y + paddle_size) {
            // Calculate where on the paddle the ball hit (0 to 4)
            int hit_position = ball_y - paddle2_y;
            
            // Change ball direction based on where it hit the paddle
            ball_dx = -1;  // Always bounce to the left
            ball_x = VGA_WIDTH - 2;  // Ensure ball doesn't get stuck in paddle
            
            // Adjust vertical direction based on hit position
            if (hit_position < 2) {
                // Hit top part of paddle - go up
                ball_dy = -1;
            } else if (hit_position > 2) {
                // Hit bottom part of paddle - go down
                ball_dy = 1;
            } else {
                // Hit middle of paddle - keep current vertical direction
                // but make it slightly random
                if ((frame_counter % 2) == 0) {
                    ball_dy = -ball_dy;
                }
            }
        }
        
        // Ball out of bounds (reset and update score)
        if (ball_x < 0) {
            // Player 2 scores
            player2_score++;
            
            // Update score display
            vga_write_char(VGA_WIDTH/2 + 5, 2, ' ', 0x0);
            draw_number(VGA_WIDTH/2 + 5, 2, player2_score, 0x0F);
            
            // Reset ball with random position and direction
            randomize_ball(&ball_x, &ball_y, &ball_dx, &ball_dy);
            // Force direction to the right after player 2 scores
            ball_dx = 1;
            
            // Redraw the center line (it might have been overwritten)
            draw_center_line();
            
            // Small pause after scoring
            delay(20000);
        }
        else if (ball_x >= VGA_WIDTH) {
            // Player 1 scores
            player1_score++;
            
            // Update score display
            vga_write_char(VGA_WIDTH/2 - 5, 2, ' ', 0x0);
            draw_number(VGA_WIDTH/2 - 5, 2, player1_score, 0x0F);
            
            // Reset ball with random position and direction
            randomize_ball(&ball_x, &ball_y, &ball_dx, &ball_dy);
            // Force direction to the left after player 1 scores
            ball_dx = -1;
            
            // Redraw the center line (it might have been overwritten)
            draw_center_line();
            
            // Small pause after scoring
            delay(20000);
        }

        // Draw the ball at the new position
        draw_filled_ball(ball_x, ball_y);
        
        // Redraw the center line if the ball is at the center
        if (ball_x == VGA_WIDTH / 2 && ball_y % 2 == 0) {
            // The ball and line are both white blocks, so they'll appear the same
        }

        // Draw paddles (filled)
        for (int y = 0; y < VGA_HEIGHT; y++) {
            if (y >= paddle1_y && y < paddle1_y + paddle_size) {
                vga_write_char(0, y, FULL_BLOCK, 0x0F);  // Left paddle
            } else {
                vga_write_char(0, y, ' ', 0x0);  // Clear other positions
            }
            
            if (y >= paddle2_y && y < paddle2_y + paddle_size) {
                vga_write_char(VGA_WIDTH - 1, y, FULL_BLOCK, 0x0F);  // Right paddle
            } else {
                vga_write_char(VGA_WIDTH - 1, y, ' ', 0x0);  // Clear other positions
            }
        }

        // Increment frame counter
        frame_counter++;
        if (frame_counter >= 6) {
            frame_counter = 0;
        }

        // Delay for frame timing (simple busy-wait)
        delay(10500);  // Increased to 100 ms delay (10 FPS)
    }
}