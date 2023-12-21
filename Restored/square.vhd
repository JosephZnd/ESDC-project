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
		done			: in std_logic;  -- To be connected to the RAM ADD Bus.
		new_game		:	in std_logic;
		start			: out std_logic;
		x_t				: out integer range 0 to 160;
		y_t				: out integer range 0 to 120;
		color_t 		: out integer range 0 to 7);
		--adr_memo		: out std_logic_vector(5 downto 0));
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
  constant MAGENTA : integer := 5; --MAGENTA
  constant GREEN : integer := 0		; --VERDE-NEGRO
  constant WHITE : integer := 7; --BLANCO
  constant BLUE : integer:= 1;
  constant SIZE : integer :=14;

   

  -- State definition:
  type state_type is (
    s00, s00a, s00b, s00c, s_cursor_a,s_cursor_b,s_cursor_c, 
    s_select_a, s_select_b, s_select_c, s_cursor_wait, s_game_wait
);
  
  -- Internal signals

  signal c_x	: integer range 0 to 160:=67;
  signal c_y	: integer range 0 to 120:=57;
  signal t_x  	: integer range 0 to 160:=25;
  signal t_y 	: integer range 0 to 120:=15;  -- Output of the state register
  signal st_square : state_type	;
  signal internal_sel, sel_selected: std_logic;
  signal sel_x, x_out : integer range 0 to 160;
  signal sel_y, y_out : integer range 0 to 120;
  signal i, j : integer range 0 to 7:=0;
  signal color_index, SelMode, s_new_game : std_logic;
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
			sel_selected <='0';
			color_index <= '0';
			SelMode <= '0';
			s_new_game <= '0';
		elsif rising_edge(clk_d1) then
			case st_square is
					-- Row 1
					when s00 =>
						--st_square <= s00a;
						--sel_selected <='0';
						--color_index <= '0';
						--SelMode <= '0';
						--sel_x <= 0;
						--sel_y <= 0;
					when s00a =>
						st_square <= s00b;
						x_out <= X0+(SIZE*i); 
						y_out <= Y0+(SIZE*j);
						if ((X0+(SIZE*i) = sel_x) and (Y0+(SIZE*j) = sel_y) and (sel_selected='1')) then
							SelMode<='1';
							else SelMode<='0';
						end if;
						i <= i+1;
					
					when s00b =>
						if SelMode ='0' then
							if color_index = '0' then color_t <= WHITE; 
								else color_t <= GREEN; 
							end if;
						else 
							color_t <= BLUE;
							SelMode <='0';	
						end if;
						if i=0 then
							j <= j+1;
							color_index <= not color_index;
						end if;
						st_square <= s00c;
		
						
					when s00c =>
						
						if done = '1' then
							if (i=0 and j=0) then
								color_index <= not color_index; 
								if sel_selected = '1' then
									st_square <= s_select_a;
								else
									if s_new_game ='1' then st_square <= s_cursor_wait; 
									else st_square <= s_game_wait; end if; 
								end if;
							else 
							color_index <= not color_index;
							st_square <= s00a;
						end if;
						end if;
					
					when s_game_wait =>
						if new_game ='1' then
							s_new_game <='1'; 
							st_square <= s_cursor_wait; 
							end if;
						
					when s_cursor_wait =>
						if ((c_x /= t_x) or (c_y /= t_y)) then
							st_square <= s00a;
							c_x<= t_x; 
							c_y<= t_y;
						else  st_square <= s_cursor_a;
						end if;
						
					when s_cursor_a =>
						if (internal_sel = '1') then
							sel_x <= t_x;
							sel_y <= t_y;
							sel_selected <= not(sel_selected);
							st_square <= s00a;
						else
							color_t <= RED; 
							x_out <= c_x; y_out <= c_y;
							st_square <= s_cursor_b;
						end if;
			
					when s_cursor_b =>
						st_square <= s_cursor_c;
					when s_cursor_c =>
						if done = '1' then st_square <= s_cursor_wait; end if;	
						
					when s_select_a =>
						st_square <= s_select_b;
						x_out <= sel_x; y_out <= sel_y;
						color_t <= BLUE;

					when s_select_b =>
						st_square <= s_select_c;
					when s_select_c =>
						if done = '1' then st_square <= s_cursor_wait; end if;
			End Case;
		End If;
	End Process;
t_x <= x_in;
t_y <= y_in;
x_t <= x_out;
y_t <= y_out;
internal_sel <= sel;
--row <= i;
--column <= j;
Start <= '1' when st_square = s00b or st_square = s_cursor_b or st_square = s_select_b else '0';
               
End Functional;