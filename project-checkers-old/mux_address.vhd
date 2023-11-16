library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_address is
    Port ( add_game : in  STD_LOGIC_VECTOR (5 downto 0);
           add_rx : in  STD_LOGIC_VECTOR (5 downto 0);
           M : in  STD_LOGIC;
           O : out STD_LOGIC_VECTOR (5 downto 0));

end mux_address;

architecture Behavioral of mux_address is

begin

process (add_game, add_rx, M)

begin


	if (M <= '0') then
		O <= add_game;
	elsif (M <= '1') then
		O <= add_rx;
	end if;

end process;

end Behavioral;
