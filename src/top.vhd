library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    clk_50mhz    : in    std_logic;
    sw           : in    std_logic_vector(3 downto 0);
    btn_south    : in    std_logic;
    btn_north    : in    std_logic;
    btn_east     : in    std_logic;
    btn_west     : in    std_logic;
    rot_a        : in    std_logic;
    rot_b        : in    std_logic;
    rot_center   : in    std_logic;
    led          : out   std_logic_vector(7 downto 0);
    lcd_e        : out   std_logic;
    lcd_rs       : out   std_logic;
    lcd_rw       : out   std_logic;
    sf_d         : out   std_logic_vector(11 downto 8);
    sf_ce0       : out   std_logic;
    sf_oe        : out   std_logic;
    spi_mosi     : out   std_logic;
    spi_miso     : in    std_logic;
    spi_sck      : out   std_logic;
    spi_ss_b     : out   std_logic;  -- active-low, directly to Flash via J11
    spi_alt_cs   : out   std_logic;  -- alternate CS path via J11
    fpga_init_b  : out   std_logic;
    dac_cs       : out   std_logic;
    dac_clr      : out   std_logic;
    amp_cs       : out   std_logic;
    ad_conv      : out   std_logic;
    rs232_dce_rxd: in    std_logic;
    rs232_dce_txd: out   std_logic;
    ps2_clk      : in    std_logic;
    ps2_data     : in    std_logic;
    vga_red      : out   std_logic;
    vga_green    : out   std_logic;
    vga_blue     : out   std_logic;
    vga_hsync    : out   std_logic;
    vga_vsync    : out   std_logic;
    sd_a         : out   std_logic_vector(12 downto 0);
    sd_ba        : out   std_logic_vector(1 downto 0);
    sd_dq        : inout std_logic_vector(15 downto 0);
    sd_ras       : out   std_logic;
    sd_cas       : out   std_logic;
    sd_we        : out   std_logic;
    sd_ck_p      : out   std_logic;
    sd_ck_n      : out   std_logic;
    sd_cke       : out   std_logic;
    sd_cs        : out   std_logic;
    sd_ldm       : out   std_logic;
    sd_udm       : out   std_logic;
    sd_ldqs      : inout std_logic;
    sd_udqs      : inout std_logic;
    e_txd        : out   std_logic_vector(3 downto 0);
    e_tx_en      : out   std_logic;
    e_tx_clk     : in    std_logic;
    e_rxd        : in    std_logic_vector(3 downto 0);
    e_rx_dv      : in    std_logic;
    e_rx_clk     : in    std_logic
  );
end entity top;

architecture rtl of top is
  signal rst : std_logic;

  -- Rotary decoder outputs
  signal rot_event : std_logic;
  signal rot_dir   : std_logic;
  signal rot_press : std_logic;

  -- Mode mux
  signal active_mode : integer range 0 to 8;
  signal mode_name   : std_logic_vector(127 downto 0);

  -- LCD
  signal lcd_line1   : std_logic_vector(127 downto 0);
  signal lcd_line2   : std_logic_vector(127 downto 0);
  signal lcd_update  : std_logic := '0';
  signal lcd_busy    : std_logic;
  signal lcd_db      : std_logic_vector(3 downto 0);

  -- Per-mode LCD line2 outputs
  signal lcd2_mode1  : std_logic_vector(127 downto 0);
  signal lcd2_mode2  : std_logic_vector(127 downto 0);
  signal lcd2_mode3  : std_logic_vector(127 downto 0);
  signal lcd2_mode4  : std_logic_vector(127 downto 0);
  signal lcd2_mode5  : std_logic_vector(127 downto 0);
  signal lcd2_mode6  : std_logic_vector(127 downto 0);
  signal lcd2_mode7  : std_logic_vector(127 downto 0);
  signal lcd2_mode8  : std_logic_vector(127 downto 0);
  signal lcd2_mode9  : std_logic_vector(127 downto 0);

  -- Per-mode LED outputs
  signal led_mode1   : std_logic_vector(7 downto 0);
  signal led_mode3   : std_logic_vector(7 downto 0);
  signal led_mode7   : std_logic_vector(7 downto 0);

  -- Shared SPI bus
  signal spi_tx_mux   : std_logic_vector(31 downto 0);
  signal spi_rx_i     : std_logic_vector(31 downto 0);
  signal spi_bits_mux : unsigned(5 downto 0);
  signal spi_start_mux: std_logic;
  signal spi_busy_i   : std_logic;
  signal spi_done_i   : std_logic;
  signal spi_sck_i    : std_logic;
  signal spi_mosi_i   : std_logic;
  signal cs_sel_mux   : unsigned(2 downto 0);

  -- Per-mode SPI signals
  signal spi_tx_m2    : std_logic_vector(31 downto 0);
  signal spi_bits_m2  : unsigned(5 downto 0);
  signal spi_start_m2 : std_logic;
  signal cs_sel_m2    : unsigned(2 downto 0);

  signal spi_tx_m3    : std_logic_vector(31 downto 0);
  signal spi_bits_m3  : unsigned(5 downto 0);
  signal spi_start_m3 : std_logic;
  signal cs_sel_m3    : unsigned(2 downto 0);

  signal spi_tx_m6    : std_logic_vector(31 downto 0);
  signal spi_bits_m6  : unsigned(5 downto 0);
  signal spi_start_m6 : std_logic;
  signal cs_sel_m6    : unsigned(2 downto 0);
  -- LCD refresh timer
  signal lcd_timer    : unsigned(21 downto 0) := (others => '0');

  -- Enable signals
  signal en : std_logic_vector(8 downto 0);
  signal btn_deb : std_logic_vector(2 downto 0);
begin

  rst <= btn_south;
  sf_ce0 <= '1';  -- disable StrataFlash, free LCD bus
  sf_oe  <= '1';  -- disable StrataFlash output (shares SPI_MISO)
  fpga_init_b <= '1';  -- disable Platform Flash on SPI_MISO
  dac_clr <= '1'; -- DAC not in reset
  sf_d <= lcd_db;

  -- Generate enable signals
  gen_en: for i in 0 to 8 generate
    en(i) <= '1' when active_mode = i else '0';
  end generate;

  -- ==================== Infrastructure ====================

  -- Debounce buttons
  u_deb_btn: entity work.debounce
    generic map (G_WIDTH => 3, G_COUNT_MAX => 500000)
    port map (
      clk => clk_50mhz, rst => rst,
      input(0) => btn_north, input(1) => btn_east, input(2) => btn_west,
      output => btn_deb
    );

  u_rotary: entity work.rotary_decoder
    port map (
      clk => clk_50mhz, rst => rst,
      rot_a => rot_a, rot_b => rot_b, rot_center => rot_center,
      rot_event => rot_event, rot_dir => rot_dir, rot_press => rot_press
    );

  u_mode_mux: entity work.mode_mux
    port map (
      clk => clk_50mhz, rst => rst,
      sw => sw,
      active_mode => active_mode,
      mode_name => mode_name
    );

  u_lcd: entity work.lcd_controller
    port map (
      clk => clk_50mhz, rst => rst,
      line1 => lcd_line1, line2 => lcd_line2,
      update => lcd_update, busy => lcd_busy,
      lcd_e => lcd_e, lcd_rs => lcd_rs, lcd_rw => lcd_rw, lcd_db => lcd_db
    );

  -- SPI bus mux: active mode owns the bus
  spi_tx_mux    <= spi_tx_m2 when en(1) = '1' else
                   spi_tx_m3 when en(2) = '1' else
                   spi_tx_m6 when en(5) = '1' else (others => '0');
  spi_bits_mux  <= spi_bits_m2 when en(1) = '1' else
                   spi_bits_m3 when en(2) = '1' else
                   spi_bits_m6 when en(5) = '1' else "000000";
  spi_start_mux <= spi_start_m2 when en(1) = '1' else
                   spi_start_m3 when en(2) = '1' else
                   spi_start_m6 when en(5) = '1' else '0';
  cs_sel_mux    <= cs_sel_m2 when en(1) = '1' else
                   cs_sel_m3 when en(2) = '1' else
                   cs_sel_m6 when en(5) = '1' else "000";

  u_spi: entity work.spi_master
    generic map (G_CLK_DIV => 8)
    port map (
      clk => clk_50mhz, rst => rst,
      tx_data => spi_tx_mux, rx_data => spi_rx_i,
      num_bits => spi_bits_mux,
      start => spi_start_mux,
      busy => spi_busy_i, done => spi_done_i,
      spi_sck => spi_sck_i, spi_mosi => spi_mosi_i, spi_miso => spi_miso
    );

  -- SPI pin drivers
  spi_sck  <= spi_sck_i;
  spi_mosi <= spi_mosi_i;

  -- CS decoding from cs_sel_mux: 0=none, 1=DAC, 2=AMP, 3=Flash, 4=ADC
  dac_cs     <= '0' when cs_sel_mux = "001" else '1';
  amp_cs     <= '0' when cs_sel_mux = "010" else '1';
  spi_ss_b   <= '0' when cs_sel_mux = "011" else '1';
  spi_alt_cs <= '0' when cs_sel_mux = "011" else '1';
  ad_conv    <= '1' when cs_sel_mux = "100" else '0';

  -- ==================== Mode Instances ====================

  u_mode1: entity work.led_chaser
    port map (
      clk => clk_50mhz, rst => rst, enable => en(0),
      rot_event => rot_event, rot_dir => rot_dir, rot_press => rot_press,
      btn_north => btn_deb(0), btn_east => btn_deb(1), btn_west => btn_deb(2),
      led => led_mode1, lcd_line2 => lcd2_mode1
    );

  u_mode2: entity work.dac_waveform
    port map (
      clk => clk_50mhz, rst => rst, enable => en(1),
      rot_event => rot_event, rot_dir => rot_dir,
      spi_start => spi_start_m2, spi_tx => spi_tx_m2,
      spi_bits => spi_bits_m2, spi_busy => spi_busy_i,
      cs_sel => cs_sel_m2, lcd_line2 => lcd2_mode2
    );

  u_mode3: entity work.adc_voltmeter
    port map (
      clk => clk_50mhz, rst => rst, enable => en(2),
      spi_tx => spi_tx_m3, spi_rx => spi_rx_i,
      spi_bits => spi_bits_m3, spi_start => spi_start_m3,
      spi_done => spi_done_i, spi_busy => spi_busy_i,
      cs_sel => cs_sel_m3,
      led => led_mode3, lcd_line2 => lcd2_mode3
    );

  u_mode4: entity work.uart_echo
    port map (
      clk => clk_50mhz, rst => rst, enable => en(3),
      rxd => rs232_dce_rxd, txd => rs232_dce_txd,
      lcd_line2 => lcd2_mode4
    );

  u_mode5: entity work.ps2_keyboard
    port map (
      clk => clk_50mhz, rst => rst, enable => en(4),
      ps2_clk => ps2_clk, ps2_data => ps2_data,
      lcd_line2 => lcd2_mode5
    );

  u_mode6: entity work.spi_flash_id
    port map (
      clk => clk_50mhz, rst => rst, enable => en(5),
      spi_tx => spi_tx_m6, spi_rx => spi_rx_i,
      spi_bits => spi_bits_m6, spi_start => spi_start_m6,
      spi_done => spi_done_i, spi_busy => spi_busy_i,
      cs_sel => cs_sel_m6, lcd_line2 => lcd2_mode6
    );

  u_mode7: entity work.ddr_memtest
    port map (
      clk => clk_50mhz, rst => rst, enable => en(6),
      sd_a => sd_a, sd_ba => sd_ba, sd_dq => sd_dq,
      sd_ras => sd_ras, sd_cas => sd_cas, sd_we => sd_we,
      sd_cs => sd_cs, sd_cke => sd_cke, sd_ldm => sd_ldm, sd_udm => sd_udm,
      lcd_line2 => lcd2_mode7, led => led_mode7
    );

  u_mode8: entity work.vga_pattern
    port map (
      clk => clk_50mhz, rst => rst, enable => en(7),
      rot_event => rot_event, rot_dir => rot_dir,
      vga_red => vga_red, vga_green => vga_green, vga_blue => vga_blue,
      vga_hsync => vga_hsync, vga_vsync => vga_vsync,
      lcd_line2 => lcd2_mode8
    );

  u_mode9: entity work.ethernet_ping
    port map (
      clk => clk_50mhz, rst => rst, enable => en(8),
      e_txd => e_txd, e_tx_en => e_tx_en, e_tx_clk => e_tx_clk,
      e_rxd => e_rxd, e_rx_dv => e_rx_dv, e_rx_clk => e_rx_clk,
      lcd_line2 => lcd2_mode9
    );

  -- ==================== Output Muxing ====================

  -- LCD line 1 = mode name
  lcd_line1 <= mode_name;

  -- LCD line 2 = active mode's status
  with active_mode select lcd_line2 <=
    lcd2_mode1 when 0,
    lcd2_mode2 when 1,
    lcd2_mode3 when 2,
    lcd2_mode4 when 3,
    lcd2_mode5 when 4,
    lcd2_mode6 when 5,
    lcd2_mode7 when 6,
    lcd2_mode8 when 7,
    lcd2_mode9 when others;

  -- LEDs
  with active_mode select led <=
    led_mode1 when 0,
    led_mode3 when 2,
    led_mode7 when 6,
    x"00"     when others;

  -- DDR clock (idle when not in mode 7)
  sd_ck_p <= '0';
  sd_ck_n <= '1';

  -- LCD refresh (~30 Hz)
  process(clk_50mhz)
  begin
    if rising_edge(clk_50mhz) then
      lcd_update <= '0';
      if rst = '1' then
        lcd_timer <= (others => '0');
      else
        lcd_timer <= lcd_timer + 1;
        if lcd_timer = 0 and lcd_busy = '0' then
          lcd_update <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture rtl;
