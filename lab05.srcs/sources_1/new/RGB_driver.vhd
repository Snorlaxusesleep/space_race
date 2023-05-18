library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RGB_driver is
    port(
        clk : in std_logic;
        hsync, vsync : out std_logic;
        v_count, h_count : buffer integer
    );        
end RGB_driver;

architecture Behavioral of RGB_Driver is
    constant H_TOTAL : integer := 1344 - 1;     --h max
    constant H_SYNC : integer := 48 - 1;        --start of h sync
    constant H_BACK : integer := 240 - 1;       --end of h sync
    constant H_START: integer := 48 + 240 - 1;  --addressable horizontal video start
    constant H_ACTIVE: integer := 1024 - 1;     --width
    constant H_END: integer := 1344 - 32 - 1;   --addressable horizontal video end
    constant H_FRONT : integer := 32 - 1;       --no use
    constant V_TOTAL : integer := 625 - 1;      --v max
    constant V_SYNC : integer := 3 - 1;         --start of v sync
    constant V_BACK : integer := 12 - 1;        --end of h sync
    constant V_START: integer := 3 + 12 - 1;    --addressable vertical video start
    constant V_ACTIVE : integer := 600 - 1;     --height
    constant V_END : integer := 625 - 10 - 1;   --addressable vertical video end
    constant V_FRONT : integer := 10 - 1;       --no use
    signal hcount, vcount : integer;
    signal clk_50MHz : std_logic;
    
    component clock_divider is
        generic (N : integer);
        port( clk : in std_logic;
        clk_out : out std_logic );
    end component;
   
begin

   u_clk50mhz : clock_divider generic map(N => 1) port map(clk, clk_50MHz);
   -- increase h count (move pixel by pixel hozitontally)
   pixel_count_proc : process (clk_50MHz)
    begin
        if (rising_edge(clk_50MHz)) then
            if (hcount = H_TOTAL) then
                hcount <= 0;
            else
                hcount <= hcount + 1;
            end if;
        end if;
    end process pixel_count_proc;
    
    hsync_gen_proc : process (hcount)
    begin
        if (hcount <= H_SYNC) then
            hsync <= '1';
        else
            hsync <= '0';
        end if;
    end process hsync_gen_proc;
    
    -- increase v count (move pixel by pixel vertically)
    line_count_proc : process (clk_50MHz)
    begin
        if (rising_edge(clk_50MHz)) then
            if (hcount = H_TOTAL) then
                if (vcount = V_TOTAL) then
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
                end if;
            end if;
        end if;
    end process line_count_proc;
    
    vsync_gen_proc : process (vcount)
    begin
        if (vcount <= V_SYNC) then
            vsync <= '1';
        else
            vsync <= '0';
        end if;
    end process vsync_gen_proc;
    
    h_count <= hcount;
    v_count <= vcount;
    
end Behavioral;