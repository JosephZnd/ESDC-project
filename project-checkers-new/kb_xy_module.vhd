library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity kb_xy_module is
  port ( clk, nrst , freeze_kb  : in  std_logic;
		up_key, down_key, left_key, right_key	: in std_logic;
		pos_x, pos_y	: out std_logic_vector(2 downto 0));
		-- will add another flag later to set different first position depending on black or white
end kb_xy_module;

architecture main of kb_xy_module is
	signal y_int, x_int: std_logic_vector(2 downto 0);
	constant position_default	: unsigned(2 downto 0) := "100";	
begin


ControlXY : process (clk, nrst, freeze_kb) 
	variable x_cnt, y_cnt : unsigned(2 downto 0);
	begin
	if nrst = '0' then
		x_cnt :=position_default;
		y_cnt := position_default;
	elsif clk'EVENT and clk='1' and freeze_kb='0' then
	
		if(up_key = '1') then
			y_cnt := y_cnt-1;
			y_int <= std_logic_vector(y_cnt);
		end if;
		if(down_key = '1') then
			y_cnt := y_cnt+1;
			y_int <= std_logic_vector(y_cnt);
		end if;

		if(left_key = '1') then
			x_cnt := x_cnt-1;
			x_int <= std_logic_vector(x_cnt);
		end if;

		if(right_key = '1') then
			x_cnt := x_cnt+1;
			x_int <= std_logic_vector(x_cnt);
		end if;
	end if;
end process;

pos_x <= x_int;
pos_y <= y_int;

end;

	