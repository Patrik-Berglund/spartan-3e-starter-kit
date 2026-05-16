# PS/2 Mouse/Keyboard Port

6-pin mini-DIN connector (J14). Directly connects to FPGA via 270Ω series resistors. 5V powered.

## Signals

| Signal | Pin | IOSTANDARD |
|--------|-----|------------|
| PS2_CLK | G14 | LVCMOS33, DRIVE=8, SLEW=SLOW |
| PS2_DATA | G13 | LVCMOS33, DRIVE=8, SLEW=SLOW |

Both signals are active-high idle. Open-collector bus (keyboard/mouse can pull low).

## Bus Timing

| Parameter | Min | Max |
|-----------|-----|-----|
| Clock high/low time | 30 μs | 50 μs |
| Data-to-clock setup | 5 μs | 25 μs |
| Clock-to-data hold | 5 μs | 25 μs |

Clock frequency: 20–30 kHz. Data valid on falling edge of clock.

## Frame Format (11 bits)

```
[Start=0] [D0] [D1] [D2] [D3] [D4] [D5] [D6] [D7] [Parity(odd)] [Stop=1]
```

LSB first. Both keyboard and mouse use same frame format.

## Keyboard

### Receiving Scan Codes

- Key press: sends scan code
- Key held: repeats scan code every ~100 ms
- Key release: sends F0 followed by scan code
- Extended key: sends E0 before scan code (release: E0 F0 + scan code)

### Common Scan Codes

| Key | Code | Key | Code | Key | Code |
|-----|------|-----|------|-----|------|
| A | 1C | 0 | 45 | Enter | 5A |
| B | 32 | 1 | 16 | Space | 29 |
| C | 21 | 2 | 1E | Backspace | 66 |
| D | 23 | 3 | 26 | Tab | 0D |
| E | 24 | 4 | 25 | Esc | 76 |
| F | 2B | 5 | 2E | Shift L | 12 |
| G | 34 | 6 | 36 | Shift R | 59 |
| H | 33 | 7 | 3D | Ctrl | 14 |
| I | 43 | 8 | 3E | Alt | 11 |
| J | 3B | 9 | 46 | Caps | 58 |

### Sending Commands to Keyboard

| Command | Description |
|---------|-------------|
| ED | Set LEDs (followed by LED byte: bit2=Caps, bit1=Num, bit0=Scroll) |
| EE | Echo (keyboard replies EE) |
| F3 | Set repeat rate |
| FE | Resend last scan code |
| FF | Reset keyboard |

Host pulls clock low to inhibit keyboard transmission. Host drives data low then releases clock to initiate host-to-device transfer.

## Mouse

### Receiving Movement Data

Mouse sends 3 frames (33 bits total) on each movement:

**Byte 1 (Status):**
```
[YV] [XV] [YS] [XS] [1] [0] [R] [L]
```
- L/R: left/right button (1=pressed)
- XS/YS: sign of X/Y (1=negative)
- XV/YV: overflow

**Byte 2:** X movement magnitude (unsigned)

**Byte 3:** Y movement magnitude (unsigned)

Relative coordinate system:
- Right = +X, Left = -X
- Up = +Y, Down = -Y

Repeats every ~50 ms during continuous movement.

## Voltage

PS/2 port powered by 5V. FPGA is NOT 5V tolerant — 270Ω series resistors provide protection.

## UCF

```
NET "PS2_CLK"   LOC = "G14" | IOSTANDARD = LVCMOS33 | DRIVE = 8 | SLEW = SLOW ;
NET "PS2_DATA"  LOC = "G13" | IOSTANDARD = LVCMOS33 | DRIVE = 8 | SLEW = SLOW ;
```
