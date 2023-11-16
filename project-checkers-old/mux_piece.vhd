library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_piece is
    Port ( piece_game : in  STD_LOGIC_VECTOR (2 downto 0);
           piece_rx : in  STD_LOGIC_VECTOR (2 downto 0);
           M : in  STD_LOGIC;
           O : out STD_LOGIC_VECTOR (2 downto 0));

end mux_piece;

architecture Behavioral of mux_piece is

begin

process (piece_game, piece_rx, M)

begin


	if (M <= '0') then
		O <= piece_game;
	elsif (M <= '1') then
		O <= piece_rx;
	end if;

end process;

end Behavioral;
