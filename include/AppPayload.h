#ifndef APP_PAYLOAD_H
#define APP_PAYLOAD_H

#include <stdint.h>

#include "PhysicalMemory.h"

typedef struct AppPayload {
    const uint16_t version;
    const uint16_t payload_size;
    const uint8_t* vender_name;
    const uint32_t checksum;

    PhysicalMemoryDescription physical_memory_description;

} AppPayload;

#endif