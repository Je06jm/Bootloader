#ifndef PHYSICAL_MEMORY_H
#define PHYSICAL_MEMORY_H

#include <stdint.h>

#define PHYSICAL_MEMORY_TYPE_UNUSABLE 0
#define PHYSICAL_MEMORY_TYPE_RESERVED 1
#define PHYSICAL_MEMORY_TYPE_BOOTLOADER 2
#define PHYSICAL_MEMORY_TYPE_APPLICATION 3
#define PHYSICAL_MEMORY_TYPE_UNUSED 4

typedef struct PhysicalMemoryRegion {
    uint64_t base;
    uint64_t length;
    uint8_t type;
} PhysicalMemoryRegion;

typedef struct PhysicalMemoryDescription {
    PhysicalMemoryRegion* regions;
    uint16_t region_count;
} PhysicalMemoryDescription;

#endif