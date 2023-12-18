-----------------------------------------------------------------------------------------
-- Block square : indicates to WRITE MEMORY where a new square must be plotted in the VGA screen
-- x_t: left top column coordinate. 8 MSB of the 10 bits needed.
-- y_t: left top row coordinate. 7 MSB of the 9 bitw needed.
-- color_t: RGB components of the square to plot. 3 bits
-- Start: order to start writing the memory.
-- Inputs: status of the board LEDS.
-- Author: Josep Altet. 
-- Version 1.0 : Date: 12-02-2019.
-- Version 2.0 : Date: 25-02-2020 (Adapted to Theory lecture).
-- Version 3.0 : Date: 08-09-2021 Adapted to Design 1.
-- Electronic System Design for Communications - ESDC - ETSTB. UPC. Barcelona.
----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity square is
  port( clk_d1, nrst		: in std_logic;
		x_in				: in integer range 0 to 160;
		y_in				: in integer range 0 to 120;
		sel: in std_logic;
		start			: out std_logic;
		x_t				: out integer range 0 to 160;
		y_t				: out integer range 0 to 120;
		color_t 		: out integer range 0 to 7;
		
		done			: in std_logic);  -- To be connected to the RAM ADD Bus.
end square;


architecture functional of square is
  
  -- Coordinates of the squares
  constant X0 : integer := 11;
  constant X1 : integer := 25;
  constant X2 : integer := 39;
  constant X3 : integer := 53;
  constant X4 : integer := 67;
  constant X5 : integer := 81;
  constant X6 : integer := 95;
  constant X7 : integer := 109;

  
  constant Y0 : integer := 1;
  constant Y1 : integer := 15;
  constant Y2 : integer := 29;
  constant Y3 : integer := 43;
  constant Y4 : integer := 57;
  constant Y5 : integer := 71;
  constant Y6 : integer := 85;
  constant Y7 : integer := 99;
  
  -- Possible colors of the squares.
  -- Precondition: memory is created blank (remaining color = 000).
  constant RED : integer := 4;
  --constant BLUE : integer := 1;
  --constant WHITE : integer := 2;
  --constant GREEN : integer := 3; sky blue
  --constant WHITE : integer := 5; MAGENTA
  constant GREEN : integer := 0; --VERDE-NEGRO
  constant WHITE : integer := 7; --BLANCO
  constant BLUE : integer:= 3;

   

  -- State definition:
  type state_type is (
    s00a, s00b, s00c, s10a, s10b, s10c, s20a, s20b, s20c,
    s30a, s30b, s30c, s40a, s40b, s40c, s50a, s50b, s50c,
    s60a, s60b, s60c, s70a, s70b, s70c, s01a, s01b, s01c,
    s11a, s11b, s11c, s21a, s21b, s21c, s31a, s31b, s31c,
    s41a, s41b, s41c, s51a, s51b, s51c, s61a, s61b, s61c,
    s71a, s71b, s71c, s02a, s02b, s02c, s12a, s12b, s12c,
    s22a, s22b, s22c, s32a, s32b, s32c, s42a, s42b, s42c,
    s52a, s52b, s52c, s62a, s62b, s62c, s72a, s72b, s72c,
    s03a, s03b, s03c, s13a, s13b, s13c, s23a, s23b, s23c,
    s33a, s33b, s33c, s43a, s43b, s43c, s53a, s53b, s53c,
    s63a, s63b, s63c, s73a, s73b, s73c, s04a, s04b, s04c,
    s14a, s14b, s14c, s24a, s24b, s24c, s34a, s34b, s34c,
    s44a, s44b, s44c, s54a, s54b, s54c, s64a, s64b, s64c,
    s74a, s74b, s74c, s05a, s05b, s05c, s15a, s15b, s15c,
    s25a, s25b, s25c, s35a, s35b, s35c, s45a, s45b, s45c,
    s55a, s55b, s55c, s65a, s65b, s65c, s75a, s75b, s75c,
    s06a, s06b, s06c, s16a, s16b, s16c, s26a, s26b, s26c,
    s36a, s36b, s36c, s46a, s46b, s46c, s56a, s56b, s56c,
    s66a, s66b, s66c, s76a, s76b, s76c, s07a, s07b, s07c,
    s17a, s17b, s17c, s27a, s27b, s27c, s37a, s37b, s37c,
    s47a, s47b, s47c, s57a, s57b, s57c, s67a, s67b, s67c,
    s77a, s77b, s77c, s_cursor_a,s_cursor_b,s_cursor_c, s_select_a, s_select_b, s_select_c
);
  
  -- Internal signals

  signal c_x	: integer range 0 to 160:=67;
  signal c_y	: integer range 0 to 120:=57;
  signal t_x  	: integer range 0 to 160:=25;
  signal t_y 	: integer range 0 to 120:=15;  -- Output of the state register
  signal st_square : state_type	;
  signal internal_sel: std_logic;
  signal sel_x : integer range 0 to 162;
  signal sel_y : integer range 0 to 120;
  -- Internal address memory bus
  
  Begin
-- All signals updated inside if (clk_d1'event and clk_d1='1') are output of registers!!
-- With this VHDL description, Control Unit and Process Unit are described with one single Process.
-- Control Unit: state flow.
-- Process Unit: Blocks that process data (counters, registers).
-- Control signals: they are not specified in the VHDL description, but they will be in the final implemented design. 
-- Only output control signals are presented.
	process(clk_d1, nrst, x_in, y_in)
	Begin
		if (nrst = '0') then
			st_square <= s00a;
		elsif rising_edge(clk_d1) then
			case st_square is
					-- Row 1
					when s00a =>
						st_square <= s00b;
						x_t <= X0; y_t <= Y0;
						color_t <= WHITE;
					when s00b =>
						st_square <= s00c;
					when s00c =>
						if done = '1' then st_square <= s10a; end if;

					-- Row 2
					when s10a =>
						st_square <= s10b;
						x_t <= X1; y_t <= Y0;
						color_t <= GREEN;
					when s10b =>
						st_square <= s10c;
					when s10c =>
						if done = '1' then st_square <= s20a; end if;

					-- Row 3
					when s20a =>
						st_square <= s20b;
						x_t <= X2; y_t <= Y0;
						color_t <= WHITE;
					when s20b =>
						st_square <= s20c;
					when s20c =>
						if done = '1' then st_square <= s30a; end if;

					-- Row 4
					when s30a =>
						st_square <= s30b;
						x_t <= X3; y_t <= Y0;
						color_t <= GREEN;
					when s30b =>
						st_square <= s30c;
					when s30c =>
						if done = '1' then st_square <= s40a; end if;

					-- Row 5
					when s40a =>
						st_square <= s40b;
						x_t <= X4; y_t <= Y0;
						color_t <= WHITE;
					when s40b =>
						st_square <= s40c;
					when s40c =>
						if done = '1' then st_square <= s50a; end if;

					-- Row 6
					when s50a =>
						st_square <= s50b;
						x_t <= X5; y_t <= Y0;
						color_t <= GREEN;
					when s50b =>
						st_square <= s50c;
					when s50c =>
						if done = '1' then st_square <= s60a; end if;

					-- Row 7
					when s60a =>
						st_square <= s60b;
						x_t <= X6; y_t <= Y0;
						color_t <= WHITE;
					when s60b =>
						st_square <= s60c;
					when s60c =>
						if done = '1' then st_square <= s70a; end if;

					-- Row 8
					when s70a =>
						st_square <= s70b;
						x_t <= X7; y_t <= Y0;
						color_t <= GREEN;
					when s70b =>
						st_square <= s70c;
					when s70c =>
						if done = '1' then st_square <= s01a; end if;
						
						-- Continue this pattern for several rows...

					-- Row 1
					when s01a =>
						st_square <= s01b;
						x_t <= X0; y_t <= Y1;
						color_t <= GREEN; -- Swapped color
					when s01b =>
						st_square <= s01c;
					when s01c =>
						if done = '1' then st_square <= s11a; end if;

					-- Row 2
					when s11a =>
						st_square <= s11b;
						x_t <= X1; y_t <= Y1;
						color_t <= WHITE; -- Swapped color
					when s11b =>
						st_square <= s11c;
					when s11c =>
						if done = '1' then st_square <= s21a; end if;

					-- Row 3
					when s21a =>
						st_square <= s21b;
						x_t <= X2; y_t <= Y1;
						color_t <= GREEN; -- Swapped color
					when s21b =>
						st_square <= s21c;
					when s21c =>
						if done = '1' then st_square <= s31a; end if;

					-- Row 4
					when s31a =>
						st_square <= s31b;
						x_t <= X3; y_t <= Y1;
						color_t <= WHITE; -- Swapped color
					when s31b =>
						st_square <= s31c;
					when s31c =>
						if done = '1' then st_square <= s41a; end if;

					-- Row 5
					when s41a =>
						st_square <= s41b;
						x_t <= X4; y_t <= Y1;
						color_t <= GREEN; -- Swapped color
					when s41b =>
						st_square <= s41c;
					when s41c =>
						if done = '1' then st_square <= s51a; end if;

					-- Row 6
					when s51a =>
						st_square <= s51b;
						x_t <= X5; y_t <= Y1;
						color_t <= WHITE; -- Swapped color
					when s51b =>
						st_square <= s51c;
					when s51c =>
						if done = '1' then st_square <= s61a; end if;

					-- Row 7
					when s61a =>
						st_square <= s61b;
						x_t <= X6; y_t <= Y1;
						color_t <= GREEN; -- Swapped color
					when s61b =>
						st_square <= s61c;
					when s61c =>
						if done = '1' then st_square <= s71a; end if;

					-- Row 8
					when s71a =>
						st_square <= s71b;
						x_t <= X7; y_t <= Y1;
						color_t <= WHITE; -- Swapped color
					when s71b =>
						st_square <= s71c;
					when s71c =>
						if done = '1' then st_square <= s02a; end if;
						
									-- Row 1
					when s02a =>
						st_square <= s02b;
						x_t <= X0; y_t <= Y2;
						color_t <= WHITE;
					when s02b =>
						st_square <= s02c;
					when s02c =>
						if done = '1' then st_square <= s12a; end if;

					-- Row 2
					when s12a =>
						st_square <= s12b;
						x_t <= X1; y_t <= Y2;
						color_t <= GREEN;
					when s12b =>
						st_square <= s12c;
					when s12c =>
						if done = '1' then st_square <= s22a; end if;

					-- Row 3
					when s22a =>
						st_square <= s22b;
						x_t <= X2; y_t <= Y2;
						color_t <= WHITE;
					when s22b =>
						st_square <= s22c;
					when s22c =>
						if done = '1' then st_square <= s32a; end if;

					-- Row 4
					when s32a =>
						st_square <= s32b;
						x_t <= X3; y_t <= Y2;
						color_t <= GREEN;
					when s32b =>
						st_square <= s32c;
					when s32c =>
						if done = '1' then st_square <= s42a; end if;

					-- Row 5
					when s42a =>
						st_square <= s42b;
						x_t <= X4; y_t <= Y2;
						color_t <= WHITE;
					when s42b =>
						st_square <= s42c;
					when s42c =>
						if done = '1' then st_square <= s52a; end if;

					-- Row 6
					when s52a =>
						st_square <= s52b;
						x_t <= X5; y_t <= Y2;
						color_t <= GREEN;
					when s52b =>
						st_square <= s52c;
					when s52c =>
						if done = '1' then st_square <= s62a; end if;

					-- Row 7
					when s62a =>
						st_square <= s62b;
						x_t <= X6; y_t <= Y2;
						color_t <= WHITE;
					when s62b =>
						st_square <= s62c;
					when s62c =>
						if done = '1' then st_square <= s72a; end if;

					-- Row 8
					when s72a =>
						st_square <= s72b;
						x_t <= X7; y_t <= Y2;
						color_t <= GREEN;
					when s72b =>
						st_square <= s72c;
					when s72c =>
						if done = '1' then st_square <= s03a; end if;
									
									-- Row 1
					when s03a =>
						st_square <= s03b;
						x_t <= X0; y_t <= Y3;
						color_t <= GREEN;
					when s03b =>
						st_square <= s03c;
					when s03c =>
						if done = '1' then st_square <= s13a; end if;

					-- Row 2
					when s13a =>
						st_square <= s13b;
						x_t <= X1; y_t <= Y3;
						color_t <= WHITE;
					when s13b =>
						st_square <= s13c;
					when s13c =>
						if done = '1' then st_square <= s23a; end if;

					-- Row 3
					when s23a =>
						st_square <= s23b;
						x_t <= X2; y_t <= Y3;
						color_t <= GREEN;
					when s23b =>
						st_square <= s23c;
					when s23c =>
						if done = '1' then st_square <= s33a; end if;

					-- Row 4
					when s33a =>
						st_square <= s33b;
						x_t <= X3; y_t <= Y3;
						color_t <= WHITE;
					when s33b =>
						st_square <= s33c;
					when s33c =>
						if done = '1' then st_square <= s43a; end if;

					-- Row 5
					when s43a =>
						st_square <= s43b;
						x_t <= X4; y_t <= Y3;
						color_t <= GREEN;
					when s43b =>
						st_square <= s43c;
					when s43c =>
						if done = '1' then st_square <= s53a; end if;

					-- Row 6
					when s53a =>
						st_square <= s53b;
						x_t <= X5; y_t <= Y3;
						color_t <= WHITE;
					when s53b =>
						st_square <= s53c;
					when s53c =>
						if done = '1' then st_square <= s63a; end if;

					-- Row 7
					when s63a =>
						st_square <= s63b;
						x_t <= X6; y_t <= Y3;
						color_t <= GREEN;
					when s63b =>
						st_square <= s63c;
					when s63c =>
						if done = '1' then st_square <= s73a; end if;

					-- Row 8
					when s73a =>
						st_square <= s73b;
						x_t <= X7; y_t <= Y3;
						color_t <= WHITE;
					when s73b =>
						st_square <= s73c;
					when s73c =>
						if done = '1' then st_square <= s04a; end if;
						
						
									-- Row 1
					when s04a =>
						st_square <= s04b;
						x_t <= X0; y_t <= Y4;
						color_t <= WHITE;
					when s04b =>
						st_square <= s04c;
					when s04c =>
						if done = '1' then st_square <= s14a; end if;

					-- Row 2
					when s14a =>
						st_square <= s14b;
						x_t <= X1; y_t <= Y4;
						color_t <= GREEN;
					when s14b =>
						st_square <= s14c;
					when s14c =>
						if done = '1' then st_square <= s24a; end if;

					-- Row 3
					when s24a =>
						st_square <= s24b;
						x_t <= X2; y_t <= Y4;
						color_t <= WHITE;
					when s24b =>
						st_square <= s24c;
					when s24c =>
						if done = '1' then st_square <= s34a; end if;

					-- Row 4
					when s34a =>
						st_square <= s34b;
						x_t <= X3; y_t <= Y4;
						color_t <= GREEN;
					when s34b =>
						st_square <= s34c;
					when s34c =>
						if done = '1' then st_square <= s44a; end if;

					-- Row 5
					when s44a =>
						st_square <= s44b;
						x_t <= X4; y_t <= Y4;
						color_t <= WHITE;
					when s44b =>
						st_square <= s44c;
					when s44c =>
						if done = '1' then st_square <= s54a; end if;

					-- Row 6
					when s54a =>
						st_square <= s54b;
						x_t <= X5; y_t <= Y4;
						color_t <= GREEN;
					when s54b =>
						st_square <= s54c;
					when s54c =>
						if done = '1' then st_square <= s64a; end if;

					-- Row 7
					when s64a =>
						st_square <= s64b;
						x_t <= X6; y_t <= Y4;
						color_t <= WHITE;
					when s64b =>
						st_square <= s64c;
					when s64c =>
						if done = '1' then st_square <= s74a; end if;

					-- Row 8
					when s74a =>
						st_square <= s74b;
						x_t <= X7; y_t <= Y4;
						color_t <= GREEN;
					when s74b =>
						st_square <= s74c;
					when s74c =>
						if done = '1' then st_square <= s05a; end if;
						
						
					when s05a =>
						st_square <= s05b;
						x_t <= X0; y_t <= Y5;
						color_t <= GREEN;
					when s05b =>
						st_square <= s05c;
					when s05c =>
						if done = '1' then st_square <= s15a; end if;

					when s15a =>
						st_square <= s15b;
						x_t <= X1; y_t <= Y5;
						color_t <= WHITE;
					when s15b =>
						st_square <= s15c;
					when s15c =>
						if done = '1' then st_square <= s25a; end if;

					when s25a =>
						st_square <= s25b;
						x_t <= X2; y_t <= Y5;
						color_t <= GREEN;
					when s25b =>
						st_square <= s25c;
					when s25c =>
						if done = '1' then st_square <= s35a; end if;

					when s35a =>
						st_square <= s35b;
						x_t <= X3; y_t <= Y5;
						color_t <= WHITE;
					when s35b =>
						st_square <= s35c;
					when s35c =>
						if done = '1' then st_square <= s45a; end if;

					when s45a =>
						st_square <= s45b;
						x_t <= X4; y_t <= Y5;
						color_t <= GREEN;
					when s45b =>
						st_square <= s45c;
					when s45c =>
						if done = '1' then st_square <= s55a; end if;

					when s55a =>
						st_square <= s55b;
						x_t <= X5; y_t <= Y5;
						color_t <= WHITE;
					when s55b =>
						st_square <= s55c;
					when s55c =>
						if done = '1' then st_square <= s65a; end if;

					when s65a =>
						st_square <= s65b;
						x_t <= X6; y_t <= Y5;
						color_t <= GREEN;
					when s65b =>
						st_square <= s65c;
					when s65c =>
						if done = '1' then st_square <= s75a; end if;

					when s75a =>
						st_square <= s75b;
						x_t <= X7; y_t <= Y5;
						color_t <= WHITE;
					when s75b =>
						st_square <= s75c;
					when s75c =>
						if done = '1' then st_square <= s06a; end if;
						
					when s06a =>
						st_square <= s06b;
						x_t <= X0; y_t <= Y6;
						color_t <= WHITE;
					when s06b =>
						st_square <= s06c;
					when s06c =>
						if done = '1' then st_square <= s16a; end if;

					when s16a =>
						st_square <= s16b;
						x_t <= X1; y_t <= Y6;
						color_t <= GREEN;
					when s16b =>
						st_square <= s16c;
					when s16c =>
						if done = '1' then st_square <= s26a; end if;

					when s26a =>
						st_square <= s26b;
						x_t <= X2; y_t <= Y6;
						color_t <= WHITE;
					when s26b =>
						st_square <= s26c;
					when s26c =>
						if done = '1' then st_square <= s36a; end if;

					when s36a =>
						st_square <= s36b;
						x_t <= X3; y_t <= Y6;
						color_t <= GREEN;
					when s36b =>
						st_square <= s36c;
					when s36c =>
						if done = '1' then st_square <= s46a; end if;

					when s46a =>
						st_square <= s46b;
						x_t <= X4; y_t <= Y6;
						color_t <= WHITE;
					when s46b =>
						st_square <= s46c;
					when s46c =>
						if done = '1' then st_square <= s56a; end if;

					when s56a =>
						st_square <= s56b;
						x_t <= X5; y_t <= Y6;
						color_t <= GREEN;
					when s56b =>
						st_square <= s56c;
					when s56c =>
						if done = '1' then st_square <= s66a; end if;

					when s66a =>
						st_square <= s66b;
						x_t <= X6; y_t <= Y6;
						color_t <= WHITE;
					when s66b =>
						st_square <= s66c;
					when s66c =>
						if done = '1' then st_square <= s76a; end if;

					when s76a =>
						st_square <= s76b;
						x_t <= X7; y_t <= Y6;
						color_t <= GREEN;
					when s76b =>
						st_square <= s76c;
					when s76c =>
						if done = '1' then st_square <= s07a; end if;
						
						-- Row 7
					when s07a =>
						st_square <= s07b;
						x_t <= X0; y_t <= Y7;
						color_t <= GREEN;
					when s07b =>
						st_square <= s07c;
					when s07c =>
						if done = '1' then st_square <= s17a; end if;

					-- Row 17
					when s17a =>
						st_square <= s17b;
						x_t <= X1; y_t <= Y7;
						color_t <= WHITE;
					when s17b =>
						st_square <= s17c;
					when s17c =>
						if done = '1' then st_square <= s27a; end if;

					-- Row 27
					when s27a =>
						st_square <= s27b;
						x_t <= X2; y_t <= Y7;
						color_t <= GREEN;
					when s27b =>
						st_square <= s27c;
					when s27c =>
						if done = '1' then st_square <= s37a; end if;

					-- Row 37
					when s37a =>
						st_square <= s37b;
						x_t <= X3; y_t <= Y7;
						color_t <= WHITE;
					when s37b =>
						st_square <= s37c;
					when s37c =>
						if done = '1' then st_square <= s47a; end if;

					-- Row 47
					when s47a =>
						st_square <= s47b;
						x_t <= X4; y_t <= Y7;
						color_t <= GREEN;
					when s47b =>
						st_square <= s47c;
					when s47c =>
						if done = '1' then st_square <= s57a; end if;

					-- Row 57
					when s57a =>
						st_square <= s57b;
						x_t <= X5; y_t <= Y7;
						color_t <= WHITE;
					when s57b =>
						st_square <= s57c;
					when s57c =>
						if done = '1' then st_square <= s67a; end if;

					-- Row 67
					when s67a =>
						st_square <= s67b;
						x_t <= X6; y_t <= Y7;
						color_t <= GREEN;
					when s67b =>
						st_square <= s67c;
					when s67c =>
						if done = '1' then st_square <= s77a; end if;

					-- Row 77
					when s77a =>
						st_square <= s77b;
						x_t <= X7; y_t <= Y7;
						color_t <= WHITE;
					when s77b =>
						st_square <= s77c;
					when s77c =>
						if done = '1' then
							if internal_sel = '1' then
								st_square <= s_select_a;
							else
								st_square <= s_cursor_a; 
							end if;
						end if;	
						
					when s_cursor_a =>
						t_x <= x_in;
						t_y <= y_in;
						--si se mueve el cursor, primero pone el tablero a cero y luego ya pinta el square
						--aqui está puesto c_x como valor fijo para probar, luego se puede cambiar a x_in
						if (c_x /= t_x or c_y /= t_y) then
							st_square <= s00a;
							c_x<= t_x ; 
							c_y<= t_y ; 
						elsif sel='1' then
							if internal_sel = '1' then
								internal_sel <= '0';
							else
								internal_sel <= '1';
								sel_x <= c_x;
								sel_y <= c_y;
							end if;
						else st_square <= s_cursor_b;
						end if;
					when s_cursor_b =>
						x_t <= c_x; y_t <= c_y; --ESTO NO CONSIGO QUE FUNCIONE
						--x_t <= 53; y_t <= 43; --ESTO es para ver si lo sigue printeando bien, y si
						color_t <= RED;
						st_square <= s_cursor_c;
					when s_cursor_c =>
						if done = '1' then st_square <= s_cursor_a; end if;	
						
					when s_select_a =>
						st_square <= s_select_b;
						x_t <= sel_x; y_t <= sel_y;
						color_t <= BLUE;
					when s_select_b =>
						st_square <= s_select_c;
					when s_select_c =>
						if done = '1' then st_square <= s_cursor_a; end if;
			End Case;
		End If;
	End Process;
	
Start <= '1' when st_square = s00b or st_square = s10b or st_square = s20b or st_square = s30b or
               st_square = s40b or st_square = s50b or st_square = s60b or st_square = s70b or
               st_square = s01b or st_square = s11b or st_square = s21b or st_square = s31b or
               st_square = s41b or st_square = s51b or st_square = s61b or st_square = s71b or
               st_square = s02b or st_square = s12b or st_square = s22b or st_square = s32b or
               st_square = s42b or st_square = s52b or st_square = s62b or st_square = s72b or
               st_square = s03b or st_square = s13b or st_square = s23b or st_square = s33b or
               st_square = s43b or st_square = s53b or st_square = s63b or st_square = s73b or
               st_square = s04b or st_square = s14b or st_square = s24b or st_square = s34b or
               st_square = s44b or st_square = s54b or st_square = s64b or st_square = s74b or
               st_square = s05b or st_square = s15b or st_square = s25b or st_square = s35b or
               st_square = s45b or st_square = s55b or st_square = s65b or st_square = s75b or
               st_square = s06b or st_square = s16b or st_square = s26b or st_square = s36b or
               st_square = s46b or st_square = s56b or st_square = s66b or st_square = s76b or
               st_square = s07b or st_square = s17b or st_square = s27b or st_square = s37b or
               st_square = s47b or st_square = s57b or st_square = s67b or st_square = s77b or
               st_square = s_cursor_b or st_square = s_select_b else '0';
               
End Functional;