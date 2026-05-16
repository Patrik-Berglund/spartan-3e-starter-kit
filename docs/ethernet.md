# 10/100 Ethernet PHY

SMSC LAN83C185 with RJ-45 connector. Requires Ethernet MAC implemented in FPGA. Clocked by on-board 25 MHz crystal.

## MII Interface

| Signal | Pin | Direction | Function |
|--------|-----|-----------|----------|
| E_TXD<0> | R11 | Output | Transmit data |
| E_TXD<1> | T15 | Output | Transmit data |
| E_TXD<2> | R5 | Output | Transmit data |
| E_TXD<3> | T5 | Output | Transmit data |
| E_TXD<4> | R6 | Output | TX Error |
| E_TX_EN | P15 | Output | Transmit enable |
| E_TX_CLK | T7 | Input | TX clock (25 MHz @ 100M, 2.5 MHz @ 10M) |
| E_RXD<0> | V8 | Input | Receive data |
| E_RXD<1> | T11 | Input | Receive data |
| E_RXD<2> | U11 | Input | Receive data |
| E_RXD<3> | V14 | Input | Receive data |
| E_RXD<4> | U14 | Input | RX Error |
| E_RX_DV | V2 | Input | Receive data valid |
| E_RX_CLK | V3 | Input | RX clock (25 MHz @ 100M, 2.5 MHz @ 10M) |
| E_CRS | U13 | Input | Carrier sense |
| E_COL | U6 | Input | Collision detect |
| E_MDC | P9 | Output | Management clock |
| E_MDIO | U5 | Bidir | Management data |

## Notes

- OPB bus clock must be ≥65 MHz for 100 Mbps, ≥6.5 MHz for 10 Mbps
- Xilinx OPB Ethernet MAC or Ethernet Lite MAC available in EDK
- Ethernet Lite uses fewer resources (no interrupts, no stats counters)

## UCF

```
NET "E_COL"      LOC = "U6"  | IOSTANDARD = LVCMOS33 ;
NET "E_CRS"      LOC = "U13" | IOSTANDARD = LVCMOS33 ;
NET "E_MDC"      LOC = "P9"  | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
NET "E_MDIO"     LOC = "U5"  | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
NET "E_RX_CLK"   LOC = "V3"  | IOSTANDARD = LVCMOS33 ;
NET "E_RX_DV"    LOC = "V2"  | IOSTANDARD = LVCMOS33 ;
NET "E_RXD<0>"   LOC = "V8"  | IOSTANDARD = LVCMOS33 ;
NET "E_RXD<1>"   LOC = "T11" | IOSTANDARD = LVCMOS33 ;
NET "E_RXD<2>"   LOC = "U11" | IOSTANDARD = LVCMOS33 ;
NET "E_RXD<3>"   LOC = "V14" | IOSTANDARD = LVCMOS33 ;
NET "E_RXD<4>"   LOC = "U14" | IOSTANDARD = LVCMOS33 ;
NET "E_TX_CLK"   LOC = "T7"  | IOSTANDARD = LVCMOS33 ;
NET "E_TX_EN"    LOC = "P15" | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
NET "E_TXD<0>"   LOC = "R11" | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
NET "E_TXD<1>"   LOC = "T15" | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
NET "E_TXD<2>"   LOC = "R5"  | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
NET "E_TXD<3>"   LOC = "T5"  | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
NET "E_TXD<4>"   LOC = "R6"  | IOSTANDARD = LVCMOS33 | SLEW = SLOW | DRIVE = 8 ;
```
