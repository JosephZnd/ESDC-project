library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity kb_xy_module is
  port ( clk, nrst , freeze_kb  : in  std_logic;
		up_key, down_key, left_key, right_key	: in std_logic;
		pos_x	:	out integer range 0 to 7;
		pos_y	: 	out integer range 0 to 7;
		debounce : in  std_logic;
		code_read :  out std_logic);
		-- will add another flag later to set different first position depending on black or white
end kb_xy_module;

architecture main of kb_xy_module is
	signal y_int, x_int: integer range 0 to 7;
	constant X0 : integer := 11;
	constant Y0 : integer := 1;
	constant SIZE : integer :=14;
	type state_type is (s_up, s_down, s_right, s_left, s_end, s_wait);
	signal s_xy : state_type;

	
	
	--constant position_default	: unsigned(2 downto 0) := "100";	
begin

--fr <= '0'; --THIS IS FOR TEST, LATER USE FREEZE
ControlXY : process (clk, nrst, freeze_kb, x_int, y_int, debounce) 
	--variable x_cnt, y_cnt : unsigned(2 downto 0);
	begin
	if (nrst='0') then 
		x_int <= 4;
		y_int <= 4;
		s_xy <= s_wait;
	elsif rising_edge(clk) then -- and freeze_kb='0' 
		--if (debounce='1') then
		case s_xy is
			when s_wait =>
				if(up_key = '1'  and debounce='1') then 
						 s_xy <= s_up; end if;
				if(down_key= '1' and debounce='1') then
						 s_xy <= s_down; end if;
				if(left_key= '1' and debounce='1') then
						 s_xy <= s_left; end if;
				if(right_key= '1' and debounce='1') then
						 s_xy <= s_right; end if;
				if (debounce='1') then
					s_xy <= s_end; end if;
			when s_up =>
				y_int <= y_int-1;
				s_xy <= s_end;
			when s_down =>
				y_int <= y_int +1;
				s_xy <= s_end;

			when s_left =>
				x_int <= x_int -1;
				s_xy <= s_end;

			when s_right =>
				x_int <= x_int +1;
				s_xy <= s_end;
			when s_end =>
				s_xy <= s_wait;
			
		end case;
	end if;

end process;
pos_x <= x_int;
pos_y <= y_int;
code_read <= '1' when s_xy = s_end else '0';

end;
	