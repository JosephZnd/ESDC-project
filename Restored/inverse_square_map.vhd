library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity inverse_square_map is
  port( posx, posy  : out integer range 0 to 7;
		x_t				: in integer range 0 to 160;
		y_t				: in integer range 0 to 120);
end inverse_square_map;


architecture inv_functional of inverse_square_map is
  
  --signal y_int, x_int: integer range 0 to 7;

  -- Coordinates of the squares
  constant X0 : integer := 11;
  constant Y0 : integer := 1;
  constant SIZE : integer :=14;
  --signal s_addR	:	std_logic_vector(5 downto 0);
  
  Begin
	posx <= (x_t-X0)/(SIZE);
	posy <= (y_t-Y0)/(SIZE);

End Inv_functional;
