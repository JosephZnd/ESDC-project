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
-- CREATED		"Tue Mar 29 16:19:10 2022"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY i_o_manager_vga IS 
	PORT
	(
		BTN0 :  IN  STD_LOGIC;
		GAME_OVER :  IN  STD_LOGIC;
		USER_CODE :  IN  STD_LOGIC;
		GUES_CODE :  IN  STD_LOGIC;
		GREATHER :  IN  STD_LOGIC;
		SMALLER :  IN  STD_LOGIC;
		WINER :  IN  STD_LOGIC;
		LOSER :  IN  STD_LOGIC;
		TIE :  IN  STD_LOGIC;
		CLK_50 :  IN  STD_LOGIC;
		Gues_CodeD :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Gues_CodeH :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Gues_CodeU :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		key_code :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		NC :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Oponent_CodeH :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Oponent_CodeT :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Oponent_CodeU :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		sel: IN STD_LOGIC;
		nrst :  OUT  STD_LOGIC;
		R0 :  OUT  STD_LOGIC;
		R1 :  OUT  STD_LOGIC;
		R2 :  OUT  STD_LOGIC;
		G0 :  OUT  STD_LOGIC;
		G1 :  OUT  STD_LOGIC;
		G2 :  OUT  STD_LOGIC;
		G7 :  OUT  STD_LOGIC;
		G6 :  OUT  STD_LOGIC;
		R :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
		B :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
		G :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
		vga_hs :  OUT  STD_LOGIC;
		bga_vs :  OUT  STD_LOGIC;
		Vga_blank :  OUT  STD_LOGIC;
		Vga_Sync :  OUT  STD_LOGIC;
		VGA_Clock :  OUT  STD_LOGIC;
		
		H0 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H3 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H4 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H5 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H6 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H7 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		
		CURSx : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		CURSy : IN STD_LOGIC_VECTOR(6 DOWNTO 0)		
	);
END i_o_manager_vga;

ARCHITECTURE bdf_type OF i_o_manager_vga IS 

COMPONENT hex_disps
	PORT(num0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 num1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 num2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 num3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 num4 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 num5 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 num6 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 num7 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT vga_visualisation
	PORT(CLK_50 : IN STD_LOGIC;
		 n_RST : IN STD_LOGIC;
		 cursor_x : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 cursor_y : IN STD_LOGIC_VECTOR(6 DOWNTO 0);	
		 sel: IN STD_LOGIC;	
		 --LG2 : IN STD_LOGIC;
		 --LG1 : IN STD_LOGIC;
		 --LG0 : IN STD_LOGIC;
		 --LR2 : IN STD_LOGIC;
		 --LR1 : IN STD_LOGIC;
		 --LR0 : IN STD_LOGIC;
		 R : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 B : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 G : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 vga_hs : OUT STD_LOGIC;
		 vga_vs : OUT STD_LOGIC;
		 vga_blank : OUT STD_LOGIC;
		 vga_syn1 : OUT STD_LOGIC;
		 VGA_CLK : OUT STD_LOGIC
		
		
		 
	);
END COMPONENT;

SIGNAL	G_ALTERA_SYNTHESIZED0 :  STD_LOGIC;
SIGNAL	G_ALTERA_SYNTHESIZED1 :  STD_LOGIC;
SIGNAL	G_ALTERA_SYNTHESIZED2 :  STD_LOGIC;
SIGNAL	G_ALTERA_SYNTHESIZED6 :  STD_LOGIC;
SIGNAL	G_ALTERA_SYNTHESIZED7 :  STD_LOGIC;
SIGNAL	nrst_ALTERA_SYNTHESIZED :  STD_LOGIC;
SIGNAL	R_ALTERA_SYNTHESIZED0 :  STD_LOGIC;
SIGNAL	R_ALTERA_SYNTHESIZED1 :  STD_LOGIC;
SIGNAL	R_ALTERA_SYNTHESIZED2 :  STD_LOGIC;

SIGNAL	INTERNAL_CURSOR_X :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	INTERNAL_CURSOR_Y :  STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL 	INTERNAL_SEL: STD_LOGIC;


BEGIN 



b2v_inst : hex_disps
PORT MAP(num0 => key_code,
		 num1 => Gues_CodeU,
		 num2 => Gues_CodeD,
		 num3 => Gues_CodeH,
		 num4 => NC,
		 num5 => Oponent_CodeU,
		 num6 => Oponent_CodeT,
		 num7 => Oponent_CodeH,
		 HEX0 => H0,
		 HEX1 => H1,
		 HEX2 => H2,
		 HEX3 => H3,
		 HEX4 => H4,
		 HEX5 => H5,
		 HEX6 => H6,
		 HEX7 => H7);


b2v_inst1 : vga_visualisation
PORT MAP(CLK_50 => CLK_50,
		 n_RST => nrst_ALTERA_SYNTHESIZED,
		 --LG7 => G_ALTERA_SYNTHESIZED7,
		 --LG6 => G_ALTERA_SYNTHESIZED6,
		 --LG2 => G_ALTERA_SYNTHESIZED2,
		 --LG1 => G_ALTERA_SYNTHESIZED1,
		 --LG0 => G_ALTERA_SYNTHESIZED0,
		 --LR2 => R_ALTERA_SYNTHESIZED2,
		 --LR1 => R_ALTERA_SYNTHESIZED1,
		 --LR0 => R_ALTERA_SYNTHESIZED0,
		 cursor_x => INTERNAL_CURSOR_X,
		 cursor_y => INTERNAL_CURSOR_Y,
		 sel => INTERNAL_SEL,
		 vga_hs => vga_hs,
		 vga_vs => bga_vs,
		 vga_blank => Vga_blank,
		 vga_syn1 => Vga_Sync,
		 VGA_CLK => VGA_Clock,
		 B => B,
		 G => G,
		 R => R);

R_ALTERA_SYNTHESIZED0 <= GAME_OVER;


R_ALTERA_SYNTHESIZED1 <= USER_CODE;


R_ALTERA_SYNTHESIZED2 <= GUES_CODE;


G_ALTERA_SYNTHESIZED7 <= GREATHER;


G_ALTERA_SYNTHESIZED6 <= SMALLER;


G_ALTERA_SYNTHESIZED0 <= WINER;


G_ALTERA_SYNTHESIZED1 <= LOSER;


G_ALTERA_SYNTHESIZED2 <= TIE;


nrst_ALTERA_SYNTHESIZED <= BTN0;

INTERNAL_CURSOR_X <= CURSx;

INTERNAL_CURSOR_Y <= CURSy;

INTERNAL_SEL <= sel; 


nrst <= nrst_ALTERA_SYNTHESIZED;
R0 <= R_ALTERA_SYNTHESIZED0;
R1 <= R_ALTERA_SYNTHESIZED1;
R2 <= R_ALTERA_SYNTHESIZED2;
G0 <= G_ALTERA_SYNTHESIZED0;
G1 <= G_ALTERA_SYNTHESIZED1;
G2 <= G_ALTERA_SYNTHESIZED2;
G7 <= G_ALTERA_SYNTHESIZED7;
G6 <= G_ALTERA_SYNTHESIZED6;

END bdf_type;