# VGA Display Port

DB15 connector. FPGA drives 3 color bits + 2 sync signals directly via resistors.

## Signals

| Signal | Pin | Function |
|--------|-----|----------|
| VGA_RED | H14 | Red (1 bit) |
| VGA_GREEN | H15 | Green (1 bit) |
| VGA_BLUE | G15 | Blue (1 bit) |
| VGA_HSYNC | F15 | Horizontal sync |
| VGA_VSYNC | F14 | Vertical sync |

## Color Table (3-bit)

| R | G | B | Color |
|---|---|---|-------|
| 0 | 0 | 0 | Black |
| 0 | 0 | 1 | Blue |
| 0 | 1 | 0 | Green |
| 0 | 1 | 1 | Cyan |
| 1 | 0 | 0 | Red |
| 1 | 0 | 1 | Magenta |
| 1 | 1 | 0 | Yellow |
| 1 | 1 | 1 | White |

## 640×480 @ 60 Hz Timing

Pixel clock: **25 MHz** (use DCM to divide 50 MHz by 2)

### Horizontal

| Parameter | Pixels | Time |
|-----------|--------|------|
| Total (TS) | 800 | 32 μs |
| Display (TDISP) | 640 | 25.6 μs |
| Front porch (TFP) | 16 | 640 ns |
| Sync pulse (TPW) | 96 | 3.84 μs |
| Back porch (TBP) | 48 | 1.92 μs |

### Vertical

| Parameter | Lines | Time |
|-----------|-------|------|
| Total (TS) | 521 | 16.7 ms |
| Display (TDISP) | 480 | 15.36 ms |
| Front porch (TFP) | 10 | 320 μs |
| Sync pulse (TPW) | 2 | 64 μs |
| Back porch (TBP) | 29 | 928 μs |

### Sync Polarity

Both HSYNC and VSYNC are active-low for 640×480@60Hz.

## Implementation Notes

- Horizontal counter (0–799) clocked by 25 MHz pixel clock
- Vertical counter (0–520) incremented on each HSYNC
- Drive color signals only during active display region
- Series resistors (270Ω) + 75Ω cable termination keep color signals in 0–0.7V range

## UCF

```
NET "VGA_RED"    LOC = "H14" | IOSTANDARD = LVTTL | DRIVE = 8 | SLEW = FAST ;
NET "VGA_GREEN"  LOC = "H15" | IOSTANDARD = LVTTL | DRIVE = 8 | SLEW = FAST ;
NET "VGA_BLUE"   LOC = "G15" | IOSTANDARD = LVTTL | DRIVE = 8 | SLEW = FAST ;
NET "VGA_HSYNC"  LOC = "F15" | IOSTANDARD = LVTTL | DRIVE = 8 | SLEW = FAST ;
NET "VGA_VSYNC"  LOC = "F14" | IOSTANDARD = LVTTL | DRIVE = 8 | SLEW = FAST ;
```
