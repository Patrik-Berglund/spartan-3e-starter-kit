library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    port (
        clk : in  std_logic;
        led : out std_logic_vector(7 downto 0)
    );
end top;

architecture rtl of top is
    signal counter : unsigned(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    -- 50 MHz clock: bits 25..22 give visible blinking patterns
    led <= std_logic_vector(counter(25 downto 18));
end rtl;
