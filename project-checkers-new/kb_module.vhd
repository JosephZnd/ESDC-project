library ieee;
use ieee.std_logic_1164.all;

entity kb_module is
  port ( clk, nrst   : in  std_logic;
		key	: in std_logic;  -- From the keytest.
		hash, w_sel, b_sel, up_key, down_key, left_key, right_key, select_key: out std_logic;  -- key identifier
		keycode_kt	 : in std_logic_vector(3 downto 0)); -- Keycode from keytest
end kb_module;

architecture main of kb_module is
	signal keycode_int : std_logic_vector(3 downto 0);  -- output of the register.
	signal nkey : std_logic; -- Signal to comment if keypad has nkey instead of key.
	
begin
nkey <= not (key);

REG_KEY : process (clk, nrst) begin
	if nrst = '0' then
		keycode_int <= x"0";
	elsif rising_edge(clk) then
		if nkey = '0' then
			keycode_int <= keycode_kt;
		end if;
	end if;
end process;
 

-- Type of key pressed by the user. This can be changed depending on the keypad.
hash <= '1' when (keycode_int = x"F" and key='1') else '0';
w_sel <= '1' when (keycode_int = x"1" and key='1') else '0';
b_sel <= '1' when (keycode_int = x"7" and key='1') else '0';

up_key <= '1' when (keycode_int = x"2"  and key='1') else '0';
left_key <='1' when (keycode_int = x"4"  and key='1') else '0';
down_key <= '1' when (keycode_int = x"8"  and key='1') else '0';
right_key <= '1' when (keycode_int = x"6"  and key='1') else '0';
select_key <= '1' when (keycode_int = x"5"  and key='1') else '0';
-- UPdating the output keycode and new_code



end;

