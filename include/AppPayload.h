#ifndef APP_PAYLOAD_H
#define APP_PAYLOAD_H

#include <stdint.h>

#include "PhysicalMemory.h"
#include "Device.h"

typedef struct AppPayload {
    const uint16_t version;
    const uint16_t payload_size;
    const uint8_t* vender_name;
    const uint32_t checksum;

    const PhysicalMemoryDescription physical_memory_description;

    const DeviceDescription const* devices;
    const uint32_t device_count;
} AppPayload;

#endif