library ieee;
use ieee.std_logic_1164.all;


entity main_control is
	port (
		clk50, nrst: in std_logic;
		hash, code_entered: in std_logic;  
		winer, loser, tie: in std_logic; 
		new_code, key_read : out std_logic;
		game_over, new_game : out std_logic;
		LED_CODE : out std_logic
		);
end main_control;


architecture main of main_control is
	type state_type is (st_wait_hash, st_enter_code, st_w_code, st_start_game, st_w_game);
	
	signal state : state_type;
	
begin

process (clk50, nrst) begin
	if nrst = '0' then
		state <= st_wait_hash;
		GAME_OVER <= '1';
		LED_CODE <= '0';
		
	elsif (clk50'event and clk50 = '1') then
		case state is
			when st_wait_hash =>
				if hash = '1' then 
					state <= st_enter_code;
				end if;

			when st_enter_code => 		
				LED_CODE <= '1';
				game_over <= '0';
				state <= st_w_code;
			when st_w_code => 
				if code_entered = '1' then 
					state <= st_start_game;
				end if;	
						
			when st_start_game =>	
				LED_CODE <= '0';
				state <= st_w_game;
				
			when st_w_game => 
				if winer = '1' or loser = '1' or tie = '1' then 
					GAME_OVER <= '1';
					state <= st_wait_hash;
				end if;	

			when others =>
				end case;
	end if;
end process;


key_read <= '1' when state = st_enter_code else '0';
new_code <= '1' when state = st_enter_code else '0';
new_game <= '1' when state = st_start_game else '0';

end;