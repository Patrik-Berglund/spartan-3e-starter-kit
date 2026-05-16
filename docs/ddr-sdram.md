# DDR SDRAM

Micron MT46V32M16 — 512 Mbit (32M×16), DDR, 100+ MHz. All signals in FPGA I/O Bank 3 (VCCO=2.5V, SSTL2_I).

## Key Parameters

- Organization: 32M × 16
- Interface: 16-bit data, 13-bit address, 2-bit bank
- VREF: 1.25V (resistor divider from 2.5V)
- Clock feedback: SD_CK_P fed back to FPGA pin B9 (Bank 0, GCLK9) for DCM alignment

## UCF Constraints

```
# Address
NET "SD_A<0>"   LOC = "T1"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<1>"   LOC = "R3"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<2>"   LOC = "R2"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<3>"   LOC = "P1"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<4>"   LOC = "F4"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<5>"   LOC = "H4"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<6>"   LOC = "H3"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<7>"   LOC = "H1"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<8>"   LOC = "H2"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<9>"   LOC = "N4"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<10>"  LOC = "T2"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<11>"  LOC = "N5"  | IOSTANDARD = SSTL2_I ;
NET "SD_A<12>"  LOC = "P2"  | IOSTANDARD = SSTL2_I ;

# Bank
NET "SD_BA<0>"  LOC = "K5"  | IOSTANDARD = SSTL2_I ;
NET "SD_BA<1>"  LOC = "K6"  | IOSTANDARD = SSTL2_I ;

# Data
NET "SD_DQ<0>"  LOC = "L2"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<1>"  LOC = "L1"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<2>"  LOC = "L3"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<3>"  LOC = "L4"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<4>"  LOC = "M3"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<5>"  LOC = "M4"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<6>"  LOC = "M5"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<7>"  LOC = "M6"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<8>"  LOC = "E2"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<9>"  LOC = "E1"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<10>" LOC = "F1"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<11>" LOC = "F2"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<12>" LOC = "G6"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<13>" LOC = "G5"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<14>" LOC = "H6"  | IOSTANDARD = SSTL2_I ;
NET "SD_DQ<15>" LOC = "H5"  | IOSTANDARD = SSTL2_I ;

# Control
NET "SD_RAS"    LOC = "C1"  | IOSTANDARD = SSTL2_I ;
NET "SD_CAS"    LOC = "C2"  | IOSTANDARD = SSTL2_I ;
NET "SD_WE"     LOC = "D1"  | IOSTANDARD = SSTL2_I ;
NET "SD_CK_P"   LOC = "J5"  | IOSTANDARD = SSTL2_I ;
NET "SD_CK_N"   LOC = "J4"  | IOSTANDARD = SSTL2_I ;
NET "SD_CKE"    LOC = "K3"  | IOSTANDARD = SSTL2_I ;
NET "SD_CS"     LOC = "K4"  | IOSTANDARD = SSTL2_I ;
NET "SD_LDM"    LOC = "J2"  | IOSTANDARD = SSTL2_I ;
NET "SD_UDM"    LOC = "J1"  | IOSTANDARD = SSTL2_I ;
NET "SD_LDQS"   LOC = "L6"  | IOSTANDARD = SSTL2_I ;
NET "SD_UDQS"   LOC = "G3"  | IOSTANDARD = SSTL2_I ;

# Clock feedback (Bank 0)
NET "SD_CK_FB"  LOC = "B9"  | IOSTANDARD = LVCMOS33 ;

# Prohibit VREF pins
CONFIG PROHIBIT = D2;
CONFIG PROHIBIT = G4;
CONFIG PROHIBIT = J6;
CONFIG PROHIBIT = L5;
CONFIG PROHIBIT = R4;
```

## Clock Feedback

SD_CK_P is routed back to FPGA pin B9 (GCLK9 in Bank 0). This allows a DCM to align the internal clock with the actual clock arriving at the SDRAM. Required by the MicroBlaze OPB DDR controller.

## Notes

- All DDR signals are series-terminated on the board
- OPB bus clock must be ≥65 MHz for proper DDR operation
- 2.5V supply from LTC3412 regulator
