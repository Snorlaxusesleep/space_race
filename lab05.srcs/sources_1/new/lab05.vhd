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
    constant asteroid_size : integer := 5;
    constant num_obstacles : integer := 5;
    signal hcount, vcount : integer;
    
    component clock_divider is
        generic (N : integer);
        port( clk : in std_logic;
        clk_out : out std_logic );
    end component;
    signal clk_1Hz, clk_10Hz, clk_50MHz, clk_60Hz : std_logic;
    
    constant X_STEP : integer := 3;
    constant Y_STEP : integer := 3;
    constant X_SIZE : integer := 40;
    constant Y_SIZE : integer := 40;
    signal x1 : integer := H_START + 256;
    signal y1 : integer := V_END - Y_SIZE;
    signal x2 : integer := H_START + 768;
    signal y2 : integer := V_END - Y_SIZE;
    signal dx : integer := X_STEP; -- obstacle x speed
    signal dy : integer := Y_STEP; -- player y speed
    type direction is (Right, Left);
    type asteroid_type is record
        x : integer range H_START to H_END;
        y : integer range V_START to V_END;
        dir : direction;
        is_activated : boolean;
    end record;
    type asteroid_array is array (natural range <>) of asteroid_type;
    signal asteroids : asteroid_array(0 to num_obstacles-1) := (
    (x => H_START+1, y => V_START+60, dir => Right, is_activated => true),
    (x => H_START+800, y => V_START+120, dir => Left, is_activated => true),
    (x => H_START+120, y => V_START+180, dir => Right, is_activated => true),
    (x => H_START+600, y => V_START+240, dir => Left, is_activated => true),
    (x => H_START+240, y => V_START+300, dir => Right, is_activated => true)
    );
    
    type colors is (C_Black, C_Green, C_Blue, C_Red, C_White, C_Yellow);
    signal color : colors := C_White;
    signal color_count : integer := 0;
    signal i : integer := 0;
    

begin

    u_clk1hz : clock_divider generic map(N => 50000000) port map(clk, clk_1Hz);
    u_clk10hz : clock_divider generic map(N => 5000000) port map(clk, clk_10Hz);
    u_clk60hz : clock_divider generic map(N => 833333) port map(clk, clk_60Hz);
    u_clk50mhz : clock_divider generic map(N => 1) port map(clk, clk_50MHz);
    
    -- asteroids declaration. process executed once only.
--    process
--    begin
--        for i in 0 to num_obstacles-1 loop
--            asteroids(i) <= (x => H_START+(101*i), y => V_START+(101*i), dir => Right);
--        end loop;
--    end process;
    
    
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
    
    -- movement of player 1 and player 2
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
    
    -- movement of asternoids
    process (clk_60Hz)
    begin
        if (rising_edge(clk_60Hz)) then
            for i in 0 to num_obstacles-1 loop
                if asteroids(i).is_activated = true then
                    if asteroids(i).dir = Right then
                        asteroids(i).x <= asteroids(i).x + dx;
                    elsif asteroids(i).dir = Left then
                        asteroids(i).x <= asteroids(i).x - dx;
                    else
                        asteroids(i).x <= asteroids(i).x - dx;
                    end if;
                    if (asteroids(i).x + asteroid_size >= H_END or asteroids(i).x <= H_START) then
                        asteroids(i).is_activated <= false;
                        --asteroids(i).y <= random();
                        --direction and x according to y value
                        --if (asteroids(i).y mod 2) = 0 then
                        --    asteroids(i).dir <= Right;
                        --    asteroids(i).x <= H_START;
                        --elsif (asteroids(i).y mod 2) = 1 then
                        --    asteroids(i).dir <= Left;
                        --    asteroids(i).x <= H_END - 50;
                        --else
                        --    asteroids(i).dir <= Left;
                        --   asteroids(i).x <= H_END - 50;
                        --end if;
                        --asteroids(i).is_activated <= true;
                    end if;
                end if;
            end loop;
        end if;
    end process;
    
    process (hcount, vcount, x1, y1)
    begin
        if ((hcount >= H_START and hcount < H_END) and (vcount >= V_START and vcount < V_TOTAL)) then
            if (x1 <= hcount and hcount < x1 + X_SIZE and y1 < vcount and vcount < y1 + Y_SIZE) then
                color <= C_White;
            elsif (x2 <= hcount and hcount < x2 + X_SIZE and y2 < vcount and vcount < y2 + Y_SIZE) then
                color <= C_White;
            else
                color <= C_Black;
            end if;
            
            -- asteroids visualization
            for i in 0 to num_obstacles-1 loop
                if (asteroids(i).x <= hcount and hcount < asteroids(i).x + asteroid_size and asteroids(i).y < vcount and vcount < asteroids(i).y + asteroid_size) then
                    color <= C_White;
                end if;
            end loop;
            -- a center line
            if (hcount >= 795 and hcount < 805) then
                color <= C_White;
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
