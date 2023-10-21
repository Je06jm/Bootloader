#ifndef DEVICE_H
#define DEVICE_H

#include <stdint.h>

typedef struct DeviceDescription {

} DeviceDescription;

typedef struct Device {
    const DeviceDescription* description;
    const uint64_t memory;
} Device;


#endif