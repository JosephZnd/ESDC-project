library ieee;
use ieee.std_logic_1164.all;

entity count4b is
  port ( clk, nclr : in  std_logic;
    output    : out integer range 0 to 15);
end count4b;

architecture arc_count4b of count4b is
  signal count : integer range 0 to 15;
begin

  process (clk, nclr)
  begin
    if nclr = '0' then
      count <= 0;
    elsif clk'event and clk = '1' then
      count <= count + 1;
    end if;
  end process;

  output <= count;
  
end arc_count4b;
