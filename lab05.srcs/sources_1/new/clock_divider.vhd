library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider is
    generic (N : integer);
    port(
        clk : in std_logic;
        clk_out : out std_logic
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal count : integer := 0;
    signal pulse : STD_LOGIC := '0';

begin
    process(clk)
    begin
        if rising_edge (clk) then
            if (count = (N - 1)) then
                pulse <= not    pulse;
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    clk_out <= pulse;

end Behavioral;
