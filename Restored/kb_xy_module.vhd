library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity kb_xy_module is
  port ( clk, nrst , freeze_kb  : in  std_logic;
		up_key, down_key, left_key, right_key	: in std_logic;
		pos_x	:	out integer range 0 to 160;
		pos_y	: 	out integer range 0 to 120;
		debounce : in  std_logic);
		-- will add another flag later to set different first position depending on black or white
end kb_xy_module;

architecture main of kb_xy_module is
	signal y_int, x_int: integer range 0 to 7;
	constant X0 : integer := 11;
	constant Y0 : integer := 1;
	constant SIZE : integer :=14;
	--constant position_default	: unsigned(2 downto 0) := "100";	
begin

--fr <= '0'; --THIS IS FOR TEST, LATER USE FREEZE
ControlXY : process (clk, nrst, freeze_kb) 
	--variable x_cnt, y_cnt : unsigned(2 downto 0);
	begin
	if (nrst='0') then 
		x_int <= 4;
		y_int <= 4;
	elsif rising_edge(clk) then -- and freeze_kb='0' 
		if (debounce='1') then
			if(up_key = '1') then
			
			--y_cnt := y_cnt-1;
			y_int <= y_int -1;
			--y_int <= std_logic_vector(y_cnt);
			end if;
			if(down_key= '1') then
			--y_cnt := y_cnt+1;
			--y_int <= std_logic_vector(y_cnt);
				y_int <= y_int +1;
			end if;

			if(left_key= '1') then
			--x_cnt := x_cnt-1;
			--x_int <= std_logic_vector(x_cnt);
				x_int <= x_int -1;
			end if;

			if(right_key= '1') then
				x_int <= x_int +1;

			--x_cnt := x_cnt+1;
			--x_int <= std_logic_vector(x_cnt);
			end if;
		else 
			x_int <= x_int;
			y_int <= y_int;
		end if;
	end if;
end process;

pos_x <= (x_int*SIZE)+X0;
pos_y <= (y_int*SIZE)+Y0;


end;
	