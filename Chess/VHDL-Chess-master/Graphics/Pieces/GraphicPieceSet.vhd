library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GraphicPieceSet is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9;
			Piece:in integer range 0 to 15
			);
end entity;

architecture Behavioral of GraphicPieceSet is
component BBishop is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component BKing is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component BKnight is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component BPawn is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component BQueen is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component BRook is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
	
component GBishop is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component GKing is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component GKnight is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component GPawn is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component GQueen is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;
component GRook is
	port(	Red,Blue,Green:out std_logic_vector(3 downto 0);
			ImageH,ImageV:in integer range 0 to 9);
	end component;

signal RedBB,BlueBB,GreenBB:std_logic_vector(3 downto 0);
signal RedBK,BlueBK,GreenBK:std_logic_vector(3 downto 0);
signal RedBN,BlueBN,GreenBN:std_logic_vector(3 downto 0);
signal RedBP,BlueBP,GreenBP:std_logic_vector(3 downto 0);
signal RedBQ,BlueBQ,GreenBQ:std_logic_vector(3 downto 0);
signal RedBR,BlueBR,GreenBR:std_logic_vector(3 downto 0);

signal RedGB,BlueGB,GreenGB:std_logic_vector(3 downto 0);
signal RedGK,BlueGK,GreenGK:std_logic_vector(3 downto 0);
signal RedGN,BlueGN,GreenGN:std_logic_vector(3 downto 0);
signal RedGP,BlueGP,GreenGP:std_logic_vector(3 downto 0);
signal RedGQ,BlueGQ,GreenGQ:std_logic_vector(3 downto 0);
signal RedGR,BlueGR,GreenGR:std_logic_vector(3 downto 0);

begin
B0: BBishop	port map(RedBB,BlueBB,GreenBB,ImageH,ImageV);
B1: BKing	port map(RedBK,BlueBK,GreenBK,ImageH,ImageV);
B2: BKnight	port map(RedBN,BlueBN,GreenBN,ImageH,ImageV);
B3: BPawn	port map(RedBP,BlueBP,GreenBP,ImageH,ImageV);
B4: BQueen	port map(RedBQ,BlueBQ,GreenBQ,ImageH,ImageV);
B5: BRook	port map(RedBR,BlueBR,GreenBR,ImageH,ImageV);

G0: GBishop	port map(RedGB,BlueGB,GreenGB,ImageH,ImageV);
G1: GKing	port map(RedGK,BlueGK,GreenGK,ImageH,ImageV);
G2: GKnight	port map(RedGN,BlueGN,GreenGN,ImageH,ImageV);
G3: GPawn	port map(RedGP,BlueGP,GreenGP,ImageH,ImageV);
G4: GQueen	port map(RedGQ,BlueGQ,GreenGQ,ImageH,ImageV);
G5: GRook	port map(RedGR,BlueGR,GreenGR,ImageH,ImageV);

process(	ImageH,ImageV,Piece,
			RedBB,BlueBB,GreenBB,RedBK,BlueBK,GreenBK,RedBN,BlueBN,GreenBN,
			RedBP,BlueBP,GreenBP,RedBQ,BlueBQ,GreenBQ,RedBR,BlueBR,GreenBR,
			RedGB,BlueGB,GreenGB,RedGK,BlueGK,GreenGK,RedGN,BlueGN,GreenGN,
			RedGP,BlueGP,GreenGP,RedGQ,BlueGQ,GreenGQ,RedGR,BlueGR,GreenGR)begin
	
	case(Piece) is
		when 0 =>
			Red<=RedBB;
			Green<=GreenBB;
			Blue<=BlueBB;
		when 1 =>
			Red<=RedBK;
			Green<=GreenBK;
			Blue<=BlueBK;
		when 2 =>
			Red<=RedBN;
			Green<=GreenBN;
			Blue<=BlueBN;
		when 3 =>
			Red<=RedBP;
			Green<=GreenBP;
			Blue<=BlueBP;
		when 4 =>
			Red<=RedBQ;
			Green<=GreenBQ;
			Blue<=BlueBQ;
		when 5 =>
			Red<=RedBR;
			Green<=GreenBR;
			Blue<=BlueBR;
		when 10 =>
			Red<=RedGB;
			Green<=GreenGB;
			Blue<=BlueGB;
		when 11 =>
			Red<=RedGK;
			Green<=GreenGK;
			Blue<=BlueGK;
		when 12 =>
			Red<=RedGN;
			Green<=GreenGN;
			Blue<=BlueGN;
		when 13 =>
			Red<=RedGP;
			Green<=GreenGP;
			Blue<=BlueGP;
		when 14 =>
			Red<=RedGQ;
			Green<=GreenGQ;
			Blue<=BlueGQ;
		when 15 =>
			Red<=RedGR;
			Green<=GreenGR;
			Blue<=BlueGR;
		when others =>	--bad piece/reserved is orange
			Red<="1100";
			Green<="1111";
			Blue<="0000";
	end case;
end process;
end Behavioral;
