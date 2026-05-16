library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_keyboard is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    ps2_clk   : in  std_logic;
    ps2_data  : in  std_logic;
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity ps2_keyboard;

architecture rtl of ps2_keyboard is
  signal ps2_clk_sync : std_logic_vector(2 downto 0) := "111";
  signal ps2_clk_fall : std_logic := '0';
  signal bit_cnt      : integer range 0 to 10 := 0;
  signal shift_reg    : std_logic_vector(10 downto 0) := (others => '0');
  signal scan_valid   : std_logic := '0';
  signal scan_code    : std_logic_vector(7 downto 0) := (others => '0');
  signal is_break     : std_logic := '0';

  -- Display buffer
  type char_buf_t is array (0 to 15) of std_logic_vector(7 downto 0);
  signal disp_buf : char_buf_t := (others => x"20");
  signal buf_pos  : integer range 0 to 15 := 0;

  -- Simple scan code to ASCII (printable subset)
  function scan_to_ascii(code : std_logic_vector(7 downto 0)) return std_logic_vector is
  begin
    case code is
      when x"1C" => return x"61"; -- a
      when x"32" => return x"62"; -- b
      when x"21" => return x"63"; -- c
      when x"23" => return x"64"; -- d
      when x"24" => return x"65"; -- e
      when x"2B" => return x"66"; -- f
      when x"34" => return x"67"; -- g
      when x"33" => return x"68"; -- h
      when x"43" => return x"69"; -- i
      when x"3B" => return x"6A"; -- j
      when x"42" => return x"6B"; -- k
      when x"4B" => return x"6C"; -- l
      when x"3A" => return x"6D"; -- m
      when x"31" => return x"6E"; -- n
      when x"44" => return x"6F"; -- o
      when x"4D" => return x"70"; -- p
      when x"15" => return x"71"; -- q
      when x"2D" => return x"72"; -- r
      when x"1B" => return x"73"; -- s
      when x"2C" => return x"74"; -- t
      when x"3C" => return x"75"; -- u
      when x"2A" => return x"76"; -- v
      when x"1D" => return x"77"; -- w
      when x"22" => return x"78"; -- x
      when x"35" => return x"79"; -- y
      when x"1A" => return x"7A"; -- z
      when x"29" => return x"20"; -- space
      when x"45" => return x"30"; -- 0
      when x"16" => return x"31"; -- 1
      when x"1E" => return x"32"; -- 2
      when x"26" => return x"33"; -- 3
      when x"25" => return x"34"; -- 4
      when x"2E" => return x"35"; -- 5
      when x"36" => return x"36"; -- 6
      when x"3D" => return x"37"; -- 7
      when x"3E" => return x"38"; -- 8
      when x"46" => return x"39"; -- 9
      when others => return x"2E"; -- '.'
    end case;
  end function;
begin

  -- Synchronize PS/2 clock and detect falling edge
  process(clk)
  begin
    if rising_edge(clk) then
      ps2_clk_sync <= ps2_clk_sync(1 downto 0) & ps2_clk;
    end if;
  end process;
  ps2_clk_fall <= ps2_clk_sync(2) and not ps2_clk_sync(1);

  -- Shift in 11-bit frame
  process(clk)
  begin
    if rising_edge(clk) then
      scan_valid <= '0';
      if rst = '1' or enable = '0' then
        bit_cnt <= 0;
      elsif ps2_clk_fall = '1' then
        shift_reg <= ps2_data & shift_reg(10 downto 1);
        if bit_cnt = 10 then
          bit_cnt <= 0;
          -- Validate: start=0, stop=1, odd parity
          if shift_reg(0) = '0' and ps2_data = '1' then
            scan_code <= shift_reg(8 downto 1);
            scan_valid <= '1';
          end if;
        else
          bit_cnt <= bit_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- Process scan codes
  process(clk)
    variable ascii : std_logic_vector(7 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' or enable = '0' then
        is_break <= '0';
        buf_pos <= 0;
        disp_buf <= (others => x"20");
      elsif scan_valid = '1' then
        if scan_code = x"F0" then
          is_break <= '1';
        elsif is_break = '1' then
          is_break <= '0';  -- ignore break code
        else
          ascii := scan_to_ascii(scan_code);
          disp_buf(buf_pos) <= ascii;
          if buf_pos = 15 then
            buf_pos <= 0;
          else
            buf_pos <= buf_pos + 1;
          end if;
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
