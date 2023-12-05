library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GameTop is
	port(	Red,Blue,Green: out std_logic_vector(3 downto 0);
			Hsync,Vsync:out std_logic;
			CLK,Clear,Upb,Downb,Leftb,Rightb,Sel:in std_logic
			);
end entity;

architecture Behavioral of GameTop is

component Graphics is
	port(	Red,Blue,Green: out std_logic_vector(3 downto 0);
			GridX,GridY:out integer range 0 to 7;
			Hpx:in integer range 0 to 640;
			Vpx:in integer range 0 to 480;
			VidOn,SelMode:in std_logic;
			SelX,SelY,OldSelX,OldSelY:in integer range 0 to 7;
			Piece:in integer range 0 to 15);
	end component;
component VGA_Driver is
	port(	Hsync,Vsync,VidOn:out std_logic;
			Hpx:out integer range 0 to 640;
			Vpx:out integer range 0 to 480;
			CLK,Clear:in std_logic);
	end component;
component GameLogic is
	port(	SelX,SelY,OldSelX,OldSelY:out integer range 0 to 7;
			SelMode:out std_logic;
			Piece:out integer range 0 to 15;
			GridX,GridY:in integer range 0 to 7;
			Upb,Downb,Leftb,Rightb,Sel,CLK,Reset: in std_logic);
	end component;
	
signal Hpx:integer range 0 to 640;
signal Vpx:integer range 0 to 480;
signal VidOn,SelectMode: std_logic;
signal SelectX,SelectY,OldSelectX,OldSelectY:integer range 0 to 7;
signal PieceId:integer range 0 to 15;
signal PixelGridX,PixelGridY:integer range 0 to 7;
begin
C0:VGA_Driver	port map(Hsync,Vsync,Vidon,Hpx,Vpx,CLK,Clear);
C1:Graphics		port map(Red,Blue,Green,PixelGridX,PixelGridY,Hpx,Vpx,Vidon,SelectMode,SelectX,SelectY,OldSelectX,OldSelectY,PieceId);
C2:GameLogic	port map(SelectX,SelectY,OldSelectX,OldSelectY,SelectMode,PieceId,PixelGridX,PixelGridY,Upb,Downb,Leftb,Rightb,Sel,CLK,Clear);
end Behavioral;

