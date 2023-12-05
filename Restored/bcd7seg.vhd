library work;
library ieee;
use ieee.std_logic_1164.all;

entity BCD7seg is 
   port( num : in std_logic_vector (3 downto 0);
        HEX  : out std_logic_vector (6 downto 0)
         );
end BCD7seg;

architecture behaviour of BCD7seg is
   
begin

        HEX(6 downto 0) <=  "1000000" when num(3 downto 0) = x"0" else
							 "1111001" when num(3 downto 0) = x"1" else
							 "0100100" when num(3 downto 0) = x"2" else
							 "0110000" when num(3 downto 0) = x"3" else
							 "0011001" when num(3 downto 0) = x"4" else
							 "0010010" when num(3 downto 0) = x"5" else
							 "0000010" when num(3 downto 0) = x"6" else
							 "1111000" when num(3 downto 0) = x"7" else
							 "0000000" when num(3 downto 0) = x"8" else
							 "0010000" when num(3 downto 0) = x"9" else
							 "1111111";
	
						 
end behaviour;
