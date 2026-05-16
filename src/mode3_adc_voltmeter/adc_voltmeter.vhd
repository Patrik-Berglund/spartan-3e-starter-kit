library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_voltmeter is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    -- Shared SPI bus interface
    spi_tx    : out std_logic_vector(31 downto 0);
    spi_rx    : in  std_logic_vector(31 downto 0);
    spi_bits  : out unsigned(5 downto 0);
    spi_start : out std_logic;
    spi_done  : in  std_logic;
    spi_busy  : in  std_logic;
    -- CS select: 0=none, 1=DAC, 2=AMP, 3=Flash, 4=ADC
    cs_sel    : out unsigned(2 downto 0);
    -- Outputs
    led       : out std_logic_vector(7 downto 0);
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity adc_voltmeter;

architecture rtl of adc_voltmeter is
  type state_t is (S_INIT_AMP, S_WAIT_AMP, S_IDLE, S_CONV, S_WAIT_ADC, S_DISPLAY);
  signal state     : state_t := S_INIT_AMP;
  signal prescale  : unsigned(15 downto 0) := (others => '0');
  signal adc_data  : signed(13 downto 0) := (others => '0');
  signal voltage   : unsigned(13 downto 0) := (others => '0');
  signal amp_done  : std_logic := '0';

  function char_to_slv(c : character) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(character'pos(c), 8));
  end function;

  function hex_char(v : unsigned(3 downto 0)) return std_logic_vector is
    variable c : integer;
  begin
    c := to_integer(v);
    if c < 10 then
      return std_logic_vector(to_unsigned(48 + c, 8));
    else
      return std_logic_vector(to_unsigned(55 + c, 8));
    end if;
  end function;
begin

  process(clk)
  begin
    if rising_edge(clk) then
      spi_start <= '0';

      if rst = '1' or enable = '0' then
        state    <= S_INIT_AMP;
        prescale <= (others => '0');
        amp_done <= '0';
        cs_sel   <= "000";
      else
        case state is
          -- Program amp: gain=-1 for both channels (0x11)
          when S_INIT_AMP =>
            if amp_done = '0' and spi_busy = '0' then
              spi_tx   <= x"11000000";  -- gain code 0001_0001 (gain=-1 both ch)
              spi_bits <= to_unsigned(8, 6);
              cs_sel   <= "010";  -- AMP
              spi_start <= '1';
              state    <= S_WAIT_AMP;
            elsif amp_done = '1' then
              state <= S_IDLE;
            end if;

          when S_WAIT_AMP =>
            cs_sel <= "010";
            if spi_done = '1' then
              amp_done <= '1';
              cs_sel   <= "000";
              state    <= S_IDLE;
            end if;

          -- Wait for sample interval (~1 kHz)
          when S_IDLE =>
            cs_sel <= "000";
            if prescale = 50000 then
              prescale <= (others => '0');
              state <= S_CONV;
            else
              prescale <= prescale + 1;
            end if;

          -- Start ADC conversion + read
          when S_CONV =>
            if spi_busy = '0' then
              spi_tx   <= (others => '0');  -- dummy data
              spi_bits <= to_unsigned(32, 6);  -- 32 clocks (captures ch0 in bits 29:16)
              cs_sel   <= "100";  -- ADC (AD_CONV)
              spi_start <= '1';
              state    <= S_WAIT_ADC;
            end if;

          when S_WAIT_ADC =>
            cs_sel <= "100";
            if spi_done = '1' then
              cs_sel <= "000";
              state  <= S_DISPLAY;
            end if;

          when S_DISPLAY =>
            -- Channel 0 is in bits 29:16 of rx_data (after 2 hi-Z bits)
            adc_data <= signed(spi_rx(29 downto 16));
            state <= S_IDLE;

        end case;
      end if;
    end if;
  end process;

  -- Convert to magnitude for display
  process(clk)
  begin
    if rising_edge(clk) then
      if adc_data < 0 then
        voltage <= unsigned(-adc_data);
      else
        voltage <= unsigned(adc_data);
      end if;
    end if;
  end process;

  -- LED bar graph
  process(voltage, enable)
    variable level : integer;
  begin
    led <= (others => '0');
    if enable = '1' then
      level := to_integer(voltage(13 downto 11));
      for i in 0 to 7 loop
        if i <= level then
          led(i) <= '1';
        end if;
      end loop;
    end if;
  end process;

  -- LCD: "CH0: XXXX       "
  lcd_line2 <=
    char_to_slv('C') & char_to_slv('H') & char_to_slv('0') & char_to_slv(':') &
    char_to_slv(' ') &
    hex_char(unsigned(std_logic_vector(adc_data(13 downto 12))) & "00") &
    hex_char(unsigned(adc_data(11 downto 8))) &
    hex_char(unsigned(adc_data(7 downto 4))) &
    hex_char(unsigned(adc_data(3 downto 0))) &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ') &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ');

end architecture rtl;
