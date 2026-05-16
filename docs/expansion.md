# Expansion Connectors

## Hirose FX2 100-pin Edge Connector (J3)

Right edge of board. 1.27 mm pitch. 43 FPGA I/O pins.

### Power

- Pin A.49/A.50: 5.0V
- Pin A.44: Bank 0 VCCO (3.3V default, 2.5V if JP9 changed)
- B-side mostly GND (signal integrity)

### Clock Signals

| Signal | Pin | FPGA Pin | Notes |
|--------|-----|----------|-------|
| FX2_CLKIN | A.46 | E10 | GCLK5 |
| FX2_CLKOUT | A.47 | D10 | GCLK4 |
| FX2_CLKIO | A.48 | D9 | General I/O |

### I/O Pins

| Signal | FPGA Pin | FX2 Pin | Shared With |
|--------|----------|---------|-------------|
| FX2_IO<1> | B4 | A.6 | J1 header |
| FX2_IO<2> | A4 | A.7 | J1 header |
| FX2_IO<3> | D5 | A.8 | J1 header |
| FX2_IO<4> | C5 | A.9 | J1 header |
| FX2_IO<5> | A6 | A.10 | J2 header |
| FX2_IO<6> | B6 | A.11 | J2 header |
| FX2_IO<7> | E7 | A.12 | J2 header |
| FX2_IO<8> | F7 | A.13 | J2 header |
| FX2_IO<9> | D7 | A.14 | J4 header |
| FX2_IO<10> | C7 | A.15 | J4 header |
| FX2_IO<11> | F8 | A.16 | J4 header |
| FX2_IO<12> | E8 | A.17 | J4 header |
| FX2_IO<13> | F9 | A.18 | LED7 |
| FX2_IO<14> | E9 | A.19 | LED6 |
| FX2_IO<15> | D11 | A.20 | LED5 |
| FX2_IO<16> | C11 | A.21 | LED4 |
| FX2_IO<17> | F11 | A.22 | LED3 |
| FX2_IO<18> | E11 | A.23 | LED2 |
| FX2_IO<19> | E12 | A.24 | LED1 |
| FX2_IO<20> | F12 | A.25 | LED0 |
| FX2_IO<21> | A13 | A.26 | — |
| FX2_IO<22> | B13 | A.27 | — |
| FX2_IO<23> | A14 | A.28 | — |
| FX2_IO<24> | B14 | A.29 | — |
| FX2_IO<25> | C14 | A.30 | — |
| FX2_IO<26> | D14 | A.31 | — |
| FX2_IO<27> | A16 | A.32 | — |
| FX2_IO<28> | B16 | A.33 | — |
| FX2_IO<29> | E13 | A.34 | — |
| FX2_IO<30> | C4 | A.35 | — |
| FX2_IO<31> | B11 | A.36 | — |
| FX2_IO<32> | A11 | A.37 | SF_A<24> |
| FX2_IO<33> | A8 | A.38 | — |
| FX2_IO<34> | G9 | A.39 | — |
| FX2_IP<35> | D12 | A.40 | Input-only |
| FX2_IP<36> | C12 | A.41 | Input-only |
| FX2_IP<37> | A15 | A.42 | Input-only |
| FX2_IP<38> | B15 | A.43 | Input-only |
| FX2_IO<39> | C3 | A.44 | — |
| FX2_IP<40> | C15 | A.45 | Input-only |

### Input-Only Pins

FX2_IP<35:38> and FX2_IP<40> are input-only — they cannot drive signals.

## Differential I/O Pairs

Up to 15 bidirectional + 2 input-only differential pairs (LVDS/RSDS). All in Bank 0.

Requires JP9 set to 2.5V for differential outputs.

| Pair | Positive | Negative | External Resistor |
|------|----------|----------|-------------------|
| 1 | A4 (IO2) | B4 (IO1) | — |
| 2 | C5 (IO4) | D5 (IO3) | — |
| 3 | B6 (IO6) | A6 (IO5) | — |
| 4 | F7 (IO8) | E7 (IO7) | — |
| 5 | C7 (IO10) | D7 (IO9) | — |
| 6 | E8 (IO12) | F8 (IO11) | — |
| 7 | E9 (IO14) | F9 (IO13) | — |
| 8 | C11 (IO16) | D11 (IO15) | — |
| 9 | E11 (IO18) | F11 (IO17) | R202 |
| 10 | F12 (IO20) | E12 (IO19) | R203 |
| 11 | B13 (IO22) | A13 (IO21) | R204 |
| 12 | B14 (IO24) | A14 (IO23) | R205 |
| 13 | D14 (IO26) | C14 (IO25) | R206 |
| 14 | B16 (IO28) | A16 (IO27) | R207 |
| 15 | C12 (IP36) | D12 (IP35) | R208 (input-only) |
| 16 | B15 (IP38) | A15 (IP37) | R209 (input-only) |
| 17 | D10 (CLKOUT) | E10 (CLKIN) | R210 |

Termination options:
- External 100Ω resistor (landing pads on board, not populated)
- On-chip DIFF_TERM (~120Ω, not available on input-only pairs 15/16)

## 6-Pin Accessory Headers

Digilent Peripheral Module compatible. Each has 4 I/O + GND + 3.3V.

### J1 (top-right, female 90° socket)

| Pin | Signal | FPGA Pin |
|-----|--------|----------|
| 1 | IO1 | B4 |
| 2 | IO2 | A4 |
| 3 | IO3 | D5 |
| 4 | IO4 | C5 |
| 5 | GND | — |
| 6 | 3.3V | — |

### J2 (bottom-right, female 90° socket)

| Pin | Signal | FPGA Pin |
|-----|--------|----------|
| 1 | IO5 | A6 |
| 2 | IO6 | B6 |
| 3 | IO7 | E7 |
| 4 | IO8 | F7 |
| 5 | GND | — |
| 6 | 3.3V | — |

### J4 (left of J1, 0.1" stake pins)

| Pin | Signal | FPGA Pin |
|-----|--------|----------|
| 1 | IO9 | D7 |
| 2 | IO10 | C7 |
| 3 | IO11 | F8 |
| 4 | IO12 | E8 |
| 5 | GND | — |
| 6 | 3.3V | — |

## Bank 0 Voltage (JP9)

- Default: 3.3V
- Set to 2.5V for LVDS/RSDS differential outputs
- Affects all Bank 0 I/O including clock inputs and FX2 connector
