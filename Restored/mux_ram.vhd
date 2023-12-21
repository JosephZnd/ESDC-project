library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_ram is
    Port ( port1 : in  STD_LOGIC_vector(5 downto 0);
           port2 : in  STD_LOGIC_vector(5 downto 0);
           M : in  STD_LOGIC;
           O : out STD_LOGIC_vector(5 downto 0));

end mux_ram;

architecture Behavioral of mux_ram is

begin

process (port1, port2, M)

begin


	if (M <= '0') then
		O <= port1;
	elsif (M <= '1') then
		O <= port2;
	end if;

end process;

end Behavioral;
