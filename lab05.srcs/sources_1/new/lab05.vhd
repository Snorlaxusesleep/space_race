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
        sel : buffer STD_LOGIC;
        
        reset         : IN     STD_LOGIC;                     --active low reset
        miso            : IN     STD_LOGIC;                     --SPI master in, slave out
        mosi            : OUT    STD_LOGIC;                     --SPI master out, slave in
        sclk            : BUFFER STD_LOGIC;                     --SPI clock
        cs            : OUT    STD_LOGIC                     --pmod chip select
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
    constant num_obstacles : integer := 40;
    signal hcount, vcount : integer;
    signal data_in1 : integer;
    signal data_in2 : integer;
    --create component of ssd
    component ssd_ctrl is
        port(
            clk: in STD_LOGIC;
            data_in1:in integer;
            data_in2:in integer;
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
    
    component pmod_joystick is
        GENERIC(
            clk_freq        : INTEGER); --system clock frequency in MHz
          PORT(
            clk             : IN     STD_LOGIC;                     --system clock
            reset_n         : IN     STD_LOGIC;                     --active low reset
            miso            : IN     STD_LOGIC;                     --SPI master in, slave out
            mosi            : OUT    STD_LOGIC;                     --SPI master out, slave in
            sclk            : BUFFER STD_LOGIC;                     --SPI clock
            cs_n            : OUT    STD_LOGIC;                     --pmod chip select
            x_position      : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0);  --joystick x-axis position
            y_position      : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0);  --joystick y-axis position
            trigger_button  : OUT    STD_LOGIC;                     --trigger button status
            center_button   : OUT    STD_LOGIC);                    --center button status
        end component;
    
    signal clk_1Hz, clk_10Hz, clk_50MHz, clk_60Hz : std_logic;
    
    constant X_STEP : integer := 3;
    constant Y_STEP : integer := 4;
    constant X_SIZE : integer := 40;
    constant Y_SIZE : integer := 40;
    signal x1 : integer := H_START + 341 - X_SIZE;
    signal y1 : integer := V_END - Y_SIZE;
    signal x2 : integer := H_START + 683;
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
        (x => H_START+50, y => V_START+Y_SIZE+305, dir => Right, is_activated => true),
        (x => H_START+100, y => V_START+Y_SIZE+14, dir => Right, is_activated => true),
        (x => H_START+150, y => V_START+Y_SIZE+252, dir => Right, is_activated => true),
        (x => H_START+200, y => V_START+Y_SIZE+341, dir => Right, is_activated => true),
        (x => H_START+250, y => V_START+Y_SIZE+378, dir => Right, is_activated => true),
        (x => H_START+300, y => V_START+Y_SIZE+109, dir => Right, is_activated => true),
        (x => H_START+350, y => V_START+Y_SIZE+437, dir => Right, is_activated => true),
        (x => H_START+400, y => V_START+Y_SIZE+297, dir => Right, is_activated => true),
        (x => H_START+450, y => V_START+Y_SIZE+461, dir => Right, is_activated => true),
        (x => H_START+500, y => V_START+Y_SIZE+348, dir => Right, is_activated => true),
        (x => H_START+550, y => V_START+Y_SIZE+309, dir => Right, is_activated => true),
        (x => H_START+600, y => V_START+Y_SIZE+389, dir => Right, is_activated => true),
        (x => H_START+650, y => V_START+Y_SIZE+268, dir => Right, is_activated => true),
        (x => H_START+700, y => V_START+Y_SIZE+17, dir => Right, is_activated => true),
        (x => H_START+750, y => V_START+Y_SIZE+217, dir => Right, is_activated => true),
        (x => H_START+800, y => V_START+Y_SIZE+132, dir => Right, is_activated => true),
        (x => H_START+850, y => V_START+Y_SIZE+24, dir => Right, is_activated => true),
        (x => H_START+900, y => V_START+Y_SIZE+247, dir => Right, is_activated => true),
        (x => H_START+950, y => V_START+Y_SIZE+185, dir => Right, is_activated => true),
        (x => H_START+999, y => V_START+Y_SIZE+100, dir => Right, is_activated => true),
        (x => H_START+25, y => V_START+Y_SIZE+125, dir => Left, is_activated => true),
        (x => H_START+75, y => V_START+Y_SIZE+490, dir => Left, is_activated => true),
        (x => H_START+125, y => V_START+Y_SIZE+108, dir => Left, is_activated => true),
        (x => H_START+175, y => V_START+Y_SIZE+334, dir => Left, is_activated => true),
        (x => H_START+225, y => V_START+Y_SIZE+320, dir => Left, is_activated => true),
        (x => H_START+275, y => V_START+Y_SIZE+89, dir => Left, is_activated => true),
        (x => H_START+325, y => V_START+Y_SIZE+408, dir => Left, is_activated => true),
        (x => H_START+375, y => V_START+Y_SIZE+432, dir => Left, is_activated => true),
        (x => H_START+425, y => V_START+Y_SIZE+118, dir => Left, is_activated => true),
        (x => H_START+475, y => V_START+Y_SIZE+351, dir => Left, is_activated => true),
        (x => H_START+525, y => V_START+Y_SIZE+499, dir => Left, is_activated => true),
        (x => H_START+575, y => V_START+Y_SIZE+70, dir => Left, is_activated => true),
        (x => H_START+625, y => V_START+Y_SIZE+507, dir => Left, is_activated => true),
        (x => H_START+675, y => V_START+Y_SIZE+482, dir => Left, is_activated => true),
        (x => H_START+725, y => V_START+Y_SIZE+87, dir => Left, is_activated => true),
        (x => H_START+775, y => V_START+Y_SIZE+152, dir => Left, is_activated => true),
        (x => H_START+825, y => V_START+Y_SIZE+1, dir => Left, is_activated => true),
        (x => H_START+875, y => V_START+Y_SIZE+142, dir => Left, is_activated => true),
        (x => H_START+925, y => V_START+Y_SIZE+203, dir => Left, is_activated => true),
        (x => H_START+975, y => V_START+Y_SIZE+442, dir => Left, is_activated => true)
    );

    type colors is (C_Black, C_Green, C_Blue, C_Red, C_White, C_Yellow);
    signal color : colors := C_White;
    type T_2D is array (0 to 39, 0 to 29) of colors;
    constant bird : T_2D := (
    
    
    );
    signal i : integer := 0;
    type rand is array (0 to 600) of integer;   
    signal random : rand;    
    
    signal x_position      :     STD_LOGIC_VECTOR(7 DOWNTO 0);  --joystick x-axis position
    signal y_position      :     STD_LOGIC_VECTOR(7 DOWNTO 0);  --joystick y-axis position
    signal trigger_button  :     STD_LOGIC;                     --trigger button status
    signal center_button   :     STD_LOGIC;                    --center button status

begin
    -- Port map the ssd_ctrl
    ssd_ctrler : ssd_ctrl port map (clk, data_in1, data_in2, sel, ssd);
    jstk_ctrler : pmod_joystick generic map(clk_freq => 100) port map(clk, reset, miso, mosi, sclk, cs, x_position, y_position, trigger_button, center_button);
    u_clk1hz : clock_divider generic map(N => 50000000) port map(clk, clk_1Hz);
    u_clk10hz : clock_divider generic map(N => 5000000) port map(clk, clk_10Hz);
    u_clk60hz : clock_divider generic map(N => 833333) port map(clk, clk_60Hz);
    u_clk50mhz : clock_divider generic map(N => 1) port map(clk, clk_50MHz);
    
    -- randomly assigned 520 values in array
    random(483) <= 12;	random(12) <= 443;	random(443) <= 396;	random(396) <= 34;	random(34) <= 163;	random(163) <= 64;	random(64) <= 430;	random(430) <= 433;	random(433) <= 378;	random(378) <= 413;	random(413) <= 254;	random(254) <= 28;	random(28) <= 515;	random(515) <= 182;	random(182) <= 383;	random(383) <= 379;	random(379) <= 180;	random(180) <= 57;	random(57) <= 252;	random(252) <= 276;	random(276) <= 176;	random(176) <= 498;	random(498) <= 37;	random(37) <= 518;	random(518) <= 54;	random(54) <= 117;	random(117) <= 297;	random(297) <= 402;	random(402) <= 50;	random(50) <= 332;	random(332) <= 217;	random(217) <= 268;	random(268) <= 26;	random(26) <= 316;	random(316) <= 230;	random(230) <= 501;	random(501) <= 159;	random(159) <= 173;	random(173) <= 85;	random(85) <= 512;	random(512) <= 18;	random(18) <= 39;	random(39) <= 417;	random(417) <= 213;	random(213) <= 292;	random(292) <= 71;	random(71) <= 459;	random(459) <= 221;	random(221) <= 216;	random(216) <= 188;	random(188) <= 273;	random(273) <= 243;	random(243) <= 101;	random(101) <= 440;	random(440) <= 170;	random(170) <= 455;	random(455) <= 387;	random(387) <= 298;	random(298) <= 445;	random(445) <= 326;	random(326) <= 98;	random(98) <= 133;	random(133) <= 345;	random(345) <= 469;	random(469) <= 339;	random(339) <= 108;	random(108) <= 9;	random(9) <= 429;	random(429) <= 200;	random(200) <= 2;	random(2) <= 22;	random(22) <= 407;	random(407) <= 207;	random(207) <= 360;	random(360) <= 4;	random(4) <= 61;	random(61) <= 65;	random(65) <= 0;	random(0) <= 203;	random(203) <= 305;	random(305) <= 472;	random(472) <= 271;	random(271) <= 231;	random(231) <= 342;	random(342) <= 507;	random(507) <= 161;	random(161) <= 25;	random(25) <= 490;	random(490) <= 209;	random(209) <= 442;	random(442) <= 491;	random(491) <= 399;	random(399) <= 148;	random(148) <= 278;	random(278) <= 494;	random(494) <= 428;	random(428) <= 257;	random(257) <= 401;	random(401) <= 335;	random(335) <= 259;	random(259) <= 481;	random(481) <= 91;	random(91) <= 167;	random(167) <= 267;	random(267) <= 46;	random(46) <= 457;	random(457) <= 168;	random(168) <= 194;	random(194) <= 409;	random(409) <= 296;	random(296) <= 16;	random(16) <= 391;	random(391) <= 224;	random(224) <= 201;	random(201) <= 78;	random(78) <= 110;	random(110) <= 149;	random(149) <= 143;	random(143) <= 140;	random(140) <= 380;	random(380) <= 141;	random(141) <= 420;	random(420) <= 385;	random(385) <= 70;	random(70) <= 281;	random(281) <= 234;	random(234) <= 381;	random(381) <= 280;	random(280) <= 63;	random(63) <= 204;	random(204) <= 218;	random(218) <= 181;	random(181) <= 13;	random(13) <= 58;	random(58) <= 47;	random(47) <= 504;	random(504) <= 214;	random(214) <= 14;	random(14) <= 260;	random(260) <= 147;	random(147) <= 336;	random(336) <= 416;	random(416) <= 237;	random(237) <= 100;	random(100) <= 382;	random(382) <= 341;	random(341) <= 125;	random(125) <= 458;	random(458) <= 174;	random(174) <= 435;	random(435) <= 38;	random(38) <= 3;	random(3) <= 189;	random(189) <= 185;	random(185) <= 446;	random(446) <= 139;	random(139) <= 208;	random(208) <= 67;	random(67) <= 233;	random(233) <= 462;	random(462) <= 338;	random(338) <= 282;	random(282) <= 317;	random(317) <= 79;	random(79) <= 471;	random(471) <= 279;	random(279) <= 232;	random(232) <= 235;	random(235) <= 437;	random(437) <= 68;	random(68) <= 136;	random(136) <= 31;	random(31) <= 20;	random(20) <= 275;	random(275) <= 196;	random(196) <= 104;	random(104) <= 408;	random(408) <= 33;	random(33) <= 77;	random(77) <= 165;	random(165) <= 403;	random(403) <= 211;	random(211) <= 368;	random(368) <= 333;	random(333) <= 516;	random(516) <= 371;	random(371) <= 309;	random(309) <= 192;	random(192) <= 432;	random(432) <= 187;	random(187) <= 414;	random(414) <= 157;	random(157) <= 482;	random(482) <= 359;	random(359) <= 253;	random(253) <= 510;	random(510) <= 60;	random(60) <= 127;	random(127) <= 358;	random(358) <= 424;	random(424) <= 398;	random(398) <= 500;	random(500) <= 367;	random(367) <= 397;	random(397) <= 210;	random(210) <= 198;	random(198) <= 43;	random(43) <= 264;	random(264) <= 80;	random(80) <= 473;	random(473) <= 265;	random(265) <= 315;	random(315) <= 310;	random(310) <= 242;	random(242) <= 52;	random(52) <= 517;	random(517) <= 179;	random(179) <= 438;	random(438) <= 375;	random(375) <= 286;	random(286) <= 404;	random(404) <= 166;	random(166) <= 250;	random(250) <= 24;	random(24) <= 422;	random(422) <= 418;	random(418) <= 32;	random(32) <= 434;	random(434) <= 226;	random(226) <= 244;	random(244) <= 228;	random(228) <= 206;	random(206) <= 274;	random(274) <= 119;	random(119) <= 15;	random(15) <= 449;	random(449) <= 356;	random(356) <= 508;	random(508) <= 6;	random(6) <= 366;	random(366) <= 111;	random(111) <= 262;	random(262) <= 447;	random(447) <= 94;	random(94) <= 162;	random(162) <= 372;	random(372) <= 400;	random(400) <= 505;	random(505) <= 277;	random(277) <= 502;	random(502) <= 361;	random(361) <= 251;	random(251) <= 193;	random(193) <= 190;	random(190) <= 178;	random(178) <= 56;	random(56) <= 289;	random(289) <= 55;	random(55) <= 44;	random(44) <= 155;	random(155) <= 107;	random(107) <= 51;	random(51) <= 7;	random(7) <= 331;	random(331) <= 1;	random(1) <= 302;	random(302) <= 247;	random(247) <= 120;	random(120) <= 172;	random(172) <= 410;	random(410) <= 365;	random(365) <= 269;	random(269) <= 513;	random(513) <= 307;	random(307) <= 511;	random(511) <= 308;	random(308) <= 249;	random(249) <= 304;	random(304) <= 291;	random(291) <= 470;	random(470) <= 395;	random(395) <= 353;	random(353) <= 81;	random(81) <= 450;	random(450) <= 99;	random(99) <= 126;	random(126) <= 197;	random(197) <= 348;	random(348) <= 334;	random(334) <= 349;	random(349) <= 72;	random(72) <= 158;	random(158) <= 222;	random(222) <= 390;	random(390) <= 321;	random(321) <= 478;	random(478) <= 86;	random(86) <= 90;	random(90) <= 392;	random(392) <= 129;	random(129) <= 436;	random(436) <= 195;	random(195) <= 354;	random(354) <= 258;	random(258) <= 263;	random(263) <= 266;	random(266) <= 73;	random(73) <= 160;	random(160) <= 330;	random(330) <= 256;	random(256) <= 363;	random(363) <= 284;	random(284) <= 82;	random(82) <= 389;	random(389) <= 142;	random(142) <= 153;	random(153) <= 311;	random(311) <= 45;	random(45) <= 186;	random(186) <= 327;	random(327) <= 154;	random(154) <= 355;	random(355) <= 451;	random(451) <= 225;	random(225) <= 288;	random(288) <= 184;	random(184) <= 270;	random(270) <= 423;	random(423) <= 388;	random(388) <= 496;	random(496) <= 323;	random(323) <= 205;	random(205) <= 362;	random(362) <= 150;	random(150) <= 394;	random(394) <= 113;	random(113) <= 8;	random(8) <= 328;	random(328) <= 431;	random(431) <= 503;	random(503) <= 329;	random(329) <= 373;	random(373) <= 42;	random(42) <= 313;	random(313) <= 246;	random(246) <= 441;	random(441) <= 374;	random(374) <= 485;	random(485) <= 21;	random(21) <= 357;	random(357) <= 369;	random(369) <= 123;	random(123) <= 215;	random(215) <= 427;	random(427) <= 146;	random(146) <= 514;	random(514) <= 145;	random(145) <= 164;	random(164) <= 460;	random(460) <= 138;	random(138) <= 229;	random(229) <= 306;	random(306) <= 41;	random(41) <= 5;	random(5) <= 492;	random(492) <= 300;	random(300) <= 62;	random(62) <= 169;	random(169) <= 340;	random(340) <= 337;	random(337) <= 439;	random(439) <= 96;	random(96) <= 324;	random(324) <= 261;	random(261) <= 301;	random(301) <= 10;	random(10) <= 109;	random(109) <= 219;	random(219) <= 106;	random(106) <= 121;	random(121) <= 406;	random(406) <= 467;	random(467) <= 489;	random(489) <= 444;	random(444) <= 134;	random(134) <= 23;	random(23) <= 285;	random(285) <= 89;	random(89) <= 102;	random(102) <= 115;	random(115) <= 415;	random(415) <= 112;	random(112) <= 319;	random(319) <= 283;	random(283) <= 132;	random(132) <= 463;	random(463) <= 484;	random(484) <= 468;	random(468) <= 456;	random(456) <= 29;	random(29) <= 75;	random(75) <= 122;	random(122) <= 303;	random(303) <= 346;	random(346) <= 137;	random(137) <= 240;	random(240) <= 325;	random(325) <= 11;	random(11) <= 384;	random(384) <= 236;	random(236) <= 421;	random(421) <= 320;	random(320) <= 377;	random(377) <= 453;	random(453) <= 36;	random(36) <= 347;	random(347) <= 245;	random(245) <= 352;	random(352) <= 83;	random(83) <= 128;	random(128) <= 118;	random(118) <= 74;	random(74) <= 465;	random(465) <= 223;	random(223) <= 293;	random(293) <= 92;	random(92) <= 30;	random(30) <= 509;	random(509) <= 88;	random(88) <= 364;	random(364) <= 49;	random(49) <= 171;	random(171) <= 464;	random(464) <= 312;	random(312) <= 299;	random(299) <= 183;	random(183) <= 144;	random(144) <= 241;	random(241) <= 220;	random(220) <= 152;	random(152) <= 248;	random(248) <= 376;	random(376) <= 448;	random(448) <= 475;	random(475) <= 84;	random(84) <= 426;	random(426) <= 53;	random(53) <= 351;	random(351) <= 48;	random(48) <= 350;	random(350) <= 17;	random(17) <= 27;	random(27) <= 103;	random(103) <= 66;	random(66) <= 461;	random(461) <= 114;	random(114) <= 95;	random(95) <= 295;	random(295) <= 130;	random(130) <= 131;	random(131) <= 452;	random(452) <= 199;	random(199) <= 202;	random(202) <= 290;	random(290) <= 151;	random(151) <= 59;	random(59) <= 454;	random(454) <= 476;	random(476) <= 40;	random(40) <= 177;	random(177) <= 519;	random(519) <= 93;	random(93) <= 480;	random(480) <= 272;	random(272) <= 487;	random(487) <= 343;	random(343) <= 314;	random(314) <= 486;	random(486) <= 488;	random(488) <= 419;	random(419) <= 344;	random(344) <= 493;	random(493) <= 411;	random(411) <= 227;	random(227) <= 238;	random(238) <= 175;	random(175) <= 318;	random(318) <= 506;	random(506) <= 497;	random(497) <= 495;	random(495) <= 87;	random(87) <= 370;	random(370) <= 479;	random(479) <= 76;	random(76) <= 287;	random(287) <= 116;	random(116) <= 466;	random(466) <= 97;	random(97) <= 412;	random(412) <= 405;	random(405) <= 124;	random(124) <= 35;	random(35) <= 499;	random(499) <= 156;	random(156) <= 19;	random(19) <= 386;	random(386) <= 191;	random(191) <= 135;	random(135) <= 474;	random(474) <= 255;	random(255) <= 69;	random(69) <= 105;	random(105) <= 477;	random(477) <= 425;	random(425) <= 239;	random(239) <= 322;	random(322) <= 393;	random(393) <= 294;	random(294) <= 212;	random(212) <= 483;

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
                if (asteroids(i).x <= x1+X_SIZE) and (asteroids(i).x >= x1) and (asteroids(i).y >= y1) and (asteroids(i).y <= y1+ Y_SIZE) then
                    collided_1 <= true;
                end if;
                if (asteroids(i).x <= x2+X_SIZE) and (asteroids(i).x >= x2) and (asteroids(i).y >= y2) and (asteroids(i).y <= y2+ Y_SIZE) then
                    collided_2 <= true;
                end if;
                
            end loop;
            if collided_1 = true then
                y1 <= V_END - Y_SIZE;
                collided_1 <=false;
            else
                if ((BTNU = '1') or (center_button = '1')) then
                    if ( y1 <= V_START) then
                        y1 <= V_END - Y_SIZE;
                        score_1 <= score_1+1;
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
                        score_2 <= score_2+1;
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
                        asteroids(i).y <= random(asteroids(i).y);
                        --direction and x according to y value
                        if (asteroids(i).dir = Right) then
                            asteroids(i).x <= H_START+1;
                        elsif (asteroids(i).dir = Left) then
                            asteroids(i).x <= H_END - 50;
                        end if;
                        asteroids(i).is_activated <= true;
                    end if;
                end if;
            end loop;
        end if;
    end process;
    
    --transfer score to pmod ssd
    process (score_1, score_2)
    begin
        data_in1 <= score_1;
        data_in2 <= score_2;
    end process;

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
