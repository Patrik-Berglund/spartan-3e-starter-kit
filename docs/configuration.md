# FPGA Configuration

The XC3S500E can be configured from multiple sources. Jumper header J30 selects the mode.

## Mode Jumper Settings (J30)

| Mode | M2:M1:M0 | Source | J30 Jumpers |
|------|----------|--------|-------------|
| Master Serial | 0:0:0 | Platform Flash PROM | All three inserted |
| SPI | 1:1:0 | SPI Serial Flash | Top removed, bottom two inserted |
| BPI Up | 0:1:0 | StrataFlash (addr 0 up) | Middle inserted only |
| BPI Down | 0:1:1 | StrataFlash (addr max down) | Middle + bottom inserted |
| JTAG | 0:1:0 | USB-JTAG download | Same as BPI Up (JTAG overrides) |

## PROG Button

Press and release to force FPGA reconfiguration from selected source.

## DONE LED

Lights when FPGA is successfully configured.

## Platform Flash PROM (XCF04S, 4 Mbit)

- Programmed via USB-JTAG (iMPACT)
- FPGA uses Master Serial mode (M2:M1:M0 = 000)
- CPLD generates active-low CE for Platform Flash when mode = 000
- Max CCLK: 25 MHz (set in bitgen Configuration Rate)
- Bitgen setting: `-g StartUpClk:CClk`

## SPI Serial Flash (M25P16, 16 Mbit)

- STMicroelectronics M25P16
- FPGA uses SPI mode (M2:M1:M0 = 110)
- VS[2:0] pins pulled high (correct for M25P16)
- Max config CCLK: 12 MHz
- After config, SPI Flash available to application via SPI bus
- Programming: use PicoBlaze SPI programmer or XSPI utility with parallel cable

## StrataFlash BPI (128 Mbit)

- Intel J3 StrataFlash, 16 Mbyte
- BPI Up: starts at address 0, increments
- BPI Down: starts at 0x1FF_FFFF, decrements
- CPLD drives SF_A<24:20> during configuration:
  - BPI Up: 00000
  - BPI Down: 11111
  - After DONE=1: High-Z (FPGA takes over)
- Supports MultiBoot (two configs in one Flash)

## CPLD Role (XC2C64A)

The CoolRunner-II CPLD provides:

1. Platform Flash CE generation (active-low when mode=000)
2. Upper StrataFlash address control during BPI configuration
3. 13–21 user I/O pins and 58 macrocells available after required functions

### CPLD Signals

| Signal | FPGA Pin | CPLD Pin | Function |
|--------|----------|----------|----------|
| XC_CMD<0> | P18 | P29 | Command |
| XC_CMD<1> | N18 | P30 | Command |
| XC_D<0> | G16 | P33 | Data |
| XC_D<1> | F18 | P34 | Data |
| XC_D<2> | F17 | P36 | Data |
| FPGA_M0 | M10 | P5 | Mode pin |
| FPGA_M1 | V11 | P6 | Mode pin |
| FPGA_M2 | T10 | P8 | Mode pin |
| XC_DONE | — | P40 | FPGA DONE |
| XC_PROG_B | — | P39 | FPGA PROG_B (open-drain only!) |
| XC_GCK0 | H16 | P43 | Clock to CPLD |

## USB-JTAG Programming

- On-board USB-JTAG circuit (Type B connector)
- Programs FPGA, Platform Flash, and CPLD
- Does NOT directly program SPI Flash or StrataFlash
- JTAG chain: FPGA → XCF04S → XC2C64A

## Bitgen Tips

| Option | Value | When |
|--------|-------|------|
| StartUpClk | CClk | Platform Flash / SPI Flash config |
| StartUpClk | JtagClk | JTAG download |
| ConfigRate | 25 | Platform Flash |
| ConfigRate | 12 | SPI Flash |
