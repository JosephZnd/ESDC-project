--Serial receiver. 
--Default baud rate is 56000 bps from a 50MHz clock.
--Version 1.2 october 2016.

library ieee;
use ieee.std_logic_1164.all;

entity register_bank2 is
port( clk, nrst, bcd, ast, new_code : in std_logic;
	   keycode : in std_logic_vector(3 downto 0);   
	   DataH, DataT, DataU  : out std_logic_vector(3 downto 0);
	   key_read, bank_ready: out std_logic );
end register_bank2;

architecture main of register_bank2 is

type stateType is ( st_wait, st_W_Keypress, st_Get_Key, st_end);
signal state: stateType;
signal s_DataH, s_DataT, s_DataU: std_logic_vector (3 downto 0);

begin

process(clk,nrst)

begin
	if (nrst='0') then
		state <= st_wait;
		bank_ready <= '1';
		DataH <= "0000";
		DataT <= "0000";
		DataU <= "0000";
	elsif (clk'event and clk = '1') then
		case state is
			when st_wait =>
				if new_code = '1' then 
					bank_ready <= '0';
					DataH <= "0000";
					DataT <= "0000";
					DataU <= "0000";
					state <= st_W_Keypress;
				end if;
				
			when st_W_Keypress =>
				
				if bcd = '1' then
					state <= st_Get_Key;
				end if;
				if ast = '1' then
					state <= st_end;
				end if;
					
			when st_Get_Key => 
				DataH <= s_DataT;
				DataT <= s_DataU;
				DataU <= keycode;
				--Actualizo los valores de las señales intermedias
				s_DataU <= keycode;
				s_DataT <= s_DataU;
				
				state <= st_W_Keypress;
				
			when st_end =>
				bank_ready <= '1';
				state <= st_wait;

			when others =>
			end case;
	end if;
end process;

key_read <= '1' when (state = st_Get_Key or state = st_end) else '0';

end;
