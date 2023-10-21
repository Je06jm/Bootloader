#ifndef DRIVE_H
#define DRIVE_H

#include "Device.h"

typedef struct Partition {
    const uint64_t lba_start;
    const uint64_t lba_count;
} Partition;

typedef struct Drive {
    const Device* device;
    const Partition* partitions;
    const uint32_t partition_count;
} Drive;

#endif