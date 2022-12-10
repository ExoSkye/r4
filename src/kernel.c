#include <stddef.h>
#include <stdint.h>
#include "mmio.h"
#include "uart.h"

volatile uint64_t** core_1 = (void*)0xE0;
volatile uint64_t** core_2 = (void*)0xE8;
volatile uint64_t** core_3 = (void*)0xF0;


void _start_core_1(void* addr) {
    *core_1 = (uint64_t*)addr;
}


void _start_core_2(void* addr) {
    *core_2 = (uint64_t*)addr;
}


void _start_core_3(void* addr) {
    *core_3 = (uint64_t*)addr;
}

void kernel_main(uint64_t dtb_ptr32, uint64_t x1, uint64_t x2, uint64_t x3) {
    uint32_t reg;
    char *board;

    asm volatile ("mrs %x0, midr_el1" : "=r" (reg));

    switch ((reg >> 4) & 0xFFF) {
        case 0xD03:
            board = "Raspberry Pi 3\0";
            MMIO_BASE = 0x3F000000;
            break;
        case 0xD08:
            board = "Raspberry Pi 4\0";
            MMIO_BASE = 0xFE000000;
            break;
    }
    uart_init();
    uart_puts(board);
    
    return;
}
