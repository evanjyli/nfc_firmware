# NFC Firmware for TRF7970A BoosterPack

This repository contains firmware for NFC communication using the TI TRF7970A BoosterPack, designed for bringup and integration with SCUM (Single-Chip Universal Microcontroller) systems. The firmware supports TiLelink protocol for high-speed chip-to-chip communication.

## Table of Contents
- [Overview](#overview)
- [Hardware Requirements](#hardware-requirements)
- [TRF7970A BoosterPack](#trf7970a-boosterpack)
- [TiLelink Functionality](#tilelink-functionality)
- [Architecture](#architecture)
- [Setup and Configuration](#setup-and-configuration)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)
- [References](#references)

## Overview

The TRF7970A is a fully integrated 13.56 MHz RFID/NFC transceiver IC that supports multiple NFC/RFID protocols including:
- ISO14443A/B
- ISO15693
- ISO18092 (NFC peer-to-peer)
- FeliCa

This firmware provides a complete software stack for:
- NFC tag reading and writing
- Peer-to-peer NFC communication
- Card emulation mode
- Integration with TiLelink protocol for system-on-chip communication

## Hardware Requirements

### TRF7970A BoosterPack
- **Part Number**: TRF7970ATB
- **Interface**: SPI (Serial Peripheral Interface)
- **Operating Voltage**: 3.3V
- **Operating Frequency**: 13.56 MHz
- **Supported Standards**: ISO14443A/B, ISO15693, ISO18092, FeliCa
- **GPIO Requirements**: 
  - SPI pins (MOSI, MISO, SCLK, CS)
  - IRQ line (interrupt request)
  - Enable pin
  - MOD pin (optional, for external modulation)

### Host Controller
- Compatible with any microcontroller supporting:
  - SPI interface (up to 8 MHz)
  - GPIO interrupt handling
  - TiLelink protocol support (for SoC integration)

### Antenna
- 13.56 MHz NFC antenna (included with BoosterPack or custom design)
- Typical impedance: 50 Ω
- Recommended antenna size: 40mm x 40mm for optimal range

## TRF7970A BoosterPack

### Features
The TRF7970A BoosterPack provides:
- **Multi-protocol Support**: Automatic protocol detection and switching
- **Low Power Modes**: Multiple power-saving states
- **High Performance**: Read range up to 50mm (depending on antenna and tag)
- **Flexible Configuration**: Adjustable RF power levels and modulation settings
- **Built-in CRC**: Hardware CRC calculation for ISO protocols
- **FIFO Buffer**: 127-byte buffer for data transmission

### Pin Configuration
```
TRF7970A BoosterPack Pin Mapping:
- P1.1: IRQ (Interrupt Request)
- P1.2: SYS_CLK (System Clock)
- P1.3: MOSI (Master Out Slave In)
- P1.4: MISO (Master In Slave Out)
- P1.5: SCLK (SPI Clock)
- P1.6: CS (Chip Select)
- P2.1: EN (Enable)
- P2.2: EN2 (Secondary Enable)
- P2.3: MOD (Modulation)
```

### Communication Protocol
The TRF7970A uses SPI for host communication:
- **Mode**: SPI Mode 1 (CPOL=0, CPHA=1)
- **Clock Speed**: Up to 8 MHz
- **Byte Order**: MSB first
- **Command Format**: 
  - Direct commands: Single byte
  - Register access: Address byte + data byte(s)
  - Continuous mode available for bulk transfers

## TiLelink Functionality

### Overview
TiLelink is a chip-scale interconnect protocol designed for high-performance, low-latency communication between hardware blocks. This firmware integrates TiLelink support to enable:
- Direct memory-mapped access to NFC controller registers
- Low-latency interrupt delivery
- DMA-based data transfer for NFC payloads
- System-on-chip integration without external microcontroller

### TiLelink Integration Architecture
```
┌─────────────────┐      TiLelink      ┌──────────────────┐
│   Host Core/    │◄────────────────────►│  NFC Controller  │
│   TiLelink      │    Memory-Mapped    │   (TRF7970A      │
│   Master        │      Interface      │    Wrapper)      │
└─────────────────┘                     └──────────────────┘
                                               │
                                               │ SPI
                                               ▼
                                        ┌─────────────┐
                                        │  TRF7970A   │
                                        │  BoosterPack│
                                        └─────────────┘
```

### TiLelink Features Implemented
1. **Memory-Mapped Register Access**
   - Base address configurable
   - 32-bit aligned register interface
   - Support for TL-UL (Uncached Lightweight) protocol

2. **Interrupt Integration**
   - TiLelink-compliant interrupt signaling
   - Configurable interrupt priority
   - Edge and level-triggered modes

3. **DMA Support**
   - Burst transfers for FIFO read/write
   - Automatic address increment
   - Configurable burst size (1-16 bytes)

4. **Clock Domain Crossing**
   - Asynchronous FIFO for clock domain crossing
   - Separate clocks for TiLelink and SPI interfaces
   - Handshaking protocol for safe data transfer

### TiLelink Memory Map
```
Base Address: 0x4000_0000 (configurable)

Offset    Register Name           Description
------    -------------           -----------
0x00      CONTROL                 Control register (enable, mode, power)
0x04      STATUS                  Status register (busy, error flags)
0x08      IRQ_STATUS              Interrupt status register
0x0C      IRQ_MASK                Interrupt mask register
0x10      FIFO_DATA               FIFO data register
0x14      FIFO_STATUS             FIFO level and status
0x18      RF_CONFIG               RF configuration (power, frequency)
0x1C      PROTOCOL_SELECT         Protocol selection register
0x20-0x7C ISO_CONFIG[24]          Protocol-specific configuration
0x80-0xFF Reserved                Reserved for future use
```

### TiLelink Transaction Examples

**Register Write:**
```
TiLelink Put: 
  Address: 0x4000_0000 (CONTROL)
  Data: 0x0000_0001 (Enable NFC controller)
  Size: 4 bytes
```

**FIFO Read (Burst):**
```
TiLelink Get:
  Address: 0x4000_0010 (FIFO_DATA)
  Size: 32 bytes (8 x 4-byte words)
  Burst: Automatic FIFO read with address hold
```

## Architecture

### Firmware Layers
```
┌─────────────────────────────────────────┐
│         Application Layer               │
│  (Tag Reading, Card Emulation, P2P)    │
└─────────────────────────────────────────┘
                  │
┌─────────────────────────────────────────┐
│         Protocol Layer                  │
│  (ISO14443A/B, ISO15693, FeliCa)       │
└─────────────────────────────────────────┘
                  │
┌─────────────────────────────────────────┐
│         TRF7970A Driver Layer           │
│  (Register Access, FIFO Management)     │
└─────────────────────────────────────────┘
                  │
┌──────────────┬──────────────────────────┐
│   SPI HAL    │    TiLelink Interface    │
│   (Direct)   │    (Memory-Mapped)       │
└──────────────┴──────────────────────────┘
```

### Key Components

1. **TRF7970A Driver**
   - Low-level register access
   - Command execution
   - Interrupt handling
   - FIFO management

2. **Protocol Stack**
   - ISO14443A/B implementation
   - ISO15693 implementation
   - Anticollision algorithms
   - CRC calculation

3. **Application APIs**
   - Tag detection and enumeration
   - Read/write operations
   - NDEF message parsing
   - Peer-to-peer data exchange

4. **TiLelink Wrapper**
   - Address decoding
   - Bus protocol conversion
   - Interrupt aggregation
   - DMA controller

## Setup and Configuration

### Hardware Setup
1. Connect the TRF7970A BoosterPack to your host controller
2. Ensure proper power supply (3.3V, min 200mA capability)
3. Connect the NFC antenna to the BoosterPack antenna terminals
4. Verify all SPI connections (or TiLelink connections for SoC integration)

### Software Configuration

#### Standard SPI Mode
```c
// Initialize TRF7970A with SPI interface
trf7970a_config_t config = {
    .spi_instance = SPI0,
    .cs_pin = GPIO_PIN_6,
    .irq_pin = GPIO_PIN_1,
    .en_pin = GPIO_PIN_1,
    .clock_speed = 4000000,  // 4 MHz SPI clock
    .rf_power = TRF7970A_POWER_FULL,
    .protocol = TRF7970A_PROTOCOL_ISO14443A
};

trf7970a_init(&config);
```

#### TiLelink Mode
```c
// Initialize TRF7970A with TiLelink interface
tilelink_nfc_config_t tl_config = {
    .base_address = 0x40000000,
    .irq_number = 16,
    .dma_enable = true,
    .fifo_threshold = 32
};

tilelink_nfc_init(&tl_config);
```

### Firmware Build
```bash
# Clone the repository
git clone https://github.com/evanjyli/nfc_firmware.git
cd nfc_firmware

# Build for standard SPI mode
make CONFIG=spi

# Build for TiLelink mode
make CONFIG=tilelink

# Flash firmware
make flash
```

## Usage

### Basic Tag Reading (SPI Mode)
```c
#include "trf7970a.h"

// Scan for tags
uint8_t uid[10];
uint8_t uid_len;

if (trf7970a_scan_tags(uid, &uid_len) == TRF_SUCCESS) {
    printf("Tag found! UID: ");
    for (int i = 0; i < uid_len; i++) {
        printf("%02X ", uid[i]);
    }
    printf("\n");
    
    // Read data from tag
    uint8_t data[16];
    if (trf7970a_read_block(4, data, 16) == TRF_SUCCESS) {
        printf("Data: %s\n", data);
    }
}
```

### Tag Writing
```c
// Write data to block 4
uint8_t data[16] = "Hello NFC!";
if (trf7970a_write_block(4, data, 16) == TRF_SUCCESS) {
    printf("Write successful\n");
}
```

### TiLelink Register Access
```c
// Direct register access via TiLelink
volatile uint32_t *nfc_control = (uint32_t *)(TL_NFC_BASE + 0x00);
volatile uint32_t *nfc_status = (uint32_t *)(TL_NFC_BASE + 0x04);
volatile uint32_t *nfc_fifo = (uint32_t *)(TL_NFC_BASE + 0x10);

// Enable NFC controller
*nfc_control = 0x1;

// Wait for tag detection
while (!(*nfc_status & STATUS_TAG_DETECTED)) {
    // Poll or use interrupt
}

// Read tag UID from FIFO
uint32_t uid[3];
uid[0] = *nfc_fifo;
uid[1] = *nfc_fifo;
uid[2] = *nfc_fifo;
```

### NDEF Message Handling
```c
#include "ndef.h"

// Read NDEF message from tag
ndef_message_t msg;
if (ndef_read_message(&msg) == NDEF_SUCCESS) {
    printf("NDEF message found:\n");
    printf("  Type: %s\n", msg.type);
    printf("  Payload: %s\n", msg.payload);
}

// Write NDEF URI record
ndef_uri_record_t uri = {
    .prefix = NDEF_URI_HTTP_WWW,
    .uri = "example.com"
};
ndef_write_uri_record(&uri);
```

## API Documentation

### TRF7970A Driver API

#### Initialization
- `trf7970a_init(config)` - Initialize the TRF7970A
- `trf7970a_deinit()` - Deinitialize and power down
- `trf7970a_reset()` - Software reset

#### Tag Operations
- `trf7970a_scan_tags(uid, uid_len)` - Scan for tags
- `trf7970a_read_block(block, data, len)` - Read data block
- `trf7970a_write_block(block, data, len)` - Write data block
- `trf7970a_authenticate(key, block)` - Authenticate with key

#### Configuration
- `trf7970a_set_protocol(protocol)` - Set active protocol
- `trf7970a_set_rf_power(power)` - Set RF output power
- `trf7970a_set_mode(mode)` - Set operating mode

#### Interrupt Handling
- `trf7970a_register_callback(callback)` - Register interrupt callback
- `trf7970a_get_irq_status()` - Read interrupt status
- `trf7970a_clear_irq()` - Clear interrupt flags

### TiLelink Interface API

#### Initialization
- `tilelink_nfc_init(config)` - Initialize TiLelink interface
- `tilelink_nfc_set_base_addr(addr)` - Set base address

#### Register Access
- `tilelink_nfc_read_reg(offset)` - Read register
- `tilelink_nfc_write_reg(offset, value)` - Write register
- `tilelink_nfc_modify_reg(offset, mask, value)` - Modify register bits

#### DMA Operations
- `tilelink_nfc_dma_read(addr, buffer, len)` - DMA read
- `tilelink_nfc_dma_write(addr, buffer, len)` - DMA write
- `tilelink_nfc_dma_status()` - Check DMA status

## Troubleshooting

### Common Issues

#### No Tag Detected
- **Cause**: Antenna not properly connected or damaged
- **Solution**: Check antenna connections, verify continuity, ensure proper impedance matching

#### Communication Errors
- **Cause**: SPI timing issues or incorrect pin configuration
- **Solution**: Reduce SPI clock speed, verify pin mappings, check logic levels

#### Intermittent Reads
- **Cause**: RF power too low or electromagnetic interference
- **Solution**: Increase RF power level, move away from interference sources, check power supply stability

#### TiLelink Access Timeout
- **Cause**: Clock domain crossing issues or incorrect base address
- **Solution**: Verify clock configuration, check address decoding, ensure proper reset sequencing

### Debug Tips

1. **Enable Debug Output**
   ```c
   trf7970a_set_debug_level(DEBUG_VERBOSE);
   ```

2. **Check Register Values**
   ```c
   uint8_t chip_status = trf7970a_read_reg(TRF7970A_REG_CHIP_STATUS);
   printf("Chip Status: 0x%02X\n", chip_status);
   ```

3. **Monitor IRQ Line**
   - Use oscilloscope to verify IRQ timing
   - Check for spurious interrupts

4. **Verify RF Field**
   - Use NFC-enabled phone to detect RF field
   - Measure field strength with spectrum analyzer

5. **TiLelink Bus Analyzer**
   - Use waveform viewer to inspect TiLelink transactions
   - Verify address and data phases
   - Check for protocol violations

## References

### Documentation
- [TRF7970A Datasheet](https://www.ti.com/product/TRF7970A)
- [TRF7970A User Guide](https://www.ti.com/lit/ug/slou186/slou186.pdf)
- [ISO14443 Standard](https://www.iso.org/standard/73599.html)
- [NFC Forum Specifications](https://nfc-forum.org/our-work/specification-releases/)
- [TiLelink Specification](https://github.com/chipsalliance/omnixtend)

### Tools
- [NFC Tools App](https://www.wakdev.com/en/apps/nfc-tools-pc-mac.html) - For testing tags
- [Proxmark3](https://github.com/Proxmark/proxmark3) - Advanced NFC analysis
- [TI Code Composer Studio](https://www.ti.com/tool/CCSTUDIO) - Development IDE

### Example Projects
- TI NFC Host Controller Example
- NFC Tag Emulation Demo
- TiLelink NFC Bridge Reference Design

## Contributing

Contributions are welcome! Please follow these guidelines:
1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Test thoroughly on hardware
5. Submit a pull request

## License

This firmware is provided as-is for evaluation and development purposes.

## Support

For issues and questions:
- Open an issue on GitHub
- Contact: evanjyli@github.com
- Check the wiki for FAQs

---

**Note**: This firmware is under active development. TiLelink functionality is in beta and may change in future releases.
