# XC3S500E FPGA

Xilinx Spartan-3E, 500K-gate equivalent, FG320 package (320-pin FBGA), speed grade -4.

## Logic Resources

| Resource | Count |
|----------|-------|
| Logic Cells | 10,476 |
| Slices | 4,656 |
| Slice Flip-Flops | 9,312 |
| 4-input LUTs | 9,312 |
| Block RAM (18 Kbit each) | 20 (360 Kbit total) |
| Multipliers (18×18) | 20 |
| DCMs | 4 |
| Global Clock Buffers (BUFGMUX) | 24 |

## I/O

| Resource | Count |
|----------|-------|
| Max User I/O | 232 |
| I/O Banks | 4 (Bank 0–3) |
| Differential I/O Pairs | up to 92 |
| I/O Standards | LVTTL, LVCMOS33/25/18/12, SSTL2, LVDS, RSDS, etc. |

## I/O Bank Voltages (on this board)

| Bank | VCCO | Used For |
|------|------|----------|
| 0 | 3.3V (JP9, default) | Clock inputs, FX2 connector, LEDs, LCD, SPI, VGA, RS-232, PS/2 |
| 1 | 3.3V | StrataFlash, Ethernet PHY, configuration |
| 2 | 3.3V | StrataFlash address, configuration |
| 3 | 2.5V | DDR SDRAM (SSTL2_I) |

## Clock Resources

| DCM | Location | Optimal Clock Input |
|-----|----------|---------------------|
| DCM_X0Y1 | Top-left | CLK_50MHZ (C9, GCLK10), CLK_AUX (B8, GCLK8) |
| DCM_X1Y1 | Top-right | CLK_SMA (A10, GCLK7) |
| DCM_X0Y0 | Bottom-left | Available |
| DCM_X1Y0 | Bottom-right | SD_CK_FB (B9, GCLK9) |

### DCM Capabilities

- Frequency synthesis (multiply/divide clock)
- Phase shifting (fixed or variable)
- Clock deskew
- Input range: 1 MHz – 333 MHz (DLL mode), 5 MHz – 333 MHz (DFS mode)
- Output range: up to 333 MHz

## Block RAM

- 20 blocks × 18 Kbit = 360 Kbit total
- Configurable as: 16K×1, 8K×2, 4K×4, 2K×9, 1K×18, 512×36
- Dual-port (independent read/write ports)
- Synchronous read and write

## Multipliers

- 20 dedicated 18×18 signed multipliers
- 36-bit output
- Can be cascaded for wider multiplies
- Registered inputs/outputs for pipelining

## Configuration

- Bitstream size: ~2.27 Mbit
- Configuration modes: Master Serial, SPI, BPI Up/Down, JTAG
- CCLK range: 1.5 MHz (default) to 25 MHz (Platform Flash) or 12 MHz (SPI Flash)
- Supports MultiBoot (switch between two configs in StrataFlash)

## Speed Grade -4

- Fastest commercial grade for this device
- Typical max clock (counter chain): ~200 MHz
- Typical max clock (complex logic): 50–150 MHz depending on design
- Slice-to-slice delay: ~0.5 ns
- IOB output delay: ~3.3 ns

## Power

- VCCINT: 1.2V (core logic)
- VCCAUX: 2.5V (auxiliary/config)
- VCCO: per-bank (see table above)
