# AGENTS.md

## Project

LED blinker demo for the Xilinx Spartan-3E Starter Kit (XC3S500E-FG320-4).

## Toolchain

- Xilinx ISE 14.7 (CLI tools: xst, ngdbuild, map, par, bitgen, impact)
- Source environment: `source /opt/Xilinx/14.7/ISE_DS/settings64.sh`
- Language: VHDL (VHDL-93, the ISE 14.7 default)
- No GUI tools — CLI only

## Build

Run `make` from the project root. The flow is:
xst → ngdbuild → map → par → bitgen

## Target Hardware

- Board: Spartan-3E Starter Kit
- FPGA: XC3S500E-FG320-4
- Clock: 50 MHz on pin C9
- LEDs: 8 active-high on pins F12, E12, E11, F11, C11, D11, E9, F9

## Conventions

- All source in `src/`, constraints in `constraints/`, build scripts in `build/`
- Top-level entity is always named `top`
- UCF format for constraints (not XDC)
- Keep designs simple and self-contained — no IP cores or external dependencies
