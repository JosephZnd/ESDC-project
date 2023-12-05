-- HEX to 7S displays routing module for the DE2 board
-- version DD-1.0 - march 2011

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;

entity hex_disps is
  port ( num0, num1, num2, num3, num4, num5, num6, num7 : in std_logic_vector (3 downto 0);
         HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out std_logic_vector (6 downto 0));
end hex_disps ;

architecture struct of hex_disps is

  component BCD7seg
    port ( num  : in std_logic_vector (3 downto 0);
           HEX  : out std_logic_vector (6 downto 0));
  end component;

begin

 display0: BCD7seg
   port map(num0,HEX0);
 display1: BCD7seg
   port map(num1,HEX1);
 display2: BCD7seg
   port map(num2,HEX2);
 display3: BCD7seg
   port map(num3,HEX3);
 display4: BCD7seg
   port map(num4,HEX4);
 display5: BCD7seg
   port map(num5,HEX5);
 display6: BCD7seg
   port map(num6,HEX6);
 display7: BCD7seg
   port map(num7,HEX7); 

end struct;
