library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_echo is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    rxd       : in  std_logic;
    txd       : out std_logic;
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity uart_echo;

architecture rtl of uart_echo is
  -- Baud rate: 115200 @ 50 MHz → divide by 434
  constant C_BAUD_DIV : integer := 434;

  -- RX signals
  signal rx_baud_cnt : integer range 0 to C_BAUD_DIV-1 := 0;
  signal rx_bit_cnt  : integer range 0 to 9 := 0;
  signal rx_shift    : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_busy     : std_logic := '0';
  signal rx_valid    : std_logic := '0';
  signal rx_data     : std_logic_vector(7 downto 0) := (others => '0');
  signal rxd_sync    : std_logic_vector(1 downto 0) := "11";

  -- TX signals
  signal tx_baud_cnt : integer range 0 to C_BAUD_DIV-1 := 0;
  signal tx_bit_cnt  : integer range 0 to 9 := 0;
  signal tx_shift    : std_logic_vector(9 downto 0) := (others => '1');
  signal tx_busy     : std_logic := '0';
  signal tx_start    : std_logic := '0';

  -- Display buffer (16 chars)
  type char_buf_t is array (0 to 15) of std_logic_vector(7 downto 0);
  signal disp_buf : char_buf_t := (others => x"20");
  signal buf_pos  : integer range 0 to 15 := 0;
begin

  -- RX synchronizer
  process(clk)
  begin
    if rising_edge(clk) then
      rxd_sync <= rxd_sync(0) & rxd;
    end if;
  end process;

  -- UART RX
  process(clk)
  begin
    if rising_edge(clk) then
      rx_valid <= '0';
      if rst = '1' then
        rx_busy <= '0';
        rx_baud_cnt <= 0;
      elsif rx_busy = '0' then
        if rxd_sync(1) = '0' then  -- start bit
          rx_busy <= '1';
          rx_baud_cnt <= C_BAUD_DIV / 2;  -- sample mid-bit
          rx_bit_cnt <= 0;
        end if;
      else
        if rx_baud_cnt = C_BAUD_DIV - 1 then
          rx_baud_cnt <= 0;
          if rx_bit_cnt = 9 then  -- stop bit
            rx_busy <= '0';
            if rxd_sync(1) = '1' then
              rx_valid <= '1';
              rx_data <= rx_shift;
            end if;
          else
            if rx_bit_cnt >= 1 then
              rx_shift <= rxd_sync(1) & rx_shift(7 downto 1);
            end if;
            rx_bit_cnt <= rx_bit_cnt + 1;
          end if;
        else
          rx_baud_cnt <= rx_baud_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- UART TX
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        tx_busy <= '0';
        tx_shift <= (others => '1');
      elsif tx_busy = '0' then
        if tx_start = '1' then
          tx_shift <= '1' & rx_data & '0';  -- stop + data + start
          tx_busy <= '1';
          tx_baud_cnt <= 0;
          tx_bit_cnt <= 0;
        end if;
      else
        if tx_baud_cnt = C_BAUD_DIV - 1 then
          tx_baud_cnt <= 0;
          tx_shift <= '1' & tx_shift(9 downto 1);
          if tx_bit_cnt = 9 then
            tx_busy <= '0';
          else
            tx_bit_cnt <= tx_bit_cnt + 1;
          end if;
        else
          tx_baud_cnt <= tx_baud_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  txd <= tx_shift(0) when enable = '1' else '1';

  -- Echo: on rx_valid, start TX and update display
  process(clk)
  begin
    if rising_edge(clk) then
      tx_start <= '0';
      if rst = '1' or enable = '0' then
        buf_pos <= 0;
        disp_buf <= (others => x"20");
      elsif rx_valid = '1' and enable = '1' then
        tx_start <= '1';
        disp_buf(buf_pos) <= rx_data;
        if buf_pos = 15 then
          buf_pos <= 0;
        else
          buf_pos <= buf_pos + 1;
        end if;
      end if;
    end if;
  end process;

  -- LCD output
  process(disp_buf)
    variable tmp : std_logic_vector(127 downto 0);
  begin
    for i in 0 to 15 loop
      tmp(127 - i*8 downto 120 - i*8) := disp_buf(i);
    end loop;
    lcd_line2 <= tmp;
  end process;

end architecture rtl;
