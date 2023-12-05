Library IEEE;
use IEEE.std_logic_1164.all;

entity PxToImagePx is
	port(	ImageX,ImageY:out integer range 0 to 9;
			GridX,GridY:in integer range 0 to 7;
			Hpx:in integer range 0 to 640;
			Vpx:in integer range 0 to 480);
	end entity;

architecture Behavoiral of PxToImagePx is

begin
ImageX <= (Hpx-(60*GridX+90))/4;
ImageY <= (Vpx-(60*GridY+10))/4;

end Behavoiral;