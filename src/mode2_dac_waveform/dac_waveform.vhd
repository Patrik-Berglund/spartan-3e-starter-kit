library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_waveform is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    rot_event : in  std_logic;
    rot_dir   : in  std_logic;
    -- Shared SPI bus interface
    spi_start : out std_logic;
    spi_tx    : out std_logic_vector(31 downto 0);
    spi_bits  : out unsigned(5 downto 0);
    spi_busy  : in  std_logic;
    cs_sel    : out unsigned(2 downto 0);
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity dac_waveform;

architecture rtl of dac_waveform is
  signal wave_sel  : unsigned(1 downto 0) := "00";  -- 0=saw,1=tri,2=sine,3=square
  signal phase     : unsigned(19 downto 0) := (others => '0');
  signal dac_val   : unsigned(11 downto 0) := (others => '0');
  signal send_tick : std_logic := '0';
  signal prescale  : unsigned(7 downto 0) := (others => '0');

  -- Simple sine approximation (quarter-wave, 64 entries)
  type sine_lut_t is array (0 to 63) of unsigned(11 downto 0);
  constant SINE_LUT : sine_lut_t := (
    x"800",x"8C8",x"990",x"A57",x"B1D",x"BE2",x"CA4",x"D64",
    x"E20",x"ED9",x"F8D",x"FFC",x"FFC",x"FFC",x"FFC",x"FFC",
    x"FFF",x"FFC",x"FFC",x"FFC",x"FFC",x"FFC",x"F8D",x"ED9",
    x"E20",x"D64",x"CA4",x"BE2",x"B1D",x"A57",x"990",x"8C8",
    x"800",x"738",x"670",x"5A9",x"4E3",x"41E",x"35C",x"29C",
    x"1E0",x"127",x"073",x"004",x"004",x"004",x"004",x"004",
    x"000",x"004",x"004",x"004",x"004",x"004",x"073",x"127",
    x"1E0",x"29C",x"35C",x"41E",x"4E3",x"5A9",x"670",x"738"
  );

  function char_to_slv(c : character) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(character'pos(c), 8));
  end function;

  type name_t is array (0 to 3) of string(1 to 8);
  constant WAVE_NAMES : name_t := ("Sawtooth", "Triangle", "Sine    ", "Square  ");
begin

  -- Waveform select via rotary
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        wave_sel <= "00";
      elsif enable = '1' and rot_event = '1' then
        if rot_dir = '1' then
          wave_sel <= wave_sel + 1;
        else
          wave_sel <= wave_sel - 1;
        end if;
      end if;
    end if;
  end process;

  -- Phase accumulator (~48.8 kHz sample rate at div=1024)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or enable = '0' then
        phase    <= (others => '0');
        prescale <= (others => '0');
        send_tick <= '0';
      else
        send_tick <= '0';
        prescale <= prescale + 1;
        if prescale = 0 then
          phase <= phase + 1;
          send_tick <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Waveform generation
  process(clk)
    variable idx : unsigned(5 downto 0);
    variable tri : unsigned(11 downto 0);
  begin
    if rising_edge(clk) then
      case wave_sel is
        when "00" =>  -- Sawtooth
          dac_val <= phase(19 downto 8);
        when "01" =>  -- Triangle
          if phase(19) = '0' then
            tri := phase(18 downto 7);
          else
            tri := not phase(18 downto 7);
          end if;
          dac_val <= tri;
        when "10" =>  -- Sine (LUT)
          idx := phase(19 downto 14);
          dac_val <= SINE_LUT(to_integer(idx));
        when others =>  -- Square
          if phase(19) = '1' then
            dac_val <= x"FFF";
          else
            dac_val <= x"000";
          end if;
      end case;
    end if;
  end process;

  -- SPI DAC command: write and update channel A
  process(clk)
  begin
    if rising_edge(clk) then
      spi_start <= '0';
      cs_sel    <= "000";
      if enable = '1' and send_tick = '1' and spi_busy = '0' then
        spi_tx <= x"00" & "0011" & "0000" & std_logic_vector(dac_val) & "0000";
        spi_bits <= to_unsigned(32, 6);
        cs_sel    <= "001";  -- DAC
        spi_start <= '1';
      elsif enable = '1' and spi_busy = '1' then
        cs_sel <= "001";
      end if;
    end if;
  end process;

  -- LCD line 2
  lcd_line2 <=
    char_to_slv('W') & char_to_slv('a') & char_to_slv('v') & char_to_slv('e') &
    char_to_slv(':') &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(1)) &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(2)) &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(3)) &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(4)) &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(5)) &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(6)) &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(7)) &
    char_to_slv(WAVE_NAMES(to_integer(wave_sel))(8)) &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ');

end architecture rtl;
