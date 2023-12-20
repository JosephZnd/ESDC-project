library ieee;
use ieee.std_logic_1164.all;


entity main_control is
	port (
		clk50, nrst: in std_logic;
		hash, white_received, fr_final, turn_read: in std_logic;  
		--winer, loser, tie: in std_logic; 
		--new_code, key_read : out std_logic;
		new_game : out std_logic;
		Turn, Color, LED_ON, LED_WHITE, LED_BLACK : out std_logic
		);
end main_control;


architecture main of main_control is
	type state_type is (st_wait_hash, st_Op_First, 
	st_P_First, st_send_color, st_start_game, S_Change_Turn, S_Wait_Turn);
	
	signal state : state_type;
	signal s_opp_first, s_color_white : std_logic;
	
begin

process (clk50, nrst) begin
	if nrst = '0' then
		state <= st_wait_hash;
		--GAME_OVER <= '1';
		LED_ON <= '1';
		LED_BLACK <= '0';
		LED_WHITE <= '0';
		s_opp_first <='0';

		
	elsif (clk50'event and clk50 = '1') then
		case state is
			when st_wait_hash =>
				if white_received = '1' then s_opp_first <= '1' ; LED_BLACK <= '1'; end if;
				if hash = '1' and  s_opp_first ='1' then 
					state <= st_Op_First;
				elsif hash = '1' then state <= st_P_First;
				end if;
				
			when st_Op_First => state <= st_start_game;
				--LED_BLACK <= '1';
				s_color_white<='0';
			
			when st_P_First => state <= st_start_game;
				s_color_white<='1';
				LED_WHITE <= '1';
			
			when st_start_game => state <= st_send_color;
			
			when st_send_color =>		
				LED_ON <= '0';	
				if s_color_white='1' then state <= S_Change_Turn;
				else state <= S_Wait_Turn; end if;
			
			when S_Change_Turn => 
				if turn_read='1' then state <= S_Wait_Turn; end if;
			
			when S_Wait_Turn => 
				if fr_final = '1' then state <= S_Change_Turn; end if;
			
			end case;
	end if;
end process;

new_game <= '1' when state = st_start_game else '0';
Turn <='1' when state=S_Change_Turn else '0';
Color <= s_color_white when state=st_send_color else '0';
end;