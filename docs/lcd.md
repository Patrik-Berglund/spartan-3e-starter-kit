# Character LCD

2×16 character LCD with Sitronix ST7066U controller (HD44780 compatible). 4-bit data interface.

## Signals

| Signal | Pin | Function |
|--------|-----|----------|
| LCD_E | M18 | Enable (pulse high to read/write) |
| LCD_RS | L18 | 0=Command, 1=Data |
| LCD_RW | L17 | 0=Write, 1=Read |
| SF_D<11> | M15 | DB7 |
| SF_D<10> | P17 | DB6 |
| SF_D<9> | R16 | DB5 |
| SF_D<8> | R15 | DB4 |

Data lines shared with StrataFlash SF_D<11:8>. Disable StrataFlash (SF_CE0=1) when using LCD.

## Voltage

LCD is 5V powered. FPGA 3.3V outputs meet 5V TTL input thresholds. 390Ω series resistors protect FPGA pins when LCD drives data (LCD_RW=1).

## Write Timing (4-bit mode)

Each 8-bit command/data sent as two 4-bit nibbles (upper first):

1. Set LCD_RS and LCD_RW, set SF_D<11:8> = upper nibble
2. Wait ≥40 ns setup
3. Pulse LCD_E high for ≥230 ns (12+ clocks at 50 MHz)
4. Wait ≥1 μs
5. Set SF_D<11:8> = lower nibble
6. Pulse LCD_E high for ≥230 ns
7. Wait ≥40 μs before next command (1.64 ms after Clear Display)

## Initialization Sequence

### Power-On (establish 4-bit mode)

1. Wait 15 ms after power-on
2. Write SF_D<11:8> = 0x3, pulse E — wait 4.1 ms
3. Write SF_D<11:8> = 0x3, pulse E — wait 100 μs
4. Write SF_D<11:8> = 0x3, pulse E — wait 40 μs
5. Write SF_D<11:8> = 0x2, pulse E — wait 40 μs (now in 4-bit mode)

### Configuration

6. Function Set: 0x28 (4-bit, 2-line, 5×8 font)
7. Entry Mode Set: 0x06 (increment, no shift)
8. Display On/Off: 0x0C (display on, cursor off, blink off)
9. Clear Display: 0x01 — wait 1.64 ms

## Command Set

| Command | RS | RW | Code | Exec Time |
|---------|----|----|------|-----------|
| Clear Display | 0 | 0 | 0x01 | 1.64 ms |
| Return Home | 0 | 0 | 0x02 | 1.6 ms |
| Entry Mode Set | 0 | 0 | 0x04–0x07 | 40 μs |
| Display On/Off | 0 | 0 | 0x08–0x0F | 40 μs |
| Cursor/Display Shift | 0 | 0 | 0x10–0x1F | 40 μs |
| Function Set | 0 | 0 | 0x20–0x3F | 40 μs |
| Set CG RAM Address | 0 | 0 | 0x40–0x7F | 40 μs |
| Set DD RAM Address | 0 | 0 | 0x80–0xFF | 40 μs |
| Write Data | 1 | 0 | 0x00–0xFF | 40 μs |
| Read Data | 1 | 1 | — | 40 μs |

## DD RAM Addresses

```
Line 1: 0x00 0x01 0x02 ... 0x0F  (positions 1–16)
Line 2: 0x40 0x41 0x42 ... 0x4F  (positions 1–16)
```

40 chars per line total (0x00–0x27, 0x40–0x67), only 16 visible.

## Entry Mode Set (0x04 + bits)

- Bit 1 (I/D): 1=increment, 0=decrement address after write
- Bit 0 (S): 1=shift display on write

## Display On/Off (0x08 + bits)

- Bit 2 (D): Display on/off
- Bit 1 (C): Cursor on/off
- Bit 0 (B): Blink on/off

## Disabling Unused LCD

Drive LCD_E=0 and LCD_RW=0 to disable and prevent bus contention.

## UCF

```
NET "LCD_E"     LOC = "M18" | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "LCD_RS"    LOC = "L18" | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "LCD_RW"    LOC = "L17" | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "SF_D<8>"   LOC = "R15" | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "SF_D<9>"   LOC = "R16" | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "SF_D<10>"  LOC = "P17" | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "SF_D<11>"  LOC = "M15" | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
```
