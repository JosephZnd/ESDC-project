library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA_Driver is
	port(	Hsync,Vsync,VidOn:out std_logic;
			Hpx:out integer range 0 to 640;
			Vpx:out integer range 0 to 480;
			CLK,Clear:in std_logic);
	end entity;

architecture Behavioral of VGA_Driver is
Component VGA_640x480 is
	port(	Hsync,Vsync,VidOn:out std_logic;
			Hpx:out integer range 0 to 640;
			Vpx:out integer range 0 to 480;
			CLK,Clear:in std_logic);
	end component;
Component VGACLK is
	port(	O:out std_logic;
			CLK,Reset:in std_logic);
	end component;

signal DivCLK: std_logic;
begin

VC0: VGACLK port map(DivCLK,CLK,Clear);
VC1: VGA_640x480 port map(Hsync,Vsync,Vidon,Hpx,Vpx,DivCLK,Clear);

end Behavioral;

