library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGACLK is
	port(	O:out std_logic;
			CLK,Reset:in std_logic);
end entity;

architecture Behavioral of VGACLK is
signal W:std_logic;
signal count: integer range 0 to 1 :=0;
begin
	O <= W;
	process(CLK,Reset) begin
		if (Reset = '1') then
			W<= '0';
			count <= 0;
		elsif rising_edge(CLK) then
			if count >= 1 then--Nexys Base Clock is 100mHz => 25mHz
				W <= not W;
				count <= 0;
			else
				count <= count + 1;
			end if;
		end if;	
	end process;
end Behavioral;

