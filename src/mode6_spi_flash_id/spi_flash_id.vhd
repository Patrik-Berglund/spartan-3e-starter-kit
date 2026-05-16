library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_flash_id is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    -- Direct SPI pins
    spi_sck   : out std_logic;
    spi_mosi  : out std_logic;
    spi_miso  : in  std_logic;
    spi_ss_b  : out std_logic;
    -- Disable other SPI devices
    dac_cs    : out std_logic;
    amp_cs    : out std_logic;
    ad_conv   : out std_logic;
    -- Debug
    led       : out std_logic_vector(7 downto 0);
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity spi_flash_id;

architecture rtl of spi_flash_id is
  type state_t is (S_IDLE, S_START, S_CLOCK, S_DONE);
  signal state    : state_t := S_IDLE;
  signal bit_cnt  : integer range 0 to 31 := 0;
  signal clk_div  : unsigned(3 downto 0) := (others => '0');
  signal shift_tx : std_logic_vector(31 downto 0) := (others => '0');
  signal shift_rx : std_logic_vector(23 downto 0) := (others => '0');
  signal id_data  : std_logic_vector(23 downto 0) := (others => '0');
  signal read_ok  : std_logic := '0';
  signal sck_int  : std_logic := '0';

  function char_to_slv(c : character) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(character'pos(c), 8));
  end function;

  function hex_char(v : std_logic_vector(3 downto 0)) return std_logic_vector is
    variable c : integer;
  begin
    c := to_integer(unsigned(v));
    if c < 10 then
      return std_logic_vector(to_unsigned(48 + c, 8));
    else
      return std_logic_vector(to_unsigned(55 + c, 8));
    end if;
  end function;
begin

  -- Disable other SPI devices
  dac_cs  <= '1';
  amp_cs  <= '1';
  ad_conv <= '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state   <= S_IDLE;
        spi_ss_b <= '1';
        sck_int <= '0';
        read_ok <= '0';
      elsif enable = '0' then
        state   <= S_IDLE;
        spi_ss_b <= '1';
        sck_int <= '0';
      else
        case state is
          when S_IDLE =>
            spi_ss_b <= '1';
            sck_int <= '0';
            if read_ok = '0' then
              state <= S_START;
            end if;

          when S_START =>
            spi_ss_b <= '0';
            sck_int <= '0';
            shift_tx <= x"9F000000";
            shift_rx <= (others => '0');
            bit_cnt <= 31;
            clk_div <= (others => '0');
            state <= S_CLOCK;

          when S_CLOCK =>
            spi_ss_b <= '0';
            clk_div <= clk_div + 1;

            if clk_div = 7 then
              -- Rising edge: sample MISO
              sck_int <= '1';
              if bit_cnt < 24 then
                shift_rx <= shift_rx(22 downto 0) & spi_miso;
              end if;
            elsif clk_div = 15 then
              -- Falling edge: shift MOSI
              sck_int <= '0';
              shift_tx <= shift_tx(30 downto 0) & '0';
              if bit_cnt = 0 then
                state <= S_DONE;
              else
                bit_cnt <= bit_cnt - 1;
              end if;
              clk_div <= (others => '0');
            end if;

          when S_DONE =>
            spi_ss_b <= '1';
            sck_int <= '0';
            id_data <= shift_rx;
            read_ok <= '1';
            state <= S_IDLE;

          when others =>
            state <= S_IDLE;
        end case;
      end if;
    end if;
  end process;

  spi_sck  <= sck_int;
  spi_mosi <= shift_tx(31);

  -- Debug: show raw MISO and state on LEDs when in this mode
  -- LED0 = spi_miso, LED1 = spi_ss_b (should go low during transfer), LED7 = read_ok
  led(0) <= spi_miso;
  led(1) <= '0';
  led(2) <= sck_int;
  led(3) <= shift_tx(31);
  led(4) <= id_data(0);  -- should be '1' if we got 0x15
  led(5) <= id_data(4);  -- should be '1' if we got 0x15
  led(6) <= id_data(8);  -- should be '0' if we got 0x20
  led(7) <= read_ok;

  -- LCD: "ID: XX XX XX    "
  lcd_line2 <=
    char_to_slv('I') & char_to_slv('D') & char_to_slv(':') & char_to_slv(' ') &
    hex_char(id_data(23 downto 20)) & hex_char(id_data(19 downto 16)) &
    char_to_slv(' ') &
    hex_char(id_data(15 downto 12)) & hex_char(id_data(11 downto 8)) &
    char_to_slv(' ') &
    hex_char(id_data(7 downto 4)) & hex_char(id_data(3 downto 0)) &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ');

end architecture rtl;
