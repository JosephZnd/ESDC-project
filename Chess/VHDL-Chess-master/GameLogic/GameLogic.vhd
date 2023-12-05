Library IEEE;
use IEEE.std_logic_1164.all;

entity GameLogic is
	port(	SelX,SelY,OldSelX,OldSelY:out integer range 0 to 7;
			SelMode: out std_logic;
			Piece:out integer range 0 to 15;
			GridX,GridY:in integer range 0 to 7;
			Upb,Downb,Leftb,Rightb,Sel,CLK,Reset: in std_logic);
	end entity;

architecture Behavioral of GameLogic is

component MoveCLK is
	Port (	O:out std_logic;
			CLK,Clear:in std_logic);
	end component;

type GameGrid is array(0 to 7, 0 to 7) of integer range 0 to 15;
signal Board: GameGrid;
signal SelectMode:std_logic;
signal SelectX,SelectY,OldSelectX,OldSelectY:integer range 0 to 7;
signal TempPiece: integer range 0 to 15;
signal MCLK:std_logic;

begin

SelX <= SelectX;
SelY <= SelectY;
OldSelX <= OldSelectX;
OldSelY <= OldSelectY;
Piece <= Board(GridY,GridX);
SelMode <= SelectMode;
C0: MoveCLK port map(MCLK,CLK,Reset);

Process(MCLK)begin
	if(rising_edge(MCLK)) then
		if(Upb = '1') then
			SelectY <= SelectY - 1;
		elsif(Downb = '1') then
			SelectY <= SelectY + 1;
		elsif(Leftb = '1') then
			SelectX <= SelectX - 1;
		elsif(Rightb = '1') then
			SelectX <= SelectX + 1;
		else
			SelectX <= SelectX;
			SelectY <= SelectY;
		end if;
	end if;
end process;

process(SelectX,SelectY,Sel,Board,TempPiece,reset,MCLK)
variable Distance: integer range 0 to 7;
begin
	if reset = '1' then
		Board <= ((5,2,0,1,4,0,2,5),
					(3,3,3,3,3,3,3,3),
					(7,7,7,7,7,7,7,7),
					(7,7,7,7,7,7,7,7),
					(7,7,7,7,7,7,7,7),
					(7,7,7,7,7,7,7,7),
					(13,13,13,13,13,13,13,13),
					(15,12,10,11,14,10,12,15));
		SelectMode <= '0';
	elsif(rising_edge(Sel))then
		if(SelectMode = '0') then
			TempPiece <= Board(SelectY,SelectX);
			OldSelectY <= SelectY;
			OldSelectX <= SelectX;
			Board(SelectY,SelectX) <= 7;
			SelectMode <= '1';
		else--Throw case into here for all piece placement
			if(TempPiece = 7) then --prevents deleting pieces. no cheating
					SelectMode <= '0';
			elsif(SelectX = OldSelectX and SelectY = OldSelectY) then --used for placing a piece back to where it came.
					Board(SelectY,SelectX) <= TempPiece;
					SelectMode <= '0';
					TempPiece <= 7;
			--White Bishop
			elsif(TempPiece = 0) then
				if(((OldSelectY - SelectY) = (SelectX - OldSelectX)) and SelectY < OldSelectY and SelectX > OldSelectX) then --Quad1
					Distance :=  OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((OldSelectY - SelectY) = (OldSelectX - SelectX)) and SelectY < OldSelectY and SelectX < OldSelectX) then --Quad2
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (OldSelectX - SelectX)) and SelectY > OldSelectY and SelectX < OldSelectX) then --Quad3
					Distance := SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (SelectX - OldSelectX)) and SelectY > OldSelectY and SelectX > OldSelectX) then --Quad4
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				end if;
			--End White Bishop
			--White King
			elsif(TempPiece = 1) then
				if((Board(OldSelectY+1,OldSelectX+1) > 6 and SelectX=OldSelectX+1 and SelectY = OldSelectY+1) or
					(Board(OldSelectY+1,OldSelectX)> 6 and SelectX=OldSelectX and SelectY = OldSelectY+1) or
					(Board(OldSelectY+1,OldSelectX-1) > 6 and SelectX=OldSelectX-1 and SelectY = OldSelectY+1) or
					(Board(OldSelectY,OldSelectX+1) > 6 and SelectX=OldSelectX+1 and SelectY = OldSelectY) or
					(Board(OldSelectY,OldSelectX) > 6 and SelectX=OldSelectX and SelectY = OldSelectY) or
					(Board(OldSelectY,OldSelectX-1) > 6 and SelectX=OldSelectX-1 and SelectY = OldSelectY) or
					(Board(OldSelectY-1,OldSelectX+1) > 6 and SelectX=OldSelectX+1 and SelectY = OldSelectY-1) or
					(Board(OldSelectY-1,OldSelectX) > 6 and SelectX=OldSelectX and SelectY = OldSelectY-1) or
					(Board(OldSelectY-1,OldSelectX-1) > 6 and SelectX=OldSelectX-1 and SelectY = OldSelectY-1)) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				end if;
			--End White King
			--White Knight
			elsif(TempPiece = 2) then
				if((Board(OldSelectY+2,OldSelectX+1) > 6 and SelectX=OldSelectX+1 and SelectY = OldSelectY+2) or
					(Board(OldSelectY+2,OldSelectX-1) > 6 and SelectX=OldSelectX-1 and SelectY = OldSelectY+2) or
					(Board(OldSelectY+1,OldSelectX+2) > 6 and SelectX=OldSelectX+2 and SelectY = OldSelectY+1) or
					(Board(OldSelectY+1,OldSelectX-2) > 6 and SelectX=OldSelectX-2 and SelectY = OldSelectY+1) or
					(Board(OldSelectY-1,OldSelectX+2) > 6 and SelectX=OldSelectX+2 and SelectY = OldSelectY-1) or
					(Board(OldSelectY-1,OldSelectX-2) > 6 and SelectX=OldSelectX-2 and SelectY = OldSelectY-1) or
					(Board(OldSelectY-2,OldSelectX+1) > 6 and SelectX=OldSelectX+1 and SelectY = OldSelectY-2) or
					(Board(OldSelectY-2,OldSelectX-1) > 6 and SelectX=OldSelectX-1 and SelectY = OldSelectY-2)) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				end if;
			--End White Khight
			--White Pawn
			elsif(TempPiece = 3) then
				if((Board(OldSelectY+1,OldSelectX+1) > 9 and SelectX=OldSelectX+1 and SelectY = OldSelectY+1) or
					(Board(OldSelectY+1,OldSelectX-1) > 9 and SelectX=OldSelectX-1 and SelectY = OldSelectY+1)) then
							if(SelectY = 7) then
								Board(SelectY,SelectX) <= 4;
							else
								Board(SelectY,SelectX) <= TempPiece;
							end if;
							SelectMode <= '0';
							TempPiece <= 7;
				elsif(SelectX = OldSelectX and Board(OldSelectY+1,OldSelectX) = 7 and SelectY = OldSelectY+1) then
							if(SelectY = 7) then
								Board(SelectY,SelectX) <= 4;
							else
								Board(SelectY,SelectX) <= TempPiece;
							end if;
							SelectMode <= '0';
							TempPiece <= 7;
				elsif(SelectX = OldSelectX and Board(OldSelectY+1,OldSelectX) = 7 and Board(OldSelectY+2,OldSelectX) = 7 and SelectY = OldSelectY+2 and OldSelectY = 1) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				elsif(SelectX = OldSelectX and SelectY = OldSelectY) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				end if;
			--End White Pawn
			--White Queen
			elsif(TempPiece = 4) then
				if((OldSelectX = SelectX) and OldSelectY > SelectY) then --UP
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,SelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectX = SelectX) and OldSelectY < SelectY) then --Down
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX > SelectX) then --left
					Distance :=  OldSelectX - SelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX < SelectX) then --right
					Distance := SelectX - OldSelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((OldSelectY - SelectY) = (SelectX - OldSelectX)) and SelectY < OldSelectY and SelectX > OldSelectX) then --Quad1
					Distance :=  OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((OldSelectY - SelectY) = (OldSelectX - SelectX)) and SelectY < OldSelectY and SelectX < OldSelectX) then --Quad2
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (OldSelectX - SelectX)) and SelectY > OldSelectY and SelectX < OldSelectX) then --Quad3
					Distance := SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (SelectX - OldSelectX)) and SelectY > OldSelectY and SelectX > OldSelectX) then --Quad4
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				end if;
			--End White Queen
			
			--White Rook
			elsif(TempPiece = 5) then
				if((OldSelectX = SelectX) and OldSelectY > SelectY) then --UP
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,SelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectX = SelectX) and OldSelectY < SelectY) then --Down
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX > SelectX) then --left
					Distance :=  OldSelectX - SelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX < SelectX) then --right
					Distance := SelectX - OldSelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) > 6) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				end if;
			--End White Rook
			
			--Black Bishop
			elsif(TempPiece = 10) then
				if(((OldSelectY - SelectY) = (SelectX - OldSelectX)) and SelectY < OldSelectY and SelectX > OldSelectX) then --Quad1
					Distance :=  OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((OldSelectY - SelectY) = (OldSelectX - SelectX)) and SelectY < OldSelectY and SelectX < OldSelectX) then --Quad2
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (OldSelectX - SelectX)) and SelectY > OldSelectY and SelectX < OldSelectX) then --Quad3
					Distance := SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (SelectX - OldSelectX)) and SelectY > OldSelectY and SelectX > OldSelectX) then --Quad4
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				end if;
			--End Black Bishop
			--Black King
			elsif(TempPiece = 11) then
				if((Board(OldSelectY+1,OldSelectX+1) < 8 and SelectX=OldSelectX+1 and SelectY = OldSelectY+1) or
					(Board(OldSelectY+1,OldSelectX) < 8 and SelectX=OldSelectX and SelectY = OldSelectY+1) or
					(Board(OldSelectY+1,OldSelectX-1) < 8 and SelectX=OldSelectX-1 and SelectY = OldSelectY+1) or
					(Board(OldSelectY,OldSelectX+1) < 8 and SelectX=OldSelectX+1 and SelectY = OldSelectY) or
					(Board(OldSelectY,OldSelectX) < 8 and SelectX=OldSelectX and SelectY = OldSelectY) or
					(Board(OldSelectY,OldSelectX-1) < 8 and SelectX=OldSelectX-1 and SelectY = OldSelectY) or
					(Board(OldSelectY-1,OldSelectX+1) < 8 and SelectX=OldSelectX+1 and SelectY = OldSelectY-1) or
					(Board(OldSelectY-1,OldSelectX) < 8 and SelectX=OldSelectX and SelectY = OldSelectY-1) or
					(Board(OldSelectY-1,OldSelectX-1) < 8 and SelectX=OldSelectX-1 and SelectY = OldSelectY-1)) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				end if;
			--End Black King
			--Black Knight
			elsif(TempPiece = 12) then
				if((Board(OldSelectY+2,OldSelectX+1) < 8 and SelectX=OldSelectX+1 and SelectY = OldSelectY+2) or
					(Board(OldSelectY+2,OldSelectX-1) < 8 and SelectX=OldSelectX-1 and SelectY = OldSelectY+2) or
					(Board(OldSelectY+1,OldSelectX+2) < 8 and SelectX=OldSelectX+2 and SelectY = OldSelectY+1) or
					(Board(OldSelectY+1,OldSelectX-2) < 8 and SelectX=OldSelectX-2 and SelectY = OldSelectY+1) or
					(Board(OldSelectY-1,OldSelectX+2) < 8 and SelectX=OldSelectX+2 and SelectY = OldSelectY-1) or
					(Board(OldSelectY-1,OldSelectX-2) < 8 and SelectX=OldSelectX-2 and SelectY = OldSelectY-1) or
					(Board(OldSelectY-2,OldSelectX+1) < 8 and SelectX=OldSelectX+1 and SelectY = OldSelectY-2) or
					(Board(OldSelectY-2,OldSelectX-1) < 8 and SelectX=OldSelectX-1 and SelectY = OldSelectY-2)) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				end if;
			--End Black Khight
			--Black Pawn
			elsif(TempPiece = 13) then
				if((Board(OldSelectY-1,OldSelectX+1) < 6 and SelectX=OldSelectX+1 and SelectY = OldSelectY-1) or
					(Board(OldSelectY-1,OldSelectX-1) < 6 and SelectX=OldSelectX-1 and SelectY = OldSelectY-1)) then
							if(SelectY = 0) then
								Board(SelectY,SelectX) <= 14;
							else
								Board(SelectY,SelectX) <= TempPiece;
							end if;
							SelectMode <= '0';
							TempPiece <= 7;
				elsif(SelectX = OldSelectX and Board(OldSelectY-1,OldSelectX) = 7 and SelectY = OldSelectY-1) then
							if(SelectY = 0) then
								Board(SelectY,SelectX) <= 14;
							else
								Board(SelectY,SelectX) <= TempPiece;
							end if;
							SelectMode <= '0';
							TempPiece <= 7;
				elsif(SelectX = OldSelectX and Board(OldSelectY-1,OldSelectX) = 7 and Board(OldSelectY-2,OldSelectX) = 7 and SelectY = OldSelectY-2 and OldSelectY = 6) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				elsif(SelectX = OldSelectX and SelectY = OldSelectY) then
							Board(SelectY,SelectX) <= TempPiece;
							SelectMode <= '0';
							TempPiece <= 7;
				end if;
			--End Black Pawn
			--Black Queen
			elsif(TempPiece = 14) then
				if((OldSelectX = SelectX) and OldSelectY > SelectY) then --UP
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,SelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectX = SelectX) and OldSelectY < SelectY) then --Down
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX > SelectX) then --left
					Distance :=  OldSelectX - SelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX < SelectX) then --right
					Distance := SelectX - OldSelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((OldSelectY - SelectY) = (SelectX - OldSelectX)) and SelectY < OldSelectY and SelectX > OldSelectX) then --Quad1
					Distance :=  OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((OldSelectY - SelectY) = (OldSelectX - SelectX)) and SelectY < OldSelectY and SelectX < OldSelectX) then --Quad2
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (OldSelectX - SelectX)) and SelectY > OldSelectY and SelectX < OldSelectX) then --Quad3
					Distance := SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif(((SelectY - OldSelectY) = (SelectX - OldSelectX)) and SelectY > OldSelectY and SelectX > OldSelectX) then --Quad4
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				end if;
			--End Black Queen
			--Black Rook
			elsif(TempPiece = 15) then
				if((OldSelectX = SelectX) and OldSelectY > SelectY) then --UP
					Distance := OldSelectY - SelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY-i,SelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectX = SelectX) and OldSelectY < SelectY) then --Down
					Distance :=  SelectY - OldSelectY;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY+i,OldSelectX) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX > SelectX) then --left
					Distance :=  OldSelectX - SelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX-i) /= 7) then
								exit;
							end if;
					end loop;
				elsif((OldSelectY = SelectY) and OldSelectX < SelectX) then --right
					Distance := SelectX - OldSelectX;
					for i in 1 to 7 loop
							if(i = Distance) then
								if(Board(SelectY,SelectX) < 8) then
									Board(SelectY,SelectX) <= TempPiece;
									SelectMode <= '0';
									TempPiece <= 7;
								end if;
								exit;
							elsif(Board(OldSelectY,OldSelectX+i) /= 7) then
								exit;
							end if;
					end loop;
				end if;
			--End Black Rook
			else
					Board(SelectY,SelectX) <= TempPiece;
					SelectMode <= '0';
					TempPiece <= 7;
			end if;
		end if;
	end if;
end process;
end Behavioral;