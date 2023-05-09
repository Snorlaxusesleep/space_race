library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.ALL;

entity lab05 is
    port(
        clk : in std_logic;
        hsync, vsync : out std_logic;
        red, green, blue : out std_logic_vector(3 downto 0);
        BTNU, BTND : IN STD_LOGIC
    );        
end lab05;

architecture Behavioral of lab05 is
    
    constant H_TOTAL : integer := 1344 - 1;
    constant H_SYNC : integer := 48 - 1;
    constant H_BACK : integer := 240 - 1;
    constant H_START: integer := 48 + 240 - 1;
    constant H_ACTIVE: integer := 1024 - 1;
    constant H_END: integer := 1344 - 32 - 1;
    constant H_FRONT : integer := 32 - 1;
    constant V_TOTAL : integer := 625 - 1;
    constant V_SYNC : integer := 3 - 1;
    constant V_BACK : integer := 12 - 1;
    constant V_START: integer := 3 + 12 - 1;
    constant V_ACTIVE : integer := 600 - 1;
    constant V_END : integer := 625 - 10 - 1;
    constant V_FRONT : integer := 10 - 1;
    signal hcount, vcount : integer;
    
    component clock_divider is
        generic (N : integer);
        port( clk : in std_logic;
        clk_out : out std_logic );
    end component;
    signal clk_1Hz, clk_10Hz, clk_50MHz : std_logic;
    
    constant X_STEP : integer := 40;
    constant Y_STEP : integer := 40;
    constant X_SIZE : integer := 80;
    constant Y_SIZE : integer := 120;
    signal x : integer := H_START;
    signal y : integer := V_END + Y_SIZE;
    signal dx : integer := X_STEP;
    signal dy : integer := Y_STEP;
    -- signal direction : integer := 0;
    type colors is (C_Black, C_Green, C_Blue, C_Red, C_White, C_Yellow);
    type T_1D is array(0 to 4) of colors;
    constant fig : T_1D := (C_Green, C_Blue, C_Red, C_White, C_Yellow);
    signal color : colors := C_White;
    signal  color_count : integer := 0;
    
    
begin
    
    u_clk50mhz : clock_divider generic map(N => 1) port map(clk, clk_50MHz);
    
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
    
    u_clk1hz : clock_divider generic map(N => 50000000) port map(clk, clk_1Hz);
    u_clk10hz : clock_divider generic map(N => 5000000) port map(clk, clk_10Hz);
    
    process (clk_10Hz)
    begin
        if (rising_edge(clk_10Hz)) then
            if (BTNU = '1') then
                if ( y <= V_START) then
                    y <= V_END - Y_SIZE;
                else
                    y <= y - dy;
                    color_count <= color_count + 1;
                end if;
            elsif (BTND = '1') then
                if ( y + Y_SIZE >= V_END) then
                    y <= V_END - Y_SIZE;
                else
                    y <= y + dy;
                    color_count <= color_count + 1;
                end if;
            end if;
            
        end if;
    end process;
    
    process (hcount, vcount, x, y)
    begin
        if ((hcount >= H_START and hcount < H_END) and (vcount >= V_START and vcount < V_TOTAL)) then
            if (x <= hcount and hcount < x + X_SIZE and y < vcount and vcount < y + Y_SIZE) then
                color <= fig(color_count mod 5);
            else
                color <= C_Black;
            end if;
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
