#ifndef VIRTUAL_MEMORY_H
#define VIRTUAL_MEMORY_H

#include <stdint.h>

#include "PhysicalMemory.h"

#define VIRTUAL_MEMORY_PROPERTY_SYSTEM (1<<0)

typedef struct VirtualMemoryRegion {
    uint64_t base;
    uint64_t length;
    uint64_t properties;
};

typedef struct VirtualMemoryDescription {
    VirtualMemoryRegion virtual_region;
    PhysicalMemoryDescription* physical_regions;
    uint16_t physical_region_count;
} VirtualMemoryDescription;

struct VirtualMemoryManager {
    const VirtualMemoryDescription description;
};

#endif