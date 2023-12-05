Library IEEE;
use IEEE.std_logic_1164.all;

entity BasePiece is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end entity;

architecture behavioral of BasePiece is
type PixelMap is array (0 to 9,0 to 9) of std_logic_vector(11 downto 0);
constant PieceImage:PixelMap :=
		(	(x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"000",x"000",x"000",x"000",x"000",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF",x"000",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"000",x"000",x"000",x"000",x"000",x"FFF",x"FFF",x"FFF"),
			(x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF",x"FFF"));
begin
	Red <=  PieceImage(ImageH,ImageV)(11 downto 8);
	Blue <=PieceImage(ImageH,ImageV)(7 downto 4);
	Green <= PieceImage(ImageH,ImageV)(3 downto 0);
end behavioral;