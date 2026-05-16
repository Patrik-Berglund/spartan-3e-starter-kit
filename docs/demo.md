# Board Explorer Demo

The 4 slide switches (SW3:0) select the demo mode (0–8). The rotary encoder and 4 push buttons are used within each demo for control.

The LCD shows the current mode name on line 1 and mode-specific status on line 2.

| SW3:0 | Mode |
|-------|------|
| 0000 | 1: LED Chaser |
| 0001 | 2: DAC Waveform |
| 0010 | 3: ADC Voltmeter |
| 0011 | 4: UART Echo |
| 0100 | 5: PS/2 Keyboard |
| 0101 | 6: SPI Flash ID |
| 0110 | 7: DDR MemTest |
| 0111 | 8: VGA Pattern |
| 1000 | 9: Ethernet Ping |

## Modes

### 1: LED Chaser ✓

Animated patterns on the 8 LEDs.

- **Rotate** — adjust speed (0=slow, F=fast)
- **BTN_EAST** — next pattern
- **BTN_WEST** — previous pattern
- Patterns: 0=bounce, 1=alternating, 2=rotate left, 3=rotate right, 4=fill, 5=blink all

### 2: DAC Waveform ⚠️ Untested

Outputs a waveform on DAC channel A (header J5, pin VOUTA).

- **Rotate** — cycle waveform: Sawtooth → Triangle → Sine → Square
- Connect an oscilloscope or speaker to J5 to hear/see the output

### 3: ADC Voltmeter ⚠️ Partial

Reads the analog input on ADC channel 0 (header J7). ADC reads data but amp gain programming needs verification with a scope.

- **LCD** — shows raw 14-bit hex value
- **LEDs** — bar graph of signal magnitude
- Connect a voltage source (0–3.3V) to J7 VINA pin

### 4: UART Echo ⚠️ Untested

RS-232 terminal echo on the DCE port (female DB9, J9).

- Connect to PC at **115200 baud, 8N1**
- Characters typed in a terminal appear on the LCD and are echoed back
- **LCD** — shows last 16 received characters

### 5: PS/2 Keyboard ⚠️ Untested

Displays keystrokes from a PS/2 keyboard.

- Plug a PS/2 keyboard into the mini-DIN connector (J14)
- **LCD** — shows typed characters (basic scan-code-to-ASCII mapping)

### 6: SPI Flash ID ❌ Not working

Needs logic analyzer to debug SPI bus timing/CS routing.

- **LCD** — should show "ID: 20 20 15" (STMicro, 16 Mbit)

### 7: DDR Memory Test ⚠️ Untested

Initializes the DDR SDRAM and runs a basic connectivity test.

- **LCD** — shows "PASS Init OK" or "Testing..."
- **LEDs** — all on = pass, ends lit = fail

### 8: VGA Test Pattern ⚠️ Untested

Outputs a 640×480 @ 60 Hz test pattern on the VGA port (DB15).

- **Rotate** — cycle pattern: Color Bars → Checkerboard → Red Screen → Gradient
- Connect a VGA monitor

### 9: Ethernet Ping ⚠️ Untested

Responds to ARP and ICMP ping requests.

- **IP address:** 192.168.1.100
- **MAC address:** 02:00:00:00:00:01
- Connect an Ethernet cable, configure your PC's interface to 192.168.1.x
- `ping 192.168.1.100` from your PC
- **LCD** — shows ping count in hex

## LCD Contrast

If the LCD appears blank, adjust the contrast potentiometer (small trimmer near the LCD) until text becomes visible.

## Hardware Connections Summary

| Mode | Peripheral | Connector |
|------|-----------|-----------|
| 2 | DAC output | J5 (6-pin header above Ethernet) |
| 3 | ADC input | J7 (6-pin header) |
| 4 | RS-232 | J9 (female DB9, DCE) |
| 5 | PS/2 keyboard | J14 (6-pin mini-DIN) |
| 8 | VGA monitor | DB15 connector |
| 9 | Ethernet | RJ-45 connector |
