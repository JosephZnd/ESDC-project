-- Frequency divider by M
-- D = output duty cycle in %
-- version DD-1.0 - march 2011

library ieee;
use ieee.std_logic_1164.all;

entity f_div is 
  port( nrst,clkin : in std_logic; 
        clkout : out std_logic );
end f_div;

architecture dni of f_div is
constant M : integer :=65536;
constant D : integer :=50;
constant n : integer :=D*M/100;
signal q : integer range 0 to M-1;
begin
  process(clkin,nrst) begin
     if nrst='0' then clkout <= '0'; q <= 0;
     elsif clkin'event and clkin='1' then 
         if q < M-1 then q <= q+1; 
            else q <= 0; end if;
         if q < n then clkout <= '1';
            else clkout <= '0'; end if;
     end if;
  end process;
end dni;
