library ieee;
use ieee.std_logic_1164.all;

entity keytest_h_v2 is
  port ( clk, nrst   : in  std_logic;
		key         : in std_logic;  -- From the keytest.
		bcd, ast, hash, A, B, C, D: out std_logic;  -- key identifier
		new_code	: out std_logic;  -- activated when there is a new code in the register.
		code_read	: in std_logic;  -- used to de-activate new_code.
		keycode_kt	 : in std_logic_vector(3 downto 0);  -- Keycode from keytest
		keycode      : out std_logic_vector(3 downto 0) );  -- output of the register.
end keytest_h_v2;

architecture main of keytest_h_v2 is
	
	signal keycode_int : std_logic_vector(3 downto 0);  -- output of the register.
	signal new_code_int : std_logic;  -- internal flag.
	signal nkey : std_logic; -- Signal to comment if keypad has nkey instead of key.
	
begin

nkey <= not (key);

REG_KEY : process (clk, nrst) begin
	if nrst = '0' then
		keycode_int <= x"0";
		new_code_int <= '0';
	elsif clk'EVENT and clk = '1' then
		if nkey = '0' then
			keycode_int <= keycode_kt;
		end if;
		if nkey = '0' then
			new_code_int <= '1';
		elsif code_read = '1' then
			new_code_int <= '0';
		end if;
	end if;
end process;


-- Type of key pressed by the user. This can be changed depending on the keypad.
bcd <= '1' when (keycode_int = x"0" or keycode_int = x"1" or keycode_int = x"2" or keycode_int = x"3" or keycode_int = x"4"
				or keycode_int = x"5" or keycode_int = x"6" or keycode_int = x"7" or keycode_int = x"8" 
				or keycode_int = x"9") and (new_code_int = '1') else '0';
ast <= '1' when (keycode_int = x"E" and new_code_int = '1') else '0';
hash <= '1' when (keycode_int = x"F" and new_code_int = '1') else '0';
A <= '1' when (keycode_int = x"A" and new_code_int = '1') else '0';
B <='1' when (keycode_int = x"B" and new_code_int = '1') else '0';
C <= '1' when (keycode_int = x"C" and new_code_int = '1') else '0';
D <= '1' when (keycode_int = x"D" and new_code_int = '1') else '0';

-- UPdating the output keycode and new_code

keycode <= keycode_int;
new_code <= new_code_int;

end;