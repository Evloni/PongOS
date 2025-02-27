#ifndef STDINT_H
#define STDINT_H

// Define exact-width integer types for 8, 16, 32, and 64-bit values
typedef unsigned char uint8_t;    // 8-bit unsigned integer
typedef signed char int8_t;       // 8-bit signed integer

typedef unsigned short uint16_t;  // 16-bit unsigned integer
typedef signed short int16_t;     // 16-bit signed integer

typedef unsigned int uint32_t;    // 32-bit unsigned integer
typedef signed int int32_t;       // 32-bit signed integer

typedef unsigned long long uint64_t;  // 64-bit unsigned integer
typedef signed long long int64_t;     // 64-bit signed integer

typedef uint8_t bool;
#define true 1
#define false 0

#endif // STDINT_H
