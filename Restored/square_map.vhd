
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity square_map is
  port( cursor_x, cursor_y   	 	: std_logic_vector (2 downto 0);
		x_t				: out integer range 0 to 160;
		y_t				: out integer range 0 to 120);
end square_map;


architecture functional of square_map is

	 
  
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
  
  signal c_x, c_y : integer range 0 to 7;

  
  Begin
	process(cursor_x, cursor_y)
	Begin
		if unsigned(cursor_y)=0 then
			y_t <= Y0;
		elsif unsigned(cursor_y)=1 then
			y_t <= Y1;
		elsif unsigned(cursor_y)=2 then
			y_t <= Y2;
		elsif unsigned(cursor_y)=3 then
			y_t <= Y3;
		elsif unsigned(cursor_y)=4 then
			y_t <= Y4;
		elsif unsigned(cursor_y)=5 then
			y_t <= Y5;
		elsif unsigned(cursor_y)=6 then
			y_t <= Y6;
		elsif unsigned(cursor_y)=7 then
			y_t <= Y7;		
		end if;
		
		if unsigned(cursor_y)=0 then
			y_t <= Y0;
		elsif unsigned(cursor_y)=1 then
			y_t <= Y1;
		elsif unsigned(cursor_y)=2 then
			y_t <= Y2;
		elsif unsigned(cursor_y)=3 then
			y_t <= Y3;
		elsif unsigned(cursor_y)=4 then
			y_t <= Y4;
		elsif unsigned(cursor_y)=5 then
			y_t <= Y5;
		elsif unsigned(cursor_y)=6 then
			y_t <= Y6;
		elsif unsigned(cursor_y)=7 then
			y_t <= Y7;		
		end if;				
	End Process;

End Functional;