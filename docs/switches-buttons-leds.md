# Switches, Buttons, and LEDs

## Slide Switches (4)

Located lower-right. SW3 is left-most, SW0 is right-most.

- UP/ON = 3.3V (logic High)
- DOWN/OFF = GND (logic Low)
- ~2 ms mechanical bounce (no hardware debounce)

| Signal | Pin | IOSTANDARD |
|--------|-----|------------|
| SW<0> | L13 | LVTTL + PULLUP |
| SW<1> | L14 | LVTTL + PULLUP |
| SW<2> | H18 | LVTTL + PULLUP |
| SW<3> | N17 | LVTTL + PULLUP |

## Push Buttons (4)

Located lower-left, surrounding rotary encoder.

- Pressed = 3.3V (logic High)
- Released = floating → use PULLDOWN
- No hardware debounce
- BTN_SOUTH often used as soft reset

| Signal | Pin | IOSTANDARD |
|--------|-----|------------|
| BTN_NORTH | V4 | LVTTL + PULLDOWN |
| BTN_EAST | H13 | LVTTL + PULLDOWN |
| BTN_SOUTH | K17 | LVTTL + PULLDOWN |
| BTN_WEST | D18 | LVTTL + PULLDOWN |

## Rotary Encoder

Center of the four push buttons. Has shaft rotation + push-button.

### Push Button (ROT_CENTER)

- Same as other push buttons: pressed = 3.3V
- Use PULLDOWN

### Shaft Encoder (ROT_A, ROT_B)

- Two switches operated by rotating cam
- Detent position: both switches closed (Low via pull-up)
- Open switch = High (use PULLUP)
- Decode rotation by detecting which signal transitions first
- Mechanical chatter present — must debounce in FPGA logic

| Signal | Pin | IOSTANDARD |
|--------|-----|------------|
| ROT_A | K18 | LVTTL + PULLUP |
| ROT_B | G18 | LVTTL + PULLUP |
| ROT_CENTER | V16 | LVTTL + PULLDOWN |

### Rotation Decoding

- Rising edge on ROT_A when ROT_B is Low → clockwise (right)
- Rising edge on ROT_B when ROT_A is Low → counter-clockwise (left)
- Filter chatter before decoding

## Discrete LEDs (8)

Located above slide switches. LED7 is left-most, LED0 is right-most.

- Active-high: drive High to light
- Connected to FPGA via 390Ω resistor to GND
- Shared with FX2 connector pins FX2_IO<13:20>

| Signal | Pin | IOSTANDARD |
|--------|-----|------------|
| LED<0> | F12 | LVTTL, SLEW=SLOW, DRIVE=8 |
| LED<1> | E12 | LVTTL, SLEW=SLOW, DRIVE=8 |
| LED<2> | E11 | LVTTL, SLEW=SLOW, DRIVE=8 |
| LED<3> | F11 | LVTTL, SLEW=SLOW, DRIVE=8 |
| LED<4> | C11 | LVTTL, SLEW=SLOW, DRIVE=8 |
| LED<5> | D11 | LVTTL, SLEW=SLOW, DRIVE=8 |
| LED<6> | E9 | LVTTL, SLEW=SLOW, DRIVE=8 |
| LED<7> | F9 | LVTTL, SLEW=SLOW, DRIVE=8 |
