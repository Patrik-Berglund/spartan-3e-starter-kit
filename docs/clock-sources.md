# Clock Sources

## Available Clocks

| Source | Pin | Global Buffer | Associated DCM | Frequency |
|--------|-----|---------------|----------------|-----------|
| On-board oscillator | C9 | GCLK10 | DCM_X0Y1 | 50 MHz ±50 ppm |
| Aux DIP socket | B8 | GCLK8 | DCM_X0Y1 | User-supplied |
| SMA connector | A10 | GCLK7 | DCM_X1Y1 | External |

All clock inputs are in I/O Bank 0 (voltage controlled by JP9, default 3.3V).

## 50 MHz Oscillator

- Epson SG-8002JF series
- Duty cycle: 40%–60%
- Accuracy: ±50 ppm (±2500 Hz)
- 3.3V device (may not work if JP9 set to 2.5V)

## Auxiliary Clock Socket

- 8-pin DIP footprint
- Use when a frequency other than 50 MHz is needed
- Alternative: use DCM to synthesize other frequencies from 50 MHz

## SMA Connector

- Can be used as clock input from external source
- Can also be used as high-speed clock output from FPGA

## UCF Constraints

```
# Location
NET "CLK_50MHZ"  LOC = "C9"  | IOSTANDARD = LVCMOS33 ;
NET "CLK_AUX"    LOC = "B8"  | IOSTANDARD = LVCMOS33 ;
NET "CLK_SMA"    LOC = "A10" | IOSTANDARD = LVCMOS33 ;

# Period constraint for 50 MHz (20 ns, 40%/60% duty)
NET "CLK_50MHZ" PERIOD = 20.0ns HIGH 40%;
```

## DDR Clock Feedback

SD_CK_P is fed back to pin B9 (GCLK9, DCM_X0Y1) for DDR SDRAM clock alignment. See ddr-sdram.md.
