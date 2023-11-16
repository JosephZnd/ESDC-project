library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CLK_5HZ is
	Port (O:out std_logic;
	CLK,nrst:in std_logic);
end CLK_5HZ;

architecture Behavioral of CLK_5HZ is
	signal W:std_logic;
	signal count: integer :=0;
begin
	O <= W;
process(CLK,nrst) 
begin
	if (nrst = '0') then
		W<= '0';
		count <= 0;
		
	elsif CLK'EVENT and CLK='1' then
		count <= count + 1;
		if count=12500000-1 then --diveds the button read speed to 50hz
			W <= not W;
			count <= 0;
		end if;
	end if;	
end process;
end;