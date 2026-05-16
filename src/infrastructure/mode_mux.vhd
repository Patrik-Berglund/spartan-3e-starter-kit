library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Mode mux: counts ROT_CENTER presses modulo NUM_MODES.
-- Outputs active_mode index and mode name for LCD line 1.

entity mode_mux is
  generic (
    G_NUM_MODES : integer := 9
  );
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    rot_press   : in  std_logic;
    active_mode : out integer range 0 to G_NUM_MODES-1;
    mode_name   : out std_logic_vector(127 downto 0)  -- 16 chars
  );
end entity mode_mux;

architecture rtl of mode_mux is
  signal mode_idx : integer range 0 to G_NUM_MODES-1 := 0;

  type name_array is array (0 to G_NUM_MODES-1) of std_logic_vector(127 downto 0);

  -- Helper: convert string to 128-bit vector (16 chars, padded with spaces)
  function str_to_slv(s : string) return std_logic_vector is
    variable result : std_logic_vector(127 downto 0) := (others => '0');
  begin
    for i in 1 to 16 loop
      if i <= s'length then
        result(127 - (i-1)*8 downto 120 - (i-1)*8) :=
          std_logic_vector(to_unsigned(character'pos(s(i)), 8));
      else
        result(127 - (i-1)*8 downto 120 - (i-1)*8) := x"20";  -- space
      end if;
    end loop;
    return result;
  end function;

  constant NAMES : name_array := (
    0 => str_to_slv("1:LED Chaser    "),
    1 => str_to_slv("2:DAC Waveform  "),
    2 => str_to_slv("3:ADC Voltmeter "),
    3 => str_to_slv("4:UART Echo     "),
    4 => str_to_slv("5:PS/2 Keyboard "),
    5 => str_to_slv("6:SPI Flash ID  "),
    6 => str_to_slv("7:DDR MemTest   "),
    7 => str_to_slv("8:VGA Pattern   "),
    8 => str_to_slv("9:Ethernet Ping ")
  );
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        mode_idx <= 0;
      elsif rot_press = '1' then
        if mode_idx = G_NUM_MODES - 1 then
          mode_idx <= 0;
        else
          mode_idx <= mode_idx + 1;
        end if;
      end if;
    end if;
  end process;

  active_mode <= mode_idx;
  mode_name   <= NAMES(mode_idx);

end architecture rtl;
