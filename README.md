# Spartan-3E Starter Kit Demo

LED blinker demo for the Xilinx Spartan-3E Starter Kit (XC3S500E-FG320-4).

## Requirements

- Xilinx ISE 14.7 (WebPack edition, free license)
- Linux / WSL

## Installing ISE 14.7 on WSL (Ubuntu 24.04)

Ubuntu 24.04 dropped some libraries ISE depends on. Install prerequisites first:

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y lib32ncurses6 lib32tinfo6 libstdc++6:i386 lib32z1

# Create compat symlinks (ISE expects libncurses5)
sudo ln -sf /usr/lib32/libncurses.so.6 /usr/lib32/libncurses.so.5
sudo ln -sf /usr/lib32/libtinfo.so.6 /usr/lib32/libtinfo.so.5
sudo ln -sf /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
sudo ln -sf /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5
```

Add to your `~/.bashrc` (ISE crashes without these):

```bash
ulimit -s unlimited
export LC_ALL=C
```

Then run the batch installer (download `Xilinx_ISE_DS_Lin_14.7_1015_1.tar` from Xilinx/AMD):

```bash
tar xf Xilinx_ISE_DS_Lin_14.7_1015_1.tar
cd Xilinx_ISE_DS_Lin_14.7_1015_1
sudo ./bin/lin64/batchxsetup --batch /path/to/ise_install.cfg
```

See `ise_install.cfg` in this repo for the config used.

## Setup

Source the ISE environment before building:

```bash
source /opt/Xilinx/14.7/ISE_DS/settings64.sh
```

## Build

```bash
make        # synthesize → bitstream
make clean  # remove build artifacts
```

## USB passthrough (WSL)

The board connects to Windows via USB. To make it visible in WSL, use `usbipd` from an **Admin PowerShell**:

```powershell
usbipd bind --busid 7-3
usbipd attach --wsl --busid 7-3
```

Verify in WSL:

```bash
lsusb | grep Xilinx
```

Note: re-attach is needed after each reconnect or reboot.

## Program the board

Connect the board via USB-JTAG (see above), then:

```bash
make program
```

## Design

- `src/top.vhd` — 32-bit counter, upper bits drive 8 LEDs at visible rates
- `constraints/top.ucf` — pin assignments for 50 MHz clock and LEDs
- `build/top.xst` — XST synthesis script
- `build/top.prj` — XST project file
