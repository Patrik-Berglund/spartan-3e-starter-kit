library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_flash_id is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    -- SPI interface
    spi_start : out std_logic;
    spi_tx    : out std_logic_vector(31 downto 0);
    spi_rx    : in  std_logic_vector(31 downto 0);
    spi_busy  : in  std_logic;
    spi_done  : in  std_logic;
    spi_ss_b  : out std_logic;
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity spi_flash_id;

architecture rtl of spi_flash_id is
  type state_t is (S_IDLE, S_SEND, S_WAIT, S_DONE);
  signal state   : state_t := S_IDLE;
  signal id_data : std_logic_vector(23 downto 0) := (others => '0');
  signal read_ok : std_logic := '0';

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

  process(clk)
  begin
    if rising_edge(clk) then
      spi_start <= '0';

      if rst = '1' then
        state   <= S_IDLE;
        spi_ss_b <= '1';
        read_ok <= '0';
      elsif enable = '0' then
        state   <= S_IDLE;
        spi_ss_b <= '1';
      else
        case state is
          when S_IDLE =>
            spi_ss_b <= '1';
            if read_ok = '0' and spi_busy = '0' then
              state <= S_SEND;
            end if;

          when S_SEND =>
            spi_ss_b <= '0';
            -- RDID command: 0x9F + 24 dummy clocks
            spi_tx <= x"9F000000";
            spi_start <= '1';
            state <= S_WAIT;

          when S_WAIT =>
            spi_ss_b <= '0';
            if spi_done = '1' then
              id_data <= spi_rx(23 downto 0);
              state <= S_DONE;
            end if;

          when S_DONE =>
            spi_ss_b <= '1';
            read_ok <= '1';
            state <= S_IDLE;
        end case;
      end if;
    end if;
  end process;

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
