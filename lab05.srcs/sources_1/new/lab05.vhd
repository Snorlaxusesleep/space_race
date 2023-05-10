library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.ALL;

entity lab05 is
    port(
        clk : in std_logic;
        hsync, vsync : out std_logic;
        red, green, blue : out std_logic_vector(3 downto 0);
        BTNU, BTND, BTNR, BTNL : IN STD_LOGIC
    );        
end lab05;

architecture Behavioral of lab05 is
    
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
    constant NumObstacles : integer := 5;
    signal hcount, vcount : integer;
    
    component clock_divider is
        generic (N : integer);
        port( clk : in std_logic;
        clk_out : out std_logic );
    end component;
    signal clk_1Hz, clk_10Hz, clk_50MHz, clk_60Hz : std_logic;
    
    constant X_STEP : integer := 5;
    constant Y_STEP : integer := 5;
    constant X_SIZE : integer := 40;
    constant Y_SIZE : integer := 40;
    signal x1 : integer := H_START + 256;
    signal y1 : integer := V_END - Y_SIZE;
    signal x2 : integer := H_START + 768;
    signal y2 : integer := V_END - Y_SIZE;
    signal dx : integer := X_STEP; -- obstacle x speed
    signal dy : integer := Y_STEP; -- player y speed
    type asteroid_type is record
        x : integer range H_START to H_END;
        y : integer range V_START to V_END;
    end record;
    type asteroid_array is array (0 to NumObstacles-1) of asteroid_type;
    
    type colors is (C_Black, C_Green, C_Blue, C_Red, C_White, C_Yellow);

    signal color : colors := C_White;
    signal  color_count : integer := 0;
    
    
begin

    u_clk1hz : clock_divider generic map(N => 50000000) port map(clk, clk_1Hz);
    u_clk10hz : clock_divider generic map(N => 5000000) port map(clk, clk_10Hz);
    u_clk60hz : clock_divider generic map(N => 833333) port map(clk, clk_60Hz);
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
    
    process (clk_60Hz)
    begin
        if (rising_edge(clk_60Hz)) then
            if (BTNU = '1') then
                if ( y1 <= V_START) then
                    y1 <= V_END - Y_SIZE;
                else
                    y1 <= y1 - dy;
                end if;
            elsif (BTND = '1') then
                if ( y1 + Y_SIZE >= V_END) then
                    y1 <= V_END - Y_SIZE;
                else
                    y1 <= y1 + dy;
                end if;
            end if;
            if (BTNR = '1') then
                if ( y2 <= V_START) then
                    y2 <= V_END - Y_SIZE;
                else
                    y2 <= y2 - dy;
                end if;
            elsif (BTNL = '1') then
                if ( y2 + Y_SIZE >= V_END) then
                    y2 <= V_END - Y_SIZE;
                else
                    y2 <= y2 + dy;
                end if;
            end if;
        end if;
    end process;
    
    process (hcount, vcount, x1, y1)
    begin
        if ((hcount >= H_START and hcount < H_END) and (vcount >= V_START and vcount < V_TOTAL)) then
            if (x1 <= hcount and hcount < x1 + X_SIZE and y1 < vcount and vcount < y1 + Y_SIZE) then
                color <= C_White;
            elsif (x2 <= hcount and hcount < x2 + X_SIZE and y2 < vcount and vcount < y2 + Y_SIZE) then
                color <= C_White;
            else -- need to add asternoids color
                color <= C_Black;
            end if;
            
            if (hcount>= 
        else
            color <= C_Black;
        end if;
        
    end process;
    
    process (color)
    begin
        case(color) is
            when C_Black =>
                red <= "0000"; green <= "0000";
                blue <= "0000";
            when C_Green =>
                red <= "0000"; green <= "1111";
                blue <= "0000";
            when C_Blue =>
                red <= "0000"; green <= "0000";
                blue <= "1111";
            when C_Red =>
                red <= "1111"; green <= "0000";
                blue <= "0000";
            when C_White =>
                red <= "1111"; green <= "1111";
                blue <= "1111";
            when C_Yellow =>
                red <= "1111"; green <= "1111";
                blue <= "0000";
            when others =>
                red <= "0000"; green <= "0000";
                blue <= "0000";
        end case;
    end process;
end Behavioral;
