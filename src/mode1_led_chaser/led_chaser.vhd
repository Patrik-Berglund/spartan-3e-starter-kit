library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_chaser is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    sw        : in  std_logic_vector(3 downto 0);
    rot_event : in  std_logic;
    rot_dir   : in  std_logic;
    led       : out std_logic_vector(7 downto 0);
    lcd_line2 : out std_logic_vector(127 downto 0)
  );
end entity led_chaser;

architecture rtl of led_chaser is
  signal prescale  : unsigned(24 downto 0) := (others => '0');
  signal speed     : unsigned(3 downto 0) := "0100";
  signal pattern   : std_logic_vector(7 downto 0) := "00000001";
  signal tick      : std_logic := '0';
  signal direction : std_logic := '1';  -- 1=left, 0=right

  function char_to_slv(c : character) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(character'pos(c), 8));
  end function;
begin

  -- Speed control via rotary
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        speed <= "0100";
      elsif enable = '1' and rot_event = '1' then
        if rot_dir = '1' and speed < 15 then
          speed <= speed + 1;
        elsif rot_dir = '0' and speed > 0 then
          speed <= speed - 1;
        end if;
      end if;
    end if;
  end process;

  -- Prescaler: free-running counter, speed selects threshold
  process(clk)
    variable threshold : unsigned(24 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' or enable = '0' then
        prescale <= (others => '0');
        tick <= '0';
      else
        tick <= '0';
        prescale <= prescale + 1;
        -- Speed 0 = slowest (~1.5 Hz), speed 8+ = fastest (~380 Hz)
        threshold := (others => '0');
        case speed is
          when "0000" => threshold := to_unsigned(25000000, 25); -- 1 Hz
          when "0001" => threshold := to_unsigned(12500000, 25);
          when "0010" => threshold := to_unsigned(6250000, 25);
          when "0011" => threshold := to_unsigned(3125000, 25);
          when "0100" => threshold := to_unsigned(1562500, 25);
          when "0101" => threshold := to_unsigned(781250, 25);
          when "0110" => threshold := to_unsigned(390625, 25);
          when "0111" => threshold := to_unsigned(195312, 25);
          when others => threshold := to_unsigned(97656, 25);
        end case;
        if prescale >= threshold then
          prescale <= (others => '0');
          tick <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Pattern shift
  process(clk)
    variable sw_prev : std_logic_vector(3 downto 1) := "000";
  begin
    if rising_edge(clk) then
      if rst = '1' or enable = '0' then
        pattern <= "00000001";
        direction <= '1';
        sw_prev := "000";
      else
        -- Reset pattern when switches change
        if sw(3 downto 1) /= sw_prev then
          pattern <= "00000001";
          direction <= '1';
          sw_prev := sw(3 downto 1);
        elsif tick = '1' then
          case sw(3 downto 1) is
            when "000" =>  -- single LED bounce
              if direction = '1' then
                pattern <= pattern(6 downto 0) & '0';
                if pattern(6) = '1' then
                  direction <= '0';
                end if;
              else
                pattern <= '0' & pattern(7 downto 1);
                if pattern(1) = '1' then
                  direction <= '1';
                end if;
              end if;
            when "001" =>  -- all LEDs blink alternating
              pattern <= not pattern;
            when "010" =>  -- rotate left
              pattern <= pattern(6 downto 0) & pattern(7);
            when "011" =>  -- rotate right
              pattern <= pattern(0) & pattern(7 downto 1);
            when "100" =>  -- fill left
              pattern <= pattern(6 downto 0) & '1';
            when others =>  -- blink all
              pattern <= not pattern;
          end case;
        end if;
      end if;
    end if;
  end process;

  led <= pattern when enable = '1' else (others => '0');

  -- LCD line 2: "Spd:X  Pat:X    "
  process(speed, sw)
    variable s_val, p_val : unsigned(7 downto 0);
  begin
    s_val := to_unsigned(48 + to_integer(speed), 8);
    if speed > 9 then
      s_val := to_unsigned(55 + to_integer(speed), 8);  -- A-F
    end if;
    p_val := to_unsigned(48 + to_integer(unsigned(sw(3 downto 1))), 8);
    lcd_line2 <=
      char_to_slv('S') & char_to_slv('p') & char_to_slv('d') & char_to_slv(':') &
      std_logic_vector(s_val) & char_to_slv(' ') &
      char_to_slv(' ') & char_to_slv('P') & char_to_slv('a') & char_to_slv('t') & char_to_slv(':') &
      std_logic_vector(p_val) &
      char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ');
  end process;

end architecture rtl;
