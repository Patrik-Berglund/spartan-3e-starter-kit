library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
  generic (
    G_DATA_WIDTH : integer   := 32;
    G_CPOL       : std_logic := '0';
    G_CPHA       : std_logic := '0';
    G_CLK_DIV    : integer   := 4  -- sck = clk / (2 * G_CLK_DIV)
  );
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    tx_data  : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    rx_data  : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    start    : in  std_logic;
    busy     : out std_logic;
    done     : out std_logic;
    spi_sck  : out std_logic;
    spi_mosi : out std_logic;
    spi_miso : in  std_logic
  );
end entity spi_master;

architecture rtl of spi_master is
  type state_t is (S_IDLE, S_TRANSFER, S_DONE);
  signal state    : state_t := S_IDLE;
  signal shift_tx : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal shift_rx : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal bit_cnt  : integer range 0 to G_DATA_WIDTH-1 := 0;
  signal clk_cnt  : integer range 0 to G_CLK_DIV-1 := 0;
  signal sck_int  : std_logic := '0';
  signal sck_prev : std_logic := '0';
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state    <= S_IDLE;
        shift_tx <= (others => '0');
        shift_rx <= (others => '0');
        bit_cnt  <= 0;
        clk_cnt  <= 0;
        sck_int  <= G_CPOL;
        sck_prev <= G_CPOL;
      else
        done <= '0';
        sck_prev <= sck_int;

        case state is
          when S_IDLE =>
            sck_int <= G_CPOL;
            if start = '1' then
              shift_tx <= tx_data;
              shift_rx <= (others => '0');
              bit_cnt  <= G_DATA_WIDTH - 1;
              clk_cnt  <= 0;
              sck_int  <= G_CPOL;
              state    <= S_TRANSFER;
              -- CPHA=0: put first bit on MOSI immediately
            end if;

          when S_TRANSFER =>
            if clk_cnt = G_CLK_DIV - 1 then
              clk_cnt <= 0;
              sck_int <= not sck_int;

              -- Sample on appropriate edge
              if (G_CPHA = '0' and sck_int = (not G_CPOL)) or
                 (G_CPHA = '1' and sck_int = G_CPOL) then
                -- This is the sampling edge
                shift_rx <= shift_rx(G_DATA_WIDTH-2 downto 0) & spi_miso;
              end if;

              -- Shift on opposite edge
              if (G_CPHA = '0' and sck_int = G_CPOL) or
                 (G_CPHA = '1' and sck_int = (not G_CPOL)) then
                if bit_cnt = 0 then
                  state <= S_DONE;
                else
                  shift_tx <= shift_tx(G_DATA_WIDTH-2 downto 0) & '0';
                  bit_cnt  <= bit_cnt - 1;
                end if;
              end if;
            else
              clk_cnt <= clk_cnt + 1;
            end if;

          when S_DONE =>
            sck_int <= G_CPOL;
            rx_data <= shift_rx;
            done    <= '1';
            state   <= S_IDLE;
        end case;
      end if;
    end if;
  end process;

  spi_sck  <= sck_int;
  spi_mosi <= shift_tx(G_DATA_WIDTH-1);
  busy     <= '0' when state = S_IDLE else '1';

end architecture rtl;
