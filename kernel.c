#include <stddef.h>
#include <stdint.h>

volatile uint32_t** core_1 = (void*)0xE0;
volatile uint32_t** core_2 = (void*)0xE8;
volatile uint32_t** core_3 = (void*)0xF0;


void _start_core_1(void* addr) {
    *core_1 = (uint32_t*)addr;
}


void _start_core_2(void* addr) {
    *core_2 = (uint32_t*)addr;
}


void _start_core_3(void* addr) {
    *core_3 = (uint32_t*)addr;
}


void kernel_main(uint64_t dtb_ptr32, uint64_t x1, uint64_t x2, uint64_t x3) {
    return;
}
