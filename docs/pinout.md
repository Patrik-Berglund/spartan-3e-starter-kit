# Pin Assignments (UCF Reference)

All pins for XC3S500E-FG320-4 on the Spartan-3E Starter Kit board.

## Clock

| Signal | Pin | IOSTANDARD | Notes |
|--------|-----|------------|-------|
| CLK_50MHZ | C9 | LVCMOS33 | 50 MHz, GCLK10, DCM_X0Y1 |
| CLK_AUX | B8 | LVCMOS33 | 8-pin DIP socket, GCLK8, DCM_X0Y1 |
| CLK_SMA | A10 | LVCMOS33 | SMA connector, GCLK7, DCM_X1Y1 |

## LEDs

Active-high, accent through 390Ω to GND.

| Signal | Pin | Notes |
|--------|-----|-------|
| LED<0> | F12 | Right-most |
| LED<1> | E12 | |
| LED<2> | E11 | |
| LED<3> | F11 | |
| LED<4> | C11 | |
| LED<5> | D11 | |
| LED<6> | E9 | |
| LED<7> | F9 | Left-most |

## Slide Switches

Logic High when UP/ON, Low when DOWN/OFF. ~2 ms bounce.

| Signal | Pin |
|--------|-----|
| SW<0> | L13 |
| SW<1> | L14 |
| SW<2> | H18 |
| SW<3> | N17 |

## Push Buttons

Active-high (pressed = 3.3V). Use PULLDOWN.

| Signal | Pin |
|--------|-----|
| BTN_NORTH | V4 |
| BTN_EAST | H13 |
| BTN_SOUTH | K17 |
| BTN_WEST | D18 |

## Rotary Encoder

| Signal | Pin | Notes |
|--------|-----|-------|
| ROT_A | K18 | Use PULLUP |
| ROT_B | G18 | Use PULLUP |
| ROT_CENTER | V16 | Use PULLDOWN |

## RS-232

| Signal | Pin | Direction |
|--------|-----|-----------|
| RS232_DCE_RXD | R7 | Input (from PC) |
| RS232_DCE_TXD | M14 | Output (to PC) |
| RS232_DTE_RXD | U8 | Input (from peripheral) |
| RS232_DTE_TXD | M13 | Output (to peripheral) |

## VGA

| Signal | Pin |
|--------|-----|
| VGA_RED | H14 |
| VGA_GREEN | H15 |
| VGA_BLUE | G15 |
| VGA_HSYNC | F15 |
| VGA_VSYNC | F14 |

## PS/2

| Signal | Pin |
|--------|-----|
| PS2_CLK | G14 |
| PS2_DATA | G13 |

## Character LCD

| Signal | Pin | Function |
|--------|-----|----------|
| LCD_E | M18 | Enable pulse |
| LCD_RS | L18 | Register select |
| LCD_RW | L17 | Read/Write |
| SF_D<8> | R15 | DB4 (shared with StrataFlash) |
| SF_D<9> | R16 | DB5 |
| SF_D<10> | P17 | DB6 |
| SF_D<11> | M15 | DB7 |

## SPI Bus (shared)

| Signal | Pin | Direction | Function |
|--------|-----|-----------|----------|
| SPI_MOSI | T4 | Output | Master Out Slave In |
| SPI_MISO | N10 | Input | Master In Slave Out |
| SPI_SCK | U16 | Output | Clock |
| SPI_SS_B | U3 | Output | SPI Flash chip select (active-low) |
| DAC_CS | N8 | Output | DAC chip select (active-low) |
| DAC_CLR | P8 | Output | DAC clear (active-low) |
| AMP_CS | N7 | Output | Amplifier chip select (active-low) |
| AMP_SHDN | P7 | Output | Amplifier shutdown (active-high) |
| AMP_DOUT | E18 | Input | Amplifier serial data out |
| AD_CONV | P11 | Output | ADC convert (active-high) |

## DDR SDRAM (Bank 3, VCCO=2.5V, SSTL2_I)

### Address

| Signal | Pin |
|--------|-----|
| SD_A<0> | T1 |
| SD_A<1> | R3 |
| SD_A<2> | R2 |
| SD_A<3> | P1 |
| SD_A<4> | F4 |
| SD_A<5> | H4 |
| SD_A<6> | H3 |
| SD_A<7> | H1 |
| SD_A<8> | H2 |
| SD_A<9> | N4 |
| SD_A<10> | T2 |
| SD_A<11> | N5 |
| SD_A<12> | P2 |

### Data

| Signal | Pin |
|--------|-----|
| SD_DQ<0> | L2 |
| SD_DQ<1> | L1 |
| SD_DQ<2> | L3 |
| SD_DQ<3> | L4 |
| SD_DQ<4> | M3 |
| SD_DQ<5> | M4 |
| SD_DQ<6> | M5 |
| SD_DQ<7> | M6 |
| SD_DQ<8> | E2 |
| SD_DQ<9> | E1 |
| SD_DQ<10> | F1 |
| SD_DQ<11> | F2 |
| SD_DQ<12> | G6 |
| SD_DQ<13> | G5 |
| SD_DQ<14> | H6 |
| SD_DQ<15> | H5 |

### Control

| Signal | Pin | Function |
|--------|-----|----------|
| SD_BA<0> | K5 | Bank address |
| SD_BA<1> | K6 | Bank address |
| SD_RAS | C1 | Row address strobe |
| SD_CAS | C2 | Column address strobe |
| SD_WE | D1 | Write enable |
| SD_CK_P | J5 | Differential clock + |
| SD_CK_N | J4 | Differential clock - |
| SD_CKE | K3 | Clock enable |
| SD_CS | K4 | Chip select (active-low) |
| SD_LDM | J2 | Lower data mask |
| SD_UDM | J1 | Upper data mask |
| SD_LDQS | L6 | Lower data strobe |
| SD_UDQS | G3 | Upper data strobe |
| SD_CK_FB | B9 | Clock feedback (Bank 0, LVCMOS33) |

### VREF (prohibited pins)

D2, G4, J6, L5, R4

## Ethernet PHY (LVCMOS33)

| Signal | Pin | Direction |
|--------|-----|-----------|
| E_TXD<0> | R11 | Output |
| E_TXD<1> | T15 | Output |
| E_TXD<2> | R5 | Output |
| E_TXD<3> | T5 | Output |
| E_TXD<4> | R6 | Output (TX_ER) |
| E_TX_EN | P15 | Output |
| E_TX_CLK | T7 | Input |
| E_RXD<0> | V8 | Input |
| E_RXD<1> | T11 | Input |
| E_RXD<2> | U11 | Input |
| E_RXD<3> | V14 | Input |
| E_RXD<4> | U14 | Input (RX_ER) |
| E_RX_DV | V2 | Input |
| E_RX_CLK | V3 | Input |
| E_CRS | U13 | Input |
| E_COL | U6 | Input |
| E_MDC | P9 | Output |
| E_MDIO | U5 | Bidir |

## StrataFlash (LVCMOS33)

### Address (SF_A<0> to SF_A<24>)

| Signal | Pin |
|--------|-----|
| SF_A<0> | H17 |
| SF_A<1> | J13 |
| SF_A<2> | J12 |
| SF_A<3> | J14 |
| SF_A<4> | J15 |
| SF_A<5> | J16 |
| SF_A<6> | J17 |
| SF_A<7> | K14 |
| SF_A<8> | K15 |
| SF_A<9> | K12 |
| SF_A<10> | K13 |
| SF_A<11> | L15 |
| SF_A<12> | L16 |
| SF_A<13> | T18 |
| SF_A<14> | R18 |
| SF_A<15> | T17 |
| SF_A<16> | U18 |
| SF_A<17> | T16 |
| SF_A<18> | U15 |
| SF_A<19> | V15 |
| SF_A<20> | T12 |
| SF_A<21> | V13 |
| SF_A<22> | V12 |
| SF_A<23> | N11 |
| SF_A<24> | A11 |

### Data (SF_D<1> to SF_D<15>, SF_D<0> = SPI_MISO)

| Signal | Pin |
|--------|-----|
| SF_D<1> | P10 |
| SF_D<2> | R10 |
| SF_D<3> | V9 |
| SF_D<4> | U9 |
| SF_D<5> | R9 |
| SF_D<6> | M9 |
| SF_D<7> | N9 |
| SF_D<8> | R15 |
| SF_D<9> | R16 |
| SF_D<10> | P17 |
| SF_D<11> | M15 |
| SF_D<12> | M16 |
| SF_D<13> | P6 |
| SF_D<14> | R8 |
| SF_D<15> | T8 |

### Control

| Signal | Pin | Function |
|--------|-----|----------|
| SF_CE0 | D16 | Chip enable (active-low) |
| SF_OE | C18 | Output enable (active-low) |
| SF_WE | D17 | Write enable (active-low) |
| SF_BYTE | C17 | Byte mode (0=x8, 1=x16) |
| SF_STS | B18 | Status (input) |

## FPGA Configuration / CPLD

| Signal | Pin |
|--------|-----|
| FPGA_M0 | M10 |
| FPGA_M1 | V11 |
| FPGA_M2 | T10 |
| FPGA_INIT_B | T3 |
| XC_CMD<0> | P18 |
| XC_CMD<1> | N18 |
| XC_D<0> | G16 |
| XC_D<1> | F18 |
| XC_D<2> | F17 |
| XC_CPLD_EN | B10 |
| XC_TRIG | R17 |
| XC_GCK0 | H16 |

## FX2 Expansion Connector (selected)

| Signal | Pin | Shared with |
|--------|-----|-------------|
| FX2_IO<1> | B4 | J1 header |
| FX2_IO<2> | A4 | J1 header |
| FX2_IO<3> | D5 | J1 header |
| FX2_IO<4> | C5 | J1 header |
| FX2_IO<5> | A6 | J2 header |
| FX2_IO<6> | B6 | J2 header |
| FX2_IO<7> | E7 | J2 header |
| FX2_IO<8> | F7 | J2 header |
| FX2_IO<9> | D7 | J4 header |
| FX2_IO<10> | C7 | J4 header |
| FX2_IO<11> | F8 | J4 header |
| FX2_IO<12> | E8 | J4 header |
| FX2_IO<13–20> | F9,E9,D11,C11,F11,E11,E12,F12 | LEDs |
| FX2_CLKIN | E10 | GCLK5 |
| FX2_CLKOUT | D10 | GCLK4 |
| FX2_CLKIO | D9 | |

## 1-Wire EEPROM

| Signal | Pin |
|--------|-----|
| DS_WIRE | U4 |
