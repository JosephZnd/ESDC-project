library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Graphics is
	port(	Red,Blue,Green: out std_logic_vector(3 downto 0);
			GridX,GridY:out integer range 0 to 7;
			Hpx:in integer range 0 to 640;
			Vpx:in integer range 0 to 480;
			VidOn,SelMode:in std_logic;
			SelX,SelY,OldSelX,OldSelY:in integer range 0 to 7;
			Piece:in integer range 0 to 15
			);
	end entity;

architecture Behavioral of Graphics is

component GraphicPieceSet is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9;
			Piece:in integer range 0 to 15
			);
	end component;
component PxToGrid is
	port(	GridX,GridY:out integer range 0 to 7;
			Hpx:in integer range 0 to 640;
			Vpx:in integer range 0 to 480);
	end component;
component PxToImagePx is
	port(	ImageX,ImageY:out integer range 0 to 9;
			GridX,GridY:in integer range 0 to 7;
			Hpx:in integer range 0 to 640;
			Vpx:in integer range 0 to 480);
	end component;
	
signal BoardGridX,BoardGridY:integer range 0 to 7;
signal RedI,BlueI,GreenI:std_logic_vector(3 downto 0);
signal PImageX,PImageY:integer range 0 to 9;
begin

C0: PxToGrid			port map(BoardGridX,BoardGridY,Hpx,Vpx);					--Takes raw pixels and conveters to the grid,8x8
C1: PxToImagePx		port map(PImageX,PImageY,BoardGridX,BoardGridY,Hpx,Vpx);--takes raw pixels and returns the value for the images.
C2: GraphicPieceSet	port map(RedI,BlueI,GreenI,PImageY,PImageX,Piece);		--returns the pixels for the corresponding piece

GridX <= BoardGridX; --used for getting the piece number
GridY <= BoardGridY;

process(Vidon,Hpx,Vpx,RedI,BlueI,GreenI,SelX,SelY,OldSelX,OldSelY,SelMode,Piece)begin
	if(Vidon = '1') then
		if(Hpx < 80 or Hpx > 559) then --purple border
				Red <= "1100";				
				Blue <= "1110";
				Green <= "0011";
		elsif(Hpx = 80 or Hpx = 139 or Hpx = 140 or Hpx = 199 or Hpx = 200 or Hpx = 259 --white boarder for the board
			or Hpx = 260 or Hpx = 319 or Hpx = 320 or Hpx = 379 or Hpx = 380 or Hpx = 439
			or Hpx = 440 or Hpx = 499 or Hpx = 500 or Hpx = 559
			or Vpx = 0 or Vpx = 59 or Vpx = 60 or Vpx = 119 or Vpx = 120 or Vpx = 179 
			or Vpx = 180 or Vpx = 239 or Vpx = 240 or Vpx = 299 or Vpx = 300 or Vpx = 359
			or Vpx = 360 or Vpx = 419 or Vpx = 420 or Vpx = 479) then
				Red <= "1111";
				Blue <= "1111";
				Green <= "1111";
		elsif((Piece /= 7) and 
						((Hpx > 89 and Hpx < 130) or (Hpx > 149 and Hpx < 190) or (Hpx > 209 and Hpx < 250)
					or (Hpx > 269 and Hpx < 310) or (Hpx > 329 and Hpx < 370) or (Hpx > 389 and Hpx < 430)
					or (Hpx > 449 and Hpx < 490) or (Hpx > 509 and Hpx < 550)) 
					and((Vpx > 9 and Vpx < 50) or (Vpx > 69 and Vpx < 110) or (Vpx > 129 and Vpx < 170) 
					or (Vpx > 189 and Vpx < 230) or (Vpx > 249 and Vpx < 290) or (Vpx > 309 and Vpx < 350)
					or (Vpx > 369 and Vpx < 410) or (Vpx > 429 and Vpx < 470)))
					then--Condition for being inside the game icon and value is not 7, 7 is no piece)
				Red <= RedI;
				Blue <= BlueI;
				Green <= GreenI;
		elsif(Hpx > (80+SelX*60) and Hpx <(80+(SelX+1)*60) and Vpx > (SelY*60) and Vpx < ((SelY+1)*60)) then
				-- Cursor is Orange
				Red <= "1111";
				Blue <= "0000";
				Green <= "1000";
		elsif((Hpx > (80+OldSelX*60) and Hpx <(80+(OldSelX+1)*60) and Vpx > (OldSelY*60) and Vpx < ((OldSelY+1)*60)) and 
					SelMode = '1') then
				-- Previous is cyan
				Red <= "0000";
				Blue <= "1111";
				Green <= "1100";					
		elsif((((Hpx-80) mod 120 < 60) and (Vpx mod 120 < 60)) or
				(((Hpx-80) mod 120 >= 60) and (Vpx mod 120 >= 60)))then --red squares
				Red <= "1111";
				Blue <= "0000";
				Green <= "0000";
		else																		 -- black squares
				Red <= "0000";
				Blue <= "0000";
				Green <= "0000";
		end if;
	else											-- Black when not displaying
		Red <= "0000";
		Blue <= "0000";
		Green <= "0000";
	end if;
end process;
end Behavioral;

