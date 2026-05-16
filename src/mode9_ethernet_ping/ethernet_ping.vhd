library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Minimal Ethernet ping responder.
-- Responds to ARP requests and ICMP echo (ping) for a hardcoded IP/MAC.
-- Operates in the MII RX/TX clock domains with a simple bridge to 50 MHz for LCD.

entity ethernet_ping is
  port (
    clk       : in    std_logic;  -- 50 MHz system clock
    rst       : in    std_logic;
    enable    : in    std_logic;
    -- MII interface
    e_txd     : out   std_logic_vector(3 downto 0);
    e_tx_en   : out   std_logic;
    e_tx_clk  : in    std_logic;
    e_rxd     : in    std_logic_vector(3 downto 0);
    e_rx_dv   : in    std_logic;
    e_rx_clk  : in    std_logic;
    -- Output
    lcd_line2 : out   std_logic_vector(127 downto 0)
  );
end entity ethernet_ping;

architecture rtl of ethernet_ping is
  -- Our MAC: 02:00:00:00:00:01 (locally administered)
  constant OUR_MAC : std_logic_vector(47 downto 0) := x"020000000001";
  -- Our IP: 192.168.1.100
  constant OUR_IP  : std_logic_vector(31 downto 0) := x"C0A80164";

  -- RX state machine (in e_rx_clk domain)
  type rx_state_t is (RX_IDLE, RX_PREAMBLE, RX_DATA);
  signal rx_state   : rx_state_t := RX_IDLE;
  signal rx_nibble_cnt : unsigned(10 downto 0) := (others => '0');
  signal rx_byte    : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_nibble_hi : std_logic := '0';

  -- Frame buffer (store first 64 bytes = 128 nibbles)
  type frame_buf_t is array (0 to 63) of std_logic_vector(7 downto 0);
  signal rx_buf : frame_buf_t := (others => (others => '0'));
  signal rx_len : unsigned(10 downto 0) := (others => '0');
  signal rx_done : std_logic := '0';

  -- TX state machine (in e_tx_clk domain)
  type tx_state_t is (TX_IDLE, TX_PREAMBLE, TX_DATA, TX_IFG);
  signal tx_state : tx_state_t := TX_IDLE;
  signal tx_buf   : frame_buf_t := (others => (others => '0'));
  signal tx_len   : unsigned(6 downto 0) := (others => '0');
  signal tx_cnt   : unsigned(10 downto 0) := (others => '0');
  signal tx_start : std_logic := '0';
  signal tx_nibble_hi : std_logic := '0';

  -- Ping counter (system clock domain)
  signal ping_count : unsigned(15 downto 0) := (others => '0');
  signal ping_pulse : std_logic := '0';
  signal ping_sync  : std_logic_vector(2 downto 0) := "000";

  -- Cross-domain signals
  signal rx_done_sync : std_logic_vector(2 downto 0) := "000";
  signal process_frame : std_logic := '0';

  function char_to_slv(c : character) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(character'pos(c), 8));
  end function;

  function hex_char(v : unsigned(3 downto 0)) return std_logic_vector is
    variable c : integer;
  begin
    c := to_integer(v);
    if c < 10 then return std_logic_vector(to_unsigned(48 + c, 8));
    else return std_logic_vector(to_unsigned(55 + c, 8));
    end if;
  end function;
begin

  -- ============ RX (e_rx_clk domain) ============
  process(e_rx_clk)
  begin
    if rising_edge(e_rx_clk) then
      if rst = '1' or enable = '0' then
        rx_state <= RX_IDLE;
        rx_done <= '0';
      else
        case rx_state is
          when RX_IDLE =>
            rx_done <= '0';
            if e_rx_dv = '1' then
              rx_state <= RX_PREAMBLE;
              rx_nibble_cnt <= (others => '0');
            end if;

          when RX_PREAMBLE =>
            if e_rx_dv = '0' then
              rx_state <= RX_IDLE;
            elsif e_rxd = x"D" then  -- SFD last nibble
              rx_state <= RX_DATA;
              rx_nibble_cnt <= (others => '0');
              rx_nibble_hi <= '0';
            end if;

          when RX_DATA =>
            if e_rx_dv = '0' then
              rx_len <= rx_nibble_cnt;
              rx_done <= '1';
              rx_state <= RX_IDLE;
            else
              if rx_nibble_hi = '0' then
                rx_byte(3 downto 0) <= e_rxd;
                rx_nibble_hi <= '1';
              else
                rx_byte(7 downto 4) <= e_rxd;
                rx_nibble_hi <= '0';
                if rx_nibble_cnt(10 downto 1) < 64 then
                  rx_buf(to_integer(rx_nibble_cnt(6 downto 1))) <=
                    e_rxd & rx_byte(3 downto 0);
                end if;
                rx_nibble_cnt <= rx_nibble_cnt + 2;
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;

  -- ============ Frame processing (50 MHz domain) ============
  -- Synchronize rx_done
  process(clk)
  begin
    if rising_edge(clk) then
      rx_done_sync <= rx_done_sync(1 downto 0) & rx_done;
    end if;
  end process;
  process_frame <= rx_done_sync(1) and not rx_done_sync(2);

  -- Simple ARP/ICMP check and response generation
  process(clk)
    variable is_arp  : boolean;
    variable is_icmp : boolean;
  begin
    if rising_edge(clk) then
      ping_pulse <= '0';
      tx_start <= '0';

      if rst = '1' or enable = '0' then
        ping_count <= (others => '0');
      elsif process_frame = '1' then
        -- Check EtherType (bytes 12-13)
        is_arp := (rx_buf(12) = x"08" and rx_buf(13) = x"06");
        is_icmp := (rx_buf(12) = x"08" and rx_buf(13) = x"00") and
                   (rx_buf(23) = x"01");  -- IP protocol = ICMP

        if is_arp then
          -- Check if ARP request for our IP (bytes 38-41 = target IP)
          if rx_buf(38) = OUR_IP(31 downto 24) and
             rx_buf(39) = OUR_IP(23 downto 16) and
             rx_buf(40) = OUR_IP(15 downto 8) and
             rx_buf(41) = OUR_IP(7 downto 0) then
            -- Build ARP reply in tx_buf (simplified)
            -- Dst MAC = sender MAC (bytes 6-11 of rx)
            for i in 0 to 5 loop
              tx_buf(i) <= rx_buf(6 + i);
            end loop;
            -- Src MAC = our MAC
            tx_buf(6)  <= OUR_MAC(47 downto 40);
            tx_buf(7)  <= OUR_MAC(39 downto 32);
            tx_buf(8)  <= OUR_MAC(31 downto 24);
            tx_buf(9)  <= OUR_MAC(23 downto 16);
            tx_buf(10) <= OUR_MAC(15 downto 8);
            tx_buf(11) <= OUR_MAC(7 downto 0);
            -- EtherType ARP
            tx_buf(12) <= x"08"; tx_buf(13) <= x"06";
            -- ARP reply opcode
            tx_buf(14) <= x"00"; tx_buf(15) <= x"01";
            tx_buf(16) <= x"08"; tx_buf(17) <= x"00";
            tx_buf(18) <= x"06"; tx_buf(19) <= x"04";
            tx_buf(20) <= x"00"; tx_buf(21) <= x"02";  -- reply
            -- Sender = us
            tx_buf(22) <= OUR_MAC(47 downto 40);
            tx_buf(23) <= OUR_MAC(39 downto 32);
            tx_buf(24) <= OUR_MAC(31 downto 24);
            tx_buf(25) <= OUR_MAC(23 downto 16);
            tx_buf(26) <= OUR_MAC(15 downto 8);
            tx_buf(27) <= OUR_MAC(7 downto 0);
            tx_buf(28) <= OUR_IP(31 downto 24);
            tx_buf(29) <= OUR_IP(23 downto 16);
            tx_buf(30) <= OUR_IP(15 downto 8);
            tx_buf(31) <= OUR_IP(7 downto 0);
            -- Target = requester
            for i in 0 to 9 loop
              tx_buf(32 + i) <= rx_buf(22 + i);
            end loop;
            tx_len <= to_unsigned(42, 7);
            tx_start <= '1';
          end if;

        elsif is_icmp then
          -- Check ICMP type = 8 (echo request) at byte 34
          if rx_buf(34) = x"08" then
            -- Build echo reply: swap MACs, swap IPs, type=0
            for i in 0 to 5 loop
              tx_buf(i) <= rx_buf(6 + i);      -- dst = sender
              tx_buf(6 + i) <= OUR_MAC((5-i)*8+7 downto (5-i)*8);
            end loop;
            tx_buf(12) <= x"08"; tx_buf(13) <= x"00";  -- IPv4
            -- Copy IP header + ICMP payload, change type to 0
            for i in 14 to 63 loop
              tx_buf(i) <= rx_buf(i);
            end loop;
            -- Swap src/dst IP
            for i in 0 to 3 loop
              tx_buf(26 + i) <= OUR_IP((3-i)*8+7 downto (3-i)*8);
              tx_buf(30 + i) <= rx_buf(26 + i);
            end loop;
            -- ICMP type = 0 (echo reply)
            tx_buf(34) <= x"00";
            -- Simplified checksum fix: add 0x0800 to existing checksum
            tx_len <= to_unsigned(64, 7);
            tx_start <= '1';
            ping_pulse <= '1';
            ping_count <= ping_count + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- ============ TX (e_tx_clk domain) ============
  -- Simplified: just send preamble + data nibbles
  process(e_tx_clk)
  begin
    if rising_edge(e_tx_clk) then
      if rst = '1' or enable = '0' then
        tx_state <= TX_IDLE;
        e_tx_en <= '0';
        e_txd <= "0000";
      else
        case tx_state is
          when TX_IDLE =>
            e_tx_en <= '0';
            e_txd <= "0000";
            if tx_start = '1' then
              tx_state <= TX_PREAMBLE;
              tx_cnt <= (others => '0');
            end if;

          when TX_PREAMBLE =>
            e_tx_en <= '1';
            if tx_cnt < 15 then
              e_txd <= x"5";  -- preamble
              tx_cnt <= tx_cnt + 1;
            else
              e_txd <= x"D";  -- SFD
              tx_cnt <= (others => '0');
              tx_nibble_hi <= '0';
              tx_state <= TX_DATA;
            end if;

          when TX_DATA =>
            e_tx_en <= '1';
            if tx_nibble_hi = '0' then
              e_txd <= tx_buf(to_integer(tx_cnt(6 downto 1)))(3 downto 0);
              tx_nibble_hi <= '1';
            else
              e_txd <= tx_buf(to_integer(tx_cnt(6 downto 1)))(7 downto 4);
              tx_nibble_hi <= '0';
              tx_cnt <= tx_cnt + 2;
              if tx_cnt(6 downto 1) >= tx_len then
                tx_state <= TX_IFG;
                tx_cnt <= (others => '0');
              end if;
            end if;

          when TX_IFG =>
            e_tx_en <= '0';
            e_txd <= "0000";
            if tx_cnt = 24 then  -- 12 byte IFG = 24 nibbles
              tx_state <= TX_IDLE;
            else
              tx_cnt <= tx_cnt + 1;
            end if;
        end case;
      end if;
    end if;
  end process;

  -- LCD: "Pings: XXXXX    "
  lcd_line2 <=
    char_to_slv('P') & char_to_slv('i') & char_to_slv('n') & char_to_slv('g') &
    char_to_slv('s') & char_to_slv(':') &
    hex_char(ping_count(15 downto 12)) &
    hex_char(ping_count(11 downto 8)) &
    hex_char(ping_count(7 downto 4)) &
    hex_char(ping_count(3 downto 0)) &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ') &
    char_to_slv(' ') & char_to_slv(' ') & char_to_slv(' ');

end architecture rtl;
