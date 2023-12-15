
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity square_map is
  port( cursor_x, cursor_y  : in integer range 0 to 7;
		x_t				: out integer range 0 to 160;
		y_t				: out integer range 0 to 120);
end square_map;


architecture functional of square_map is
  
  --signal y_int, x_int: integer range 0 to 7;

  -- Coordinates of the squares
  constant X0 : integer := 11;
  constant Y0 : integer := 1;
  constant SIZE : integer :=14;
  
  Begin
	x_t <= (cursor_x*SIZE)+X0;
	y_t <= (cursor_y*SIZE)+Y0;
End Functional;