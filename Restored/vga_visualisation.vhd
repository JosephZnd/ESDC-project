-- Copyright (C) 1991-2010 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II"
-- VERSION		"Version 9.1 Build 350 03/24/2010 Service Pack 2 SJ Web Edition"
<<<<<<< HEAD
-- CREATED		"Thu Dec 14 13:48:11 2023"
=======
-- CREATED		"Thu Dec 14 13:24:08 2023"
>>>>>>> df89e4c80c30746e5454062a2b141721b3f760cd

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY vga_visualisation IS 
	PORT
	(
		CLK_50 :  IN  STD_LOGIC;
<<<<<<< HEAD
		n_RST :  IN  STD_LOGIC;
		cursor_x :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		cursor_y :  IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
=======
		LG7 :  IN  STD_LOGIC;
		LG6 :  IN  STD_LOGIC;
		LG2 :  IN  STD_LOGIC;
		LG1 :  IN  STD_LOGIC;
		LG0 :  IN  STD_LOGIC;
		LR2 :  IN  STD_LOGIC;
		LR1 :  IN  STD_LOGIC;
		LR0 :  IN  STD_LOGIC;
		n_RST :  IN  STD_LOGIC;
>>>>>>> df89e4c80c30746e5454062a2b141721b3f760cd
		vga_hs :  OUT  STD_LOGIC;
		vga_vs :  OUT  STD_LOGIC;
		vga_blank :  OUT  STD_LOGIC;
		vga_syn1 :  OUT  STD_LOGIC;
		VGA_CLK :  OUT  STD_LOGIC;
		B :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
		G :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
		R :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END vga_visualisation;

ARCHITECTURE bdf_type OF vga_visualisation IS 

COMPONENT video_memory
	PORT(wren : IN STD_LOGIC;
		 wrclock : IN STD_LOGIC;
		 rdclock : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 rdaddress : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		 wraddress : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END COMPONENT;

COMPONENT wr_memory
	PORT(clk_d1 : IN STD_LOGIC;
		 start : IN STD_LOGIC;
		 nrst : IN STD_LOGIC;
		 color_t : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 x_t : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 y_t : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		 we : OUT STD_LOGIC;
		 done : OUT STD_LOGIC;
		 adr_memo : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
		 data : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END COMPONENT;

COMPONENT vga_sync
	PORT(clock_25Mhz : IN STD_LOGIC;
		 color_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 vga_hs : OUT STD_LOGIC;
		 vga_vs : OUT STD_LOGIC;
		 vga_blank : OUT STD_LOGIC;
		 vga_sync : OUT STD_LOGIC;
		 vga_clk : OUT STD_LOGIC;
		 pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 pixel_row : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 vga_b : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 vga_g : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 vga_r : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;

COMPONENT clk_video
	PORT(inclk : IN STD_LOGIC;
		 outclk : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT add_generator
	PORT(pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 pixel_row : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 adr_memo : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
	);
END COMPONENT;

COMPONENT square
	PORT(clk_d1 : IN STD_LOGIC;
		 nrst : IN STD_LOGIC;
<<<<<<< HEAD
		 done : IN STD_LOGIC;
		 x_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 y_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
=======
		 LG7 : IN STD_LOGIC;
		 LG6 : IN STD_LOGIC;
		 LG2 : IN STD_LOGIC;
		 LG1 : IN STD_LOGIC;
		 LG0 : IN STD_LOGIC;
		 LR2 : IN STD_LOGIC;
		 LR1 : IN STD_LOGIC;
		 LR0 : IN STD_LOGIC;
		 done : IN STD_LOGIC;
>>>>>>> df89e4c80c30746e5454062a2b141721b3f760cd
		 start : OUT STD_LOGIC;
		 color_t : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 x_t : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 y_t : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT clk_div_two
	PORT(clock_50Mhz : IN STD_LOGIC;
		 nrst : IN STD_LOGIC;
		 clock_25MHz : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	add :  STD_LOGIC_VECTOR(14 DOWNTO 0);
SIGNAL	clk_25 :  STD_LOGIC;
SIGNAL	col :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	nrst :  STD_LOGIC;
SIGNAL	row :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(14 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;


BEGIN 



b2v_inst : video_memory
PORT MAP(wren => SYNTHESIZED_WIRE_0,
		 wrclock => CLK_50,
		 rdclock => clk_25,
		 data => SYNTHESIZED_WIRE_1,
		 rdaddress => add,
		 wraddress => SYNTHESIZED_WIRE_2,
		 q => SYNTHESIZED_WIRE_7);


b2v_inst1 : wr_memory
PORT MAP(clk_d1 => CLK_50,
		 start => SYNTHESIZED_WIRE_3,
		 nrst => nrst,
		 color_t => SYNTHESIZED_WIRE_4,
		 x_t => SYNTHESIZED_WIRE_5,
		 y_t => SYNTHESIZED_WIRE_6,
		 we => SYNTHESIZED_WIRE_0,
		 done => SYNTHESIZED_WIRE_9,
		 adr_memo => SYNTHESIZED_WIRE_2,
		 data => SYNTHESIZED_WIRE_1);


b2v_inst2 : vga_sync
PORT MAP(clock_25Mhz => clk_25,
		 color_in => SYNTHESIZED_WIRE_7,
		 vga_hs => vga_hs,
		 vga_vs => vga_vs,
		 vga_blank => vga_blank,
		 vga_sync => vga_syn1,
		 vga_clk => VGA_CLK,
		 pixel_column => col,
		 pixel_row => row,
		 vga_b => B,
		 vga_g => G,
		 vga_r => R);


b2v_inst3 : clk_video
PORT MAP(inclk => SYNTHESIZED_WIRE_8,
		 outclk => clk_25);


b2v_inst7 : add_generator
PORT MAP(pixel_column => col,
		 pixel_row => row,
		 adr_memo => add);


b2v_inst8 : square
PORT MAP(clk_d1 => CLK_50,
		 nrst => nrst,
<<<<<<< HEAD
		 done => SYNTHESIZED_WIRE_9,
		 x_in => cursor_x,
		 y_in => cursor_y,
=======
		 LG7 => LG7,
		 LG6 => LG6,
		 LG2 => LG2,
		 LG1 => LG1,
		 LG0 => LG0,
		 LR2 => LR2,
		 LR1 => LR1,
		 LR0 => LR0,
		 done => SYNTHESIZED_WIRE_9,
>>>>>>> df89e4c80c30746e5454062a2b141721b3f760cd
		 start => SYNTHESIZED_WIRE_3,
		 color_t => SYNTHESIZED_WIRE_4,
		 x_t => SYNTHESIZED_WIRE_5,
		 y_t => SYNTHESIZED_WIRE_6);


b2v_inst9 : clk_div_two
PORT MAP(clock_50Mhz => CLK_50,
		 nrst => nrst,
		 clock_25MHz => SYNTHESIZED_WIRE_8);

nrst <= n_RST;

END bdf_type;