# AGENTS.md

## Project

Board Explorer demo for the Xilinx Spartan-3E Starter Kit (XC3S500E-FG320-4).
Exercises all board peripherals via 9 selectable modes.

## Toolchain

- Xilinx ISE 14.7 (CLI tools: xst, ngdbuild, map, par, bitgen)
- Source environment: `source /opt/Xilinx/14.7/ISE_DS/settings64.sh`
- Programmer: `xc3sprog` (not iMPACT — it has libusb issues on WSL)
- Language: VHDL-93 (the ISE 14.7 default — do NOT use `-vhdl2008`)
- No GUI tools — CLI only

## Build

```bash
source /opt/Xilinx/14.7/ISE_DS/settings64.sh
make
```

Flow: xst → ngdbuild → map → par → bitgen

## Program

```bash
sudo xc3sprog -c xpc -p 0 build/top.bit
```

## Code Structure

```
src/
├── top.vhd                          # Top-level: mode mux, output routing
├── infrastructure/
│   ├── debounce.vhd                 # Generic N-bit debouncer
│   ├── rotary_decoder.vhd          # Quadrature + press decoder
│   ├── spi_master.vhd              # Configurable SPI engine
│   ├── lcd_controller.vhd          # HD44780 4-bit controller
│   └── mode_mux.vhd                # Mode counter + name labels
├── mode1_led_chaser/
├── mode2_dac_waveform/
├── mode3_adc_voltmeter/
├── mode4_uart_echo/
├── mode5_ps2_keyboard/
├── mode6_spi_flash_id/
├── mode7_ddr_memtest/
├── mode8_vga_pattern/
└── mode9_ethernet_ping/
constraints/top.ucf
build/top.xst, build/top.prj
```

## Conventions

- All source in `src/`, constraints in `constraints/`, build scripts in `build/`
- Top-level entity is always named `top`
- UCF format for constraints (not XDC)
- Keep designs simple and self-contained — no IP cores or external dependencies
- Each mode is a self-contained entity with `enable` input
- Shared peripherals (SPI, LCD) are muxed in top.vhd
- Commit and push after every meaningful change — don't batch up work

## XST / VHDL-93 Gotchas (Learned)

These cause synthesis errors in ISE 14.7 XST:

1. **No `-vhdl2008` option** — XST doesn't recognize it at all. Remove from .xst file.
2. **No `character'val()`** — XST doesn't support the `'val` attribute. Use `to_unsigned(48 + x, 8)` instead.
3. **No division/modulo by non-power-of-2** — `speed / 10` is not synthesizable. Use hex display or shift-based approaches.
4. **No conditional expressions in port maps** — `tx_data => x when y else z` is VHDL-2008. Use intermediate signals.
5. **No hex literals in aggregates** — `(others => x"20")` is invalid. Use `(others => '0')` for std_logic_vector.
6. **Ethernet clock pins (T7, V3) are not on dedicated clock sites** — Add `CLOCK_DEDICATED_ROUTE = FALSE` in UCF to demote placement error to warning.
7. **`mkdir -p build/xst/tmp` required** — XST needs this directory but `make clean` removes it. The Makefile handles this via an order-only prerequisite.

## Resource Usage (Board Explorer, all 9 modes)

- Slices: 1,903 / 4,656 (40%)
- Flip-Flops: 1,905 / 9,312 (20%)
- LUTs: 2,582 / 9,312 (27%)
- Plenty of room for enhancements
