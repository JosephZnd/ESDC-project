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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity square is
  port( clk_d1, nrst, LG7, LG6, LG2, LG1, LG0   	 	: in std_logic;
			LR2, LR1, LR0 	: in std_logic;
		x_in				: in integer range 0 to 160;
		y_in				: in integer range 0 to 120;
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
  
  constant SIZE : integer :=14;
  
  -- Possible colors of the squares.
  -- Precondition: memory is created blank (remaining color = 000).
  constant RED : integer := 4;
  --constant BLUE : integer := 1;
  --constant GREEN : integer := 2;
  --constant BLUE : integer := 3; sky blue
  --constant GREEN : integer := 5; MAGENTA
  constant GREEN : integer := 0; --VERDE-NEGRO
  constant WHITE : integer := 7; --BLANCO

   

  -- State definition:
  type state_type is (
    s00a, s00b, s00c, s_cursor_a,s_cursor_b,s_cursor_c);
  
  -- Internal signals
	
  signal c_x	: integer range 0 to 160:=11;
  signal c_y	: integer range 0 to 120:=1;
  signal t_x  	: integer range 0 to 160:=25;
  signal t_y 	: integer range 0 to 120:=15;  -- Output of the state register
  signal st_square : state_type	;
  signal i, j : integer range 0 to 7:=0;
  signal color_index : std_logic;
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
			color_index <= '0';
		elsif rising_edge(clk_d1) then
			case st_square is
					-- Row 1
					when s00a =>
						st_square <= s00b;
						x_t <= (X0+SIZE*i); y_t <= (Y0+SIZE*j);
						if color_index = '0' then color_t <= WHITE; 
							else color_t <= GREEN; 
						end if;
					when s00b =>
						i <= i+1;
						color_index <= not color_index;
						if i=0 then
							j <= j+1;
							color_index <= not color_index;
						end if;
						st_square <= s00c;
					when s00c =>
						if done = '1' then st_square <= s_cursor_a; end if;

					-- Row 2
						
					when s_cursor_a =>
						--si se mueve el cursor, primero pone el tablero a cero y luego ya pinta el square
						--aqui está puesto c_x como valor fijo para probar, luego se puede cambiar a x_in
						if (c_x /= t_x) or (c_x /= t_x) then
							t_x <= c_x; 
							t_y <= c_y;
							st_square <= s00a;
						else st_square <= s_cursor_b;
						end if;
					when s_cursor_b =>
						x_t <= c_x; y_t <= c_y;
						color_t <= RED;
						st_square <= s_cursor_c;
					when s_cursor_c =>
						if done = '1' then st_square <= s_cursor_a; end if;	
			End Case;
		End If;
	End Process;

Start <= '1' when st_square = s00b or st_square = s_cursor_b else '0';
End Functional;