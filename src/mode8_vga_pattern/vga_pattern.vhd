library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_pattern is
  port (
    clk       : in  std_logic;  -- 50 MHz
    rst       : in  std_logic;
    enable    : in  std_logic;
    rot_event : in  std_logic;
    rot_dir   : in  std_logic;
    vga_red   : out std_logic;
    vga_green : out std_logic;
    vga_blue  : out std_logic;
    vga_hsync : out std_logic;
    vga_vsync : out std_logic;
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity vga_pattern;

architecture rtl of vga_pattern is
  -- 25 MHz pixel clock from 50 MHz (toggle)
  signal pix_clk_en : std_logic := '0';

  -- Timing counters
  signal h_cnt : unsigned(9 downto 0) := (others => '0');
  signal v_cnt : unsigned(9 downto 0) := (others => '0');

  -- 640x480@60Hz timing
  constant H_DISP  : integer := 640;
  constant H_FP    : integer := 16;
  constant H_PW    : integer := 96;
  constant H_BP    : integer := 48;
  constant H_TOTAL : integer := 800;
  constant V_DISP  : integer := 480;
  constant V_FP    : integer := 10;
  constant V_PW    : integer := 2;
  constant V_BP    : integer := 29;
  constant V_TOTAL : integer := 521;

  signal video_on : std_logic := '0';
  signal pattern  : unsigned(1 downto 0) := "00";

  signal r, g, b : std_logic := '0';

  function char_to_slv(c : character) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(character'pos(c), 8));
  end function;

  type name_t is array (0 to 3) of string(1 to 10);
  constant PAT_NAMES : name_t := ("Color Bars", "Checkerbrd", "Red Screen", "Gradient  ");
begin

  -- Pattern select
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pattern <= "00";
      elsif enable = '1' and rot_event = '1' then
        if rot_dir = '1' then
          pattern <= pattern + 1;
        else
          pattern <= pattern - 1;
        end if;
      end if;
    end if;
  end process;

  -- Pixel clock enable (25 MHz)
  process(clk)
  begin
    if rising_edge(clk) then
      pix_clk_en <= not pix_clk_en;
    end if;
  end process;

  -- Horizontal counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        h_cnt <= (others => '0');
        v_cnt <= (others => '0');
      elsif pix_clk_en = '1' then
        if h_cnt = H_TOTAL - 1 then
          h_cnt <= (others => '0');
          if v_cnt = V_TOTAL - 1 then
            v_cnt <= (others => '0');
          else
            v_cnt <= v_cnt + 1;
          end if;
        else
          h_cnt <= h_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- Sync signals (active low)
  vga_hsync <= '0' when h_cnt >= H_DISP + H_FP and h_cnt < H_DISP + H_FP + H_PW else '1';
  vga_vsync <= '0' when v_cnt >= V_DISP + V_FP and v_cnt < V_DISP + V_FP + V_PW else '1';
  video_on  <= '1' when h_cnt < H_DISP and v_cnt < V_DISP else '0';

  -- Pattern generation
  process(h_cnt, v_cnt, pattern, video_on)
    variable col : unsigned(2 downto 0);
  begin
    r <= '0'; g <= '0'; b <= '0';
    if video_on = '1' then
      case pattern is
        when "00" =>  -- 8 color bars
          col := h_cnt(9 downto 7);
          r <= col(2); g <= col(1); b <= col(0);
        when "01" =>  -- Checkerboard
          r <= h_cnt(4) xor v_cnt(4);
          g <= h_cnt(4) xor v_cnt(4);
          b <= h_cnt(4) xor v_cnt(4);
        when "10" =>  -- Solid red
          r <= '1'; g <= '0'; b <= '0';
        when others =>  -- Horizontal gradient (white bars)
          r <= h_cnt(3); g <= h_cnt(3); b <= h_cnt(3);
      end case;
    end if;
  end process;

  vga_red   <= r when enable = '1' else '0';
  vga_green <= g when enable = '1' else '0';
  vga_blue  <= b when enable = '1' else '0';

  -- LCD line 2
  lcd_line2 <=
    char_to_slv(PAT_NAMES(to_integer(pattern))(1)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(2)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(3)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(4)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(5)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(6)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(7)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(8)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(9)) &
    char_to_slv(PAT_NAMES(to_integer(pattern))(10)) &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ') &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ');

end architecture rtl;
