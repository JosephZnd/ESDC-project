library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_write is
    Port ( wen_game : in  STD_LOGIC;
           wen_main : in  STD_LOGIC;
           M : in  STD_LOGIC;
           O : out STD_LOGIC);

end mux_write;

architecture Behavioral of mux_write is

begin

process (wen_game, wen_main, M)

begin


	if (M <= '0') then
		O <= wen_game;
	elsif (M <= '1') then
		O <= wen_main;
	end if;

end process;

end Behavioral;
