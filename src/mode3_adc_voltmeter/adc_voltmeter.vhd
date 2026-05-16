library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_voltmeter is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    -- SPI/ADC interface
    spi_sck   : out std_logic;
    spi_miso  : in  std_logic;
    ad_conv   : out std_logic;
    amp_cs    : out std_logic;
    -- Outputs
    led       : out std_logic_vector(7 downto 0);
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity adc_voltmeter;

architecture rtl of adc_voltmeter is
  type state_t is (S_IDLE, S_CONV, S_WAIT, S_CLOCK, S_DISPLAY);
  signal state     : state_t := S_IDLE;
  signal prescale  : unsigned(15 downto 0) := (others => '0');
  signal sck_cnt   : integer range 0 to 34 := 0;
  signal bit_cnt   : integer range 0 to 7 := 0;
  signal shift_reg : std_logic_vector(13 downto 0) := (others => '0');
  signal adc_data  : signed(13 downto 0) := (others => '0');
  signal voltage   : unsigned(13 downto 0) := (others => '0');
  signal sck_int   : std_logic := '0';
  signal clk_div   : unsigned(2 downto 0) := (others => '0');
  signal sample_rdy: std_logic := '0';

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

  amp_cs <= '1';  -- disable pre-amp

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or enable = '0' then
        state     <= S_IDLE;
        prescale  <= (others => '0');
        ad_conv   <= '0';
        sck_int   <= '0';
        sck_cnt   <= 0;
        sample_rdy <= '0';
      else
        sample_rdy <= '0';

        case state is
          when S_IDLE =>
            ad_conv <= '0';
            sck_int <= '0';
            -- Sample at ~1 kHz
            if prescale = 50000 then
              prescale <= (others => '0');
              state <= S_CONV;
            else
              prescale <= prescale + 1;
            end if;

          when S_CONV =>
            ad_conv <= '1';
            state <= S_WAIT;

          when S_WAIT =>
            ad_conv <= '0';
            sck_cnt <= 0;
            clk_div <= (others => '0');
            shift_reg <= (others => '0');
            state <= S_CLOCK;

          when S_CLOCK =>
            clk_div <= clk_div + 1;
            if clk_div = 3 then
              sck_int <= '1';
            elsif clk_div = 7 then
              sck_int <= '0';
              -- Sample MISO on falling edge, bits 2-15 are channel 0
              if sck_cnt >= 2 and sck_cnt <= 15 then
                shift_reg <= shift_reg(12 downto 0) & spi_miso;
              end if;
              sck_cnt <= sck_cnt + 1;
              if sck_cnt = 33 then
                state <= S_DISPLAY;
              end if;
              clk_div <= (others => '0');
            end if;

          when S_DISPLAY =>
            adc_data <= signed(shift_reg);
            sample_rdy <= '1';
            state <= S_IDLE;
        end case;
      end if;
    end if;
  end process;

  spi_sck <= sck_int when enable = '1' else '0';

  -- Convert to magnitude for display
  process(clk)
  begin
    if rising_edge(clk) then
      if sample_rdy = '1' then
        if adc_data < 0 then
          voltage <= unsigned(-adc_data);
        else
          voltage <= unsigned(adc_data);
        end if;
      end if;
    end if;
  end process;

  -- LED bar graph (8 levels from 14-bit magnitude)
  process(voltage)
    variable level : integer;
  begin
    level := to_integer(voltage(13 downto 11));
    led <= (others => '0');
    for i in 0 to 7 loop
      if i <= level then
        led(i) <= '1';
      end if;
    end loop;
  end process;

  -- LCD: "CH0: XXXX raw    "
  lcd_line2 <=
    char_to_slv('C') & char_to_slv('H') & char_to_slv('0') & char_to_slv(':') &
    char_to_slv(' ') &
    hex_char(unsigned(std_logic_vector(adc_data(13 downto 12))) & "00") &
    hex_char(unsigned(adc_data(11 downto 8))) &
    hex_char(unsigned(adc_data(7 downto 4))) &
    hex_char(unsigned(adc_data(3 downto 0))) &
    char_to_slv(' ') & char_to_slv('r') & char_to_slv('a') & char_to_slv('w') &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ');

end architecture rtl;
