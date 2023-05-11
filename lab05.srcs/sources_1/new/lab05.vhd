library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.ALL;

entity lab05 is
    port(
        clk : in std_logic;
        hsync, vsync : out std_logic;
        red, green, blue : out std_logic_vector(3 downto 0);
        BTNU, BTND, BTNR, BTNL : IN STD_LOGIC;
        ssd : out STD_LOGIC_VECTOR(6 downto 0);
        sel : buffer STD_LOGIC
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
    signal data_in : STD_LOGIC_VECTOR(7 downto 0);
    --create component of ssd
    component ssd_ctrl is
        port(
            clk: in STD_LOGIC;
            data_in:in STD_LOGIC_VECTOR (7 downto 0);
            sel: buffer STD_LOGIC := '0';
            ssd: out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
    -- create component of clock driver
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
    signal collided_1 : boolean := false; 
    signal collided_2 : boolean := false; 
    signal score_1 : integer := 0;
    signal score_2 : integer := 0;
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
    type rand is array (0 to 249) of integer;
    signal random  : rand;
    signal ran_count : integer := 0;


begin
    -- Port map the ssd_ctrl
    name : ssd_ctrl port map (clk, data_in, sel, ssd);
    u_clk1hz : clock_divider generic map(N => 50000000) port map(clk, clk_1Hz);
    u_clk10hz : clock_divider generic map(N => 5000000) port map(clk, clk_10Hz);
    u_clk60hz : clock_divider generic map(N => 833333) port map(clk, clk_60Hz);
    u_clk50mhz : clock_divider generic map(N => 1) port map(clk, clk_50MHz);
    
    --assign random number to array
    random(0) <= 236; random(1) <= 347; random(2) <= 586; random(3) <= 140; random(4) <= 546; random(5) <= 369; random(6) <= 24; random(7) <= 208; random(8) <= 405; random(9) <= 506; random(10) <= 177; random(11) <= 492; random(12) <= 64; random(13) <= 247; random(14) <= 50; random(15) <= 513; random(16) <= 427; random(17) <= 149; random(18) <= 254; random(19) <= 348; random(20) <= 242; random(21) <= 465; random(22) <= 470; random(23) <= 386; random(24) <= 24; random(25) <= 28; random(26) <= 544; random(27) <= 102; random(28) <= 580; random(29) <= 207; random(30) <= 272; random(31) <= 103; random(32) <= 231; random(33) <= 400; random(34) <= 68; random(35) <= 126; random(36) <= 30; random(37) <= 300; random(38) <= 150; random(39) <= 78; random(40) <= 421; random(41) <= 93; random(42) <= 129; random(43) <= 535; random(44) <= 303; random(45) <= 516; random(46) <= 416; random(47) <= 525; random(48) <= 129; random(49) <= 491; random(50) <= 417; random(51) <= 471; random(52) <= 171; random(53) <= 186; random(54) <= 146; random(55) <= 227; random(56) <= 443; random(57) <= 316; random(58) <= 471; random(59) <= 32; random(60) <= 476; random(61) <= 131; random(62) <= 211; random(63) <= 353; random(64) <= 467; random(65) <= 160; random(66) <= 89; random(67) <= 534; random(68) <= 262; random(69) <= 28; random(70) <= 403; random(71) <= 144; random(72) <= 250; random(73) <= 286; random(74) <= 556; random(75) <= 426; random(76) <= 487; random(77) <= 212; random(78) <= 123; random(79) <= 148; random(80) <= 148; random(81) <= 191; random(82) <= 235; random(83) <= 321; random(84) <= 327; random(85) <= 48; random(86) <= 153; random(87) <= 465; random(88) <= 307; random(89) <= 261; random(90) <= 244; random(91) <= 144; random(92) <= 556; random(93) <= 94; random(94) <= 229; random(95) <= 414; random(96) <= 555; random(97) <= 357; random(98) <= 320; random(99) <= 307; random(100) <= 328; random(101) <= 287; random(102) <= 435; random(103) <= 361; random(104) <= 433; random(105) <= 422; random(106) <= 326; random(107) <= 323; random(108) <= 427; random(109) <= 157; random(110) <= 265; random(111) <= 493; random(112) <= 528; random(113) <= 42; random(114) <= 576; random(115) <= 550; random(116) <= 163; random(117) <= 400; random(118) <= 404; random(119) <= 597; random(120) <= 54; random(121) <= 587; random(122) <= 507; random(123) <= 37; random(124) <= 182; random(125) <= 84; random(126) <= 140; random(127) <= 572; random(128) <= 464; random(129) <= 67; random(130) <= 523; random(131) <= 339; random(132) <= 85; random(133) <= 421; random(134) <= 446; random(135) <= 98; random(136) <= 55; random(137) <= 375; random(138) <= 440; random(139) <= 535; random(140) <= 375; random(141) <= 165; random(142) <= 301; random(143) <= 406; random(144) <= 308; random(145) <= 501; random(146) <= 336; random(147) <= 153; random(148) <= 227; random(149) <= 280; random(150) <= 78; random(151) <= 553; random(152) <= 25; random(153) <= 515; random(154) <= 508; random(155) <= 199; random(156) <= 480; random(157) <= 334; random(158) <= 562; random(159) <= 285; random(160) <= 230; random(161) <= 575; random(162) <= 236; random(163) <= 195; random(164) <= 407; random(165) <= 595; random(166) <= 330; random(167) <= 269; random(168) <= 82; random(169) <= 182; random(170) <= 399; random(171) <= 522; random(172) <= 398; random(173) <= 121; random(174) <= 324; random(175) <= 563; random(176) <= 308; random(177) <= 525; random(178) <= 572; random(179) <= 214; random(180) <= 21; random(181) <= 484; random(182) <= 111; random(183) <= 553; random(184) <= 91; random(185) <= 323; random(186) <= 367; random(187) <= 537; random(188) <= 183; random(189) <= 338; random(190) <= 122; random(191) <= 465; random(192) <= 218; random(193) <= 191; random(194) <= 401; random(195) <= 105; random(196) <= 293; random(197) <= 473; random(198) <= 184; random(199) <= 299; random(200) <= 290; random(201) <= 573; random(202) <= 82; random(203) <= 430; random(204) <= 43; random(205) <= 530; random(206) <= 544; random(207) <= 87; random(208) <= 394; random(209) <= 231; random(210) <= 240; random(211) <= 484; random(212) <= 186; random(213) <= 504; random(214) <= 298; random(215) <= 486; random(216) <= 214; random(217) <= 320; random(218) <= 424; random(219) <= 249; random(220) <= 217; random(221) <= 463; random(222) <= 210; random(223) <= 492; random(224) <= 426; random(225) <= 91; random(226) <= 49; random(227) <= 500; random(228) <= 401; random(229) <= 84; random(230) <= 443; random(231) <= 32; random(232) <= 472; random(233) <= 482; random(234) <= 100; random(235) <= 265; random(236) <= 202; random(237) <= 377; random(238) <= 351; random(239) <= 433; random(240) <= 424; random(241) <= 238; random(242) <= 459; random(243) <= 532; random(244) <= 123;random(245) <= 312; random(246) <= 99; random(247) <= 322; random(248) <= 115; random(249) <= 529; 

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
            for i in 0 to num_obstacles-1 loop
                if asteroids(i).dir = Left then
                    if (asteroids(i).x <= x1+X_SIZE) and (asteroids(i).x >= x1) and (asteroids(i).y >= y1) and (asteroids(i).y <= y1+ Y_SIZE) then
                        collided_1 <= true;
                    end if;
                    if (asteroids(i).x <= x2+X_SIZE) and (asteroids(i).x >= x2) and (asteroids(i).y >= y2) and (asteroids(i).y <= y2+ Y_SIZE) then
                        collided_2 <= true;
                    end if;
                end if;
            end loop;
            if collided_1 = true then
                y1 <= V_END - Y_SIZE;
                collided_1 <=false;
            else
                if (BTNU = '1') then
                    if ( y1 <= V_START) then
                        y1 <= V_END - Y_SIZE;
                        score_1 <= 
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
            end if;
            if collided_2 = true then
                y2 <= V_END - Y_SIZE;
                collided_2 <= false;
            else
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
        end if;
    end process;
    

    -- process (asteroids, x1, y1, x2, y2)
    -- begin
        
    -- end process;

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
                        asteroids(i).y <= random(ran_count) ;
                        if ran_count>249 then
                            ran_count <=0;
                        end if;
                        ran_count <= ran_count + 1;
                        if (asteroids(i).y mod 2) = 0 then
                            asteroids(i).dir <= Right;
                            asteroids(i).x <= H_START;
                        elsif (asteroids(i).y mod 2) = 1 then
                            asteroids(i).dir <= Left;
                            asteroids(i).x <= H_END - 50;
                        else
                            asteroids(i).dir <= Left;
                            asteroids(i).x <= H_END - 50;
                        end if;
                        asteroids(i).is_activated <= true;
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
    
    --set new y-position for asteroids
    -- process (asteroids)
    -- begin
    --     for i in 0 to num_obstacles-1 loop
    --         if asteroids(i).is_activated = false then
    --             asteroids(i).y <= random(ran_count) ;
    --             ran_count <= ran_count + 1;
    --             asteroids(i).is_activated <= true;
    --             if (asteroids(i).y mod 2) = 0 then
    --                 asteroids(i).dir <= Right;
    --                 asteroids(i).x <= H_START;
    --             elsif (asteroids(i).y mod 2) = 1 then
    --                 asteroids(i).dir <= Left;
    --                 asteroids(i).x <= H_END - 50;
    --             else
    --                 asteroids(i).dir <= Left;
    --                 asteroids(i).x <= H_END - 50;
    --             end if;
    --         end if;
    --     end loop;
    -- end process;

    process (hcount, vcount, x1, y1, x2, y2, asteroids)
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
