library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ssd_ctrl is
    Port (
    -- TODO-1: Create the input/output ports
        clk: in STD_LOGIC;
        data_in1:in integer;
        data_in2:in integer;
        sel: buffer STD_LOGIC := '0';
        ssd: out STD_LOGIC_VECTOR (6 downto 0)
);
end ssd_ctrl;

architecture Behavioral of ssd_ctrl is
    -- TODO-4: Create the component of clk_div
    component clock_divider is
        generic (N : integer);
        port( clk : in std_logic ;
        clk_out : out std_logic );
    end component;
    
    -- Add any signal if necessary
    signal digit: integer;
    
begin
    -- TODO-2: Fill in the blank
    process(digit) begin
        case digit is
            when 0 => ssd <= "1111110";    -- 0x0
            when 1 => ssd <= "0110000";    -- 0x1
            when 2 => ssd <= "1101101";    -- 0x2
            when 3 => ssd <= "1111001";    -- 0x3
            when 4 => ssd <= "0110011";    -- 0x4
            when 5 => ssd <= "1011011";    -- 0x5
            when 6 => ssd <= "1011111";    -- 0x6
            when 7 => ssd <= "1110000";    -- 0x7
            when 8 => ssd <= "1111111";    -- 0x8
            when 9 => ssd <= "1111011";    -- 0x9
            when 10 => ssd <= "1110111";    -- 0xA
            when 11 => ssd <= "0011111";    -- 0xb (lowercase)
            when 12 => ssd <= "1001110";    -- 0xC
            when 13 => ssd <= "0111101";    -- 0xd (lowercase)
            when 14 => ssd <= "1001111";    -- 0xE
            when 15 => ssd <= "1000111";    -- 0xF
            when others => ssd <= "0000000";
        end case;
    end process;

    -- TODO-5 : Port map the clk_div component (100MHz --> 100Hz)
    u_clk100hz : clock_divider generic map(N => 500000) port map(clk, sel);
    -- TODO-6: Time-multiplexing (Create as many process as you want, OR use both sequential and combinational statement)

    process(sel)
    begin
        if (sel = '0') then
            digit <= data_in2;
        elsif (sel = '1') then
            digit <= data_in1;
        end if;
    end process;        
        
    
end Behavioral;