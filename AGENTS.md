# AGENTS.md

## Project

LED blinker demo for the Xilinx Spartan-3E Starter Kit (XC3S500E-FG320-4).

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

Use `xc3sprog` with the Xilinx Platform Cable USB II:

```bash
sudo xc3sprog -c xpc -p 0 build/top.bit
```

The USB cable must be attached to WSL first (see USB passthrough below).

## USB Passthrough (WSL)

From Admin PowerShell:

```powershell
usbipd bind --busid 7-3
usbipd attach --wsl --busid 7-3
```

After firmware load the cable re-enumerates — re-attach is needed.
Verify: `lsusb | grep Xilinx` (expect `03fd:0008 Platform Cable USB II`).

If the cable shows `03fd:000d` (firmware not loaded), run:

```bash
sudo fxload -t fx2 -I /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/xusbdfwu.hex -D /dev/bus/usb/<bus>/<dev>
```

Then re-attach from PowerShell (cable re-enumerates after firmware load).

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
