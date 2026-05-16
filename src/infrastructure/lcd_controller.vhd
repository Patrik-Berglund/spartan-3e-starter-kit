library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_controller is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    line1  : in  std_logic_vector(127 downto 0);  -- 16 chars, char0 = bits 127:120
    line2  : in  std_logic_vector(127 downto 0);
    update : in  std_logic;
    busy   : out std_logic;
    lcd_e  : out std_logic;
    lcd_rs : out std_logic;
    lcd_rw : out std_logic;
    lcd_db : out std_logic_vector(3 downto 0)
  );
end entity lcd_controller;

architecture rtl of lcd_controller is
  -- Timing constants @ 50 MHz
  constant C_15MS   : integer := 750000;
  constant C_4_1MS  : integer := 205000;
  constant C_100US  : integer := 5000;
  constant C_40US   : integer := 2000;
  constant C_1_64MS : integer := 82000;
  constant C_ENABLE : integer := 12;  -- 240 ns pulse
  constant C_1US    : integer := 50;

  type state_t is (
    S_POWERON, S_INIT0, S_INIT1, S_INIT2, S_INIT3,
    S_FUNC_SET, S_ENTRY_MODE, S_DISP_ON, S_CLEAR,
    S_IDLE, S_WRITE_SETUP, S_WRITE_UPPER, S_WRITE_GAP, S_WRITE_LOWER, S_WRITE_WAIT,
    S_SET_ADDR
  );
  signal state : state_t := S_POWERON;

  signal wait_cnt  : integer range 0 to C_15MS := 0;
  signal char_idx  : integer range 0 to 32 := 0;
  signal cur_byte  : std_logic_vector(7 downto 0) := (others => '0');
  signal is_data   : std_logic := '0';
  signal line_buf  : std_logic_vector(255 downto 0) := (others => '0');
  signal pending   : std_logic := '0';
begin

  lcd_rw <= '0';  -- always write

  process(clk)
    variable byte_v : std_logic_vector(7 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state    <= S_POWERON;
        wait_cnt <= 0;
        char_idx <= 0;
        lcd_e    <= '0';
        lcd_rs   <= '0';
        lcd_db   <= "0000";
        pending  <= '0';
        line_buf <= (others => '0');
      else
        -- Latch update requests
        if update = '1' then
          line_buf <= line1 & line2;
          pending  <= '1';
        end if;

        case state is
          -- Power-on wait 15 ms
          when S_POWERON =>
            lcd_e <= '0';
            if wait_cnt = C_15MS then
              wait_cnt <= 0;
              state <= S_INIT0;
            else
              wait_cnt <= wait_cnt + 1;
            end if;

          -- Init sequence: write 0x3 three times, then 0x2
          when S_INIT0 =>
            lcd_db <= "0011"; lcd_rs <= '0';
            if wait_cnt < C_ENABLE then
              lcd_e <= '1'; wait_cnt <= wait_cnt + 1;
            elsif wait_cnt < C_ENABLE + C_4_1MS then
              lcd_e <= '0'; wait_cnt <= wait_cnt + 1;
            else
              wait_cnt <= 0; state <= S_INIT1;
            end if;

          when S_INIT1 =>
            lcd_db <= "0011"; lcd_rs <= '0';
            if wait_cnt < C_ENABLE then
              lcd_e <= '1'; wait_cnt <= wait_cnt + 1;
            elsif wait_cnt < C_ENABLE + C_100US then
              lcd_e <= '0'; wait_cnt <= wait_cnt + 1;
            else
              wait_cnt <= 0; state <= S_INIT2;
            end if;

          when S_INIT2 =>
            lcd_db <= "0011"; lcd_rs <= '0';
            if wait_cnt < C_ENABLE then
              lcd_e <= '1'; wait_cnt <= wait_cnt + 1;
            elsif wait_cnt < C_ENABLE + C_40US then
              lcd_e <= '0'; wait_cnt <= wait_cnt + 1;
            else
              wait_cnt <= 0; state <= S_INIT3;
            end if;

          when S_INIT3 =>
            lcd_db <= "0010"; lcd_rs <= '0';
            if wait_cnt < C_ENABLE then
              lcd_e <= '1'; wait_cnt <= wait_cnt + 1;
            elsif wait_cnt < C_ENABLE + C_40US then
              lcd_e <= '0'; wait_cnt <= wait_cnt + 1;
            else
              wait_cnt <= 0;
              cur_byte <= x"28"; is_data <= '0'; state <= S_FUNC_SET;
            end if;

          -- Function Set 0x28
          when S_FUNC_SET =>
            if wait_cnt = 0 then
              state <= S_WRITE_SETUP;
            end if;
            -- After write completes, go to entry mode
            -- (handled by char_idx sequencing below)

          -- Entry Mode 0x06
          when S_ENTRY_MODE =>
            cur_byte <= x"06"; is_data <= '0';
            state <= S_WRITE_SETUP;

          -- Display On 0x0C
          when S_DISP_ON =>
            cur_byte <= x"0C"; is_data <= '0';
            state <= S_WRITE_SETUP;

          -- Clear Display
          when S_CLEAR =>
            cur_byte <= x"01"; is_data <= '0';
            state <= S_WRITE_SETUP;

          -- Idle: wait for pending update
          when S_IDLE =>
            lcd_e <= '0';
            if pending = '1' then
              pending  <= '0';
              char_idx <= 0;
              -- Set DD RAM address to 0x00
              cur_byte <= x"80"; is_data <= '0';
              state <= S_SET_ADDR;
            end if;

          when S_SET_ADDR =>
            state <= S_WRITE_SETUP;

          -- Write nibble sequence
          when S_WRITE_SETUP =>
            lcd_rs <= is_data;
            lcd_db <= cur_byte(7 downto 4);
            lcd_e  <= '0';
            wait_cnt <= 0;
            state <= S_WRITE_UPPER;

          when S_WRITE_UPPER =>
            if wait_cnt < C_ENABLE then
              lcd_e <= '1'; wait_cnt <= wait_cnt + 1;
            else
              lcd_e <= '0'; wait_cnt <= 0; state <= S_WRITE_GAP;
            end if;

          when S_WRITE_GAP =>
            if wait_cnt < C_1US then
              wait_cnt <= wait_cnt + 1;
            else
              lcd_db <= cur_byte(3 downto 0);
              wait_cnt <= 0; state <= S_WRITE_LOWER;
            end if;

          when S_WRITE_LOWER =>
            if wait_cnt < C_ENABLE then
              lcd_e <= '1'; wait_cnt <= wait_cnt + 1;
            else
              lcd_e <= '0'; wait_cnt <= 0; state <= S_WRITE_WAIT;
            end if;

          when S_WRITE_WAIT =>
            -- Wait 40 us (or 1.64 ms after clear)
            if cur_byte = x"01" then
              if wait_cnt < C_1_64MS then
                wait_cnt <= wait_cnt + 1;
              else
                wait_cnt <= 0;
                -- After init sequence
                if char_idx = 0 and is_data = '0' then
                  -- Advance through init commands
                  if cur_byte = x"28" then
                    cur_byte <= x"06"; state <= S_WRITE_SETUP;
                  end if;
                else
                  state <= S_IDLE;
                end if;
              end if;
            elsif wait_cnt < C_40US then
              wait_cnt <= wait_cnt + 1;
            else
              wait_cnt <= 0;
              -- Determine next action
              if is_data = '0' and char_idx = 0 then
                -- Init sequence progression
                if cur_byte = x"28" then
                  cur_byte <= x"06"; state <= S_WRITE_SETUP;
                elsif cur_byte = x"06" then
                  cur_byte <= x"0C"; state <= S_WRITE_SETUP;
                elsif cur_byte = x"0C" then
                  cur_byte <= x"01"; state <= S_WRITE_SETUP;
                elsif cur_byte = x"80" or cur_byte = x"C0" then
                  -- Address set done, write chars
                  is_data <= '1';
                  byte_v := line_buf(255 - char_idx*8 downto 248 - char_idx*8);
                  cur_byte <= byte_v;
                  state <= S_WRITE_SETUP;
                else
                  state <= S_IDLE;
                end if;
              elsif is_data = '1' then
                -- Writing characters
                if char_idx = 15 then
                  -- End of line 1, set address to line 2
                  char_idx <= 16;
                  cur_byte <= x"C0"; is_data <= '0';
                  state <= S_WRITE_SETUP;
                elsif char_idx = 31 then
                  -- Done
                  state <= S_IDLE;
                else
                  char_idx <= char_idx + 1;
                  byte_v := line_buf(255 - (char_idx+1)*8 downto 248 - (char_idx+1)*8);
                  cur_byte <= byte_v;
                  state <= S_WRITE_SETUP;
                end if;
              else
                -- After line2 address set
                is_data <= '1';
                byte_v := line_buf(255 - char_idx*8 downto 248 - char_idx*8);
                cur_byte <= byte_v;
                state <= S_WRITE_SETUP;
              end if;
            end if;

        end case;
      end if;
    end if;
  end process;

  busy <= '0' when state = S_IDLE else '1';

end architecture rtl;
