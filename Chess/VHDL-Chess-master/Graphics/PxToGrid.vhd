Library IEEE;
use IEEE.std_logic_1164.all;

entity PxToGrid is
	port(	GridX,GridY:out integer range 0 to 7;
			Hpx:in integer range 0 to 640;
			Vpx:in integer range 0 to 480);
	end entity;

architecture Behavoiral of PxToGrid is

begin
GridX <= (Hpx-80)/60;
GridY <= Vpx/60;

end Behavoiral;