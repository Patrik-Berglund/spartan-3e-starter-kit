# SPI Bus

The Spartan-3E Starter Kit has a shared SPI bus connecting four peripherals. Only one device may be active at a time.

## Bus Signals

| Signal | Pin | Direction |
|--------|-----|-----------|
| SPI_MOSI | T4 | FPGA → Slave |
| SPI_MISO | N10 | Slave → FPGA |
| SPI_SCK | U16 | FPGA → Slave |

## Chip Selects

| Signal | Pin | Device | Active |
|--------|-----|--------|--------|
| DAC_CS | N8 | LTC2624 Quad DAC | Low |
| AMP_CS | N7 | LTC6912-1 Pre-Amp | Low |
| AD_CONV | P11 | LTC1407A-1 ADC | High |
| SPI_SS_B | U3 | M25P16 SPI Flash | Low |

## Disable Table (CRITICAL)

Before communicating with any SPI device, disable all others:

| Signal | Disable Value | Disables |
|--------|---------------|----------|
| SPI_SS_B | 1 | SPI Flash |
| AMP_CS | 1 | Pre-Amplifier |
| DAC_CS | 1 | DAC |
| AD_CONV | 0 | ADC |
| SF_CE0 | 1 | StrataFlash (shares SF_D<0> = SPI_MISO) |
| FPGA_INIT_B | 1 | Platform Flash PROM |

## DAC — LTC2624 (4-channel, 12-bit)

### Protocol

- 32-bit SPI transaction, MSB first
- FPGA captures MISO on rising SCK edge
- DAC captures MOSI on rising SCK edge
- Conversion starts on DAC_CS rising edge
- Max clock: 50 MHz

### 32-bit Command Word

```
[31:24] Don't care
[23:20] Command (0011 = write and update)
[19:16] Address (0000=A, 0001=B, 0010=C, 0011=D, 1111=All)
[15:4]  12-bit unsigned data
[3:0]   Don't care
```

### Output Voltage

- Channels A, B: `VOUT = (D[11:0] / 4096) × 3.3V`
- Channels C, D: `VOUT = (D[11:0] / 4096) × 2.5V`

### Additional Signals

| Signal | Pin | Function |
|--------|-----|----------|
| DAC_CLR | P8 | Active-low async reset |

## Pre-Amplifier — LTC6912-1 (dual programmable gain)

### Protocol

- 8-bit SPI transaction, MSB first
- AMP captures MOSI on rising SCK edge
- Gain latched on AMP_CS rising edge
- Max clock: ~10 MHz

### 8-bit Command Word

```
[7:4] Channel A gain code
[3:0] Channel B gain code
```

### Gain Codes

| Code | Gain | Input Range (V) |
|------|------|-----------------|
| 0000 | 0 | — |
| 0001 | -1 | 0.4 – 2.9 |
| 0010 | -2 | 1.025 – 2.275 |
| 0011 | -5 | 1.4 – 1.9 |
| 0100 | -10 | 1.525 – 1.775 |
| 0101 | -20 | 1.5875 – 1.7125 |
| 0110 | -50 | 1.625 – 1.675 |
| 0111 | -100 | 1.6375 – 1.6625 |

### Additional Signals

| Signal | Pin | Function |
|--------|-----|----------|
| AMP_SHDN | P7 | Active-high shutdown |
| AMP_DOUT | E18 | Serial echo of previous gain (can ignore) |

## ADC — LTC1407A-1 (dual 14-bit simultaneous)

### Protocol

- AD_CONV pulse starts simultaneous sampling of both channels
- Results available on next AD_CONV cycle (1 sample latency)
- 34 SCK cycles per transaction
- Data on SPI_MISO, falling edge of SCK
- Max sample rate: ~1.5 MHz

### Transaction (34 clocks after AD_CONV rising edge)

```
Clocks 1-2:   High-Z
Clocks 3-16:  Channel 0 (14-bit two's complement, MSB first)
Clocks 17-18: High-Z
Clocks 19-32: Channel 1 (14-bit two's complement, MSB first)
Clocks 33-34: High-Z (releases bus)
```

### Digital Output Formula

```
D[13:0] = GAIN × (VIN - 1.65V) / 1.25V × 8192
```

Reference voltage: 1.65V (from resistor divider).

## SPI Flash — M25P16 (16 Mbit)

### Signals

| Signal | Pin | Function |
|--------|-----|----------|
| SPI_SS_B | U3 | Chip select (active-low) |
| SPI_ALT_CS_JP11 | R12 | Alternate CS via J11 jumper |

### Notes

- Standard SPI Flash commands (READ, PP, SE, BE, RDID, etc.)
- Used for FPGA configuration in SPI mode (VS[2:0]=111)
- Available to application after configuration
- Max clock during config: 12 MHz (set in bitgen)
- Max clock for application: 50 MHz
