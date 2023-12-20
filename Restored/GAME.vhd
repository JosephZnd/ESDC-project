library ieee;
use ieee.std_logic_1164.all;


entity game is
	port (
		clk50, nrst: in std_logic;
		new_game : in std_logic;  
		RDY_RECEIVED, GR_RECEIVED, EQ_RECEIVED, SM_RECEIVED, DT_RECEIVED: in std_logic;  
		OponentH, OponentT, OponentU : in std_logic_vector(3 downto 0);
		OurH, OurT, OurU : in std_logic_vector(3 downto 0);
		bank_ready, ready_to_TX, Turn, Color: in std_logic;  
		SEND_RDY, SEND_GR, SEND_EQ, SEND_SM, SEND_DT : out std_logic;
		frame_received : out std_logic;
		LightD, LightG, LightS, Light_WIN, Light_Loose, Light_Tie : out std_logic;
		enterCode, led_turn, turn_read, freeze_kb : out std_logic
		);
end game;


architecture main of game is
	type state_type is (st_wait_game, st_W_TX1, st_S_RDY, st_W_RDY, st_Start_Game, st_Turn, st_Wait_Turn, st_Code, st_W_Code, st_W_TX2, st_S_DT, st_W_DT,
	sT_FR_R, st_W_TX3, st_S_GRorSM, st_W_FR, st_S_EQ, st_W_FR2);
	
	signal state : state_type;
	signal s_white : std_logic:='0';
	signal Opponent_Gr_Our : std_logic;
	
begin

process (clk50, nrst) begin
	if nrst = '0' then
		state <= st_wait_game;
		LightD <= '0';
		LightG <= '0';
		LightS <= '0';
		Light_WIN <= '0';
		Light_Loose <= '0';
		Light_Tie <= '0';
	elsif clk50'event and clk50 = '1' then
		case state is
			when st_wait_game =>
				if new_game = '1' then
					state <= st_W_TX1;
				end if;

			when st_W_TX1 => 
				if Color='1' then 
					s_white <='1';
				end if;
				
				if ready_to_TX = '1' then
					state <= st_S_RDY;
				end if;
				
			when st_S_RDY => 
				state <= st_W_RDY;
			
			--when st_W_RDY =>
				--if RDY_Received = '1' then
					--state <= st_Code;
				--end if;
				
			when st_W_RDY =>
				if RDY_Received = '1' then
					state <= st_Start_Game;
				end if;
				
			-- Hay sincronzacion de RDYs
			
			when st_Start_Game => state <= st_Wait_Turn;
				
			when st_Wait_Turn => 
				if Turn='1' then state <= st_Turn; end if;
			
			when st_Turn =>
				 --se queda aqui
					
			
			when st_Code =>
				state <= st_W_code;
				--LightD <= '1';

			when st_W_code =>
				if bank_ready = '1' then
					state <= st_W_TX2;
					--LightD <= '0';
				end if;	
			
			when st_W_TX2 =>
				if ready_to_TX = '1' then
					state <= st_S_DT;
				end if;	
			
			when st_S_DT =>
				state <= st_W_DT;
			
			when st_W_DT =>
				if DT_RECEIVED = '1' then
					state <= st_FR_R;
				end if;	
			
			when st_FR_R =>
				state <= st_W_TX3;
				
			when st_W_TX3 =>
				if ready_to_TX = '1' then
					if (OponentH=OurH and OponentT=OurT and OponentU=OurU) then
						state <= st_S_EQ;
					else
						state <= st_S_GRorSM;
					end if;
				end if;	
				
			when st_S_GRorSM =>
				state <= st_W_FR;
				
			when st_W_FR =>
				if EQ_RECEIVED = '1' then
					light_WIN <= '1';
					light_Loose <= '0';
					light_Tie <= '0';
					lightG <= '0';
					lightS <= '0';
					lightD <= '0';
					state <= st_wait_game;
				elsif GR_RECEIVED = '1' then
					light_WIN <= '0';
					light_Loose <= '0';
					light_Tie <= '0';
					lightG <= '1';
					lightS <= '0';
					lightD <= '0';
					state <= st_code;
				elsif SM_RECEIVED = '1' then
					light_WIN <= '0';
					light_Loose <= '0';
					light_Tie <= '0';
					lightG <= '0';
					lightS <= '1';
					lightD <= '0';
					state <= st_code;
				end if;	
			
			when st_S_EQ =>
				state <= st_W_FR2;
				
			when st_W_FR2 =>
				if EQ_RECEIVED = '1' then
					light_WIN <= '0';
					light_Loose <= '0';
					light_Tie <= '1';
					lightG <= '0';
					lightS <= '0';
					lightD <= '0';
					state <= st_wait_game;
				elsif GR_RECEIVED = '1' or SM_RECEIVED = '1' then
					light_WIN <= '0';
					light_Loose <= '1';
					light_Tie <= '0';
					lightG <= '0';
					lightS <= '0';
					lightD <= '0';
					state <= st_wait_game;
				end if;	
				
			when others =>
				end case; 
	end if;
end process;
led_turn <='1' when state = st_Turn else '0';

turn_read <='1' when state = st_Turn else '0';
freeze_kb <='0' when state = st_Turn else '1';

SEND_RDY <= '1' when state = st_S_RDY else '0';
SEND_DT <= '1' when state = st_S_DT else '0';
SEND_EQ <= '1' when state = st_S_EQ else '0';
SEND_GR <= '1' when state = st_S_GRorSM and Opponent_Gr_Our = '1' else '0';
SEND_SM <= '1' when state = st_S_GRorSM and Opponent_Gr_Our = '0' else '0';

enterCode <= '1' when state = st_Code else '0';

frame_received <= '1' when state= st_Start_Game or state = st_Code or state = st_FR_R or ((state = st_W_FR or state = st_W_FR2 ) and 
(EQ_RECEIVED = '1' or GR_RECEIVED = '1' or SM_RECEIVED = '1')) else '0';

Opponent_Gr_Our <= '1' when (OponentH>OurH or (OponentH=OurH and OponentT>OurT) or (OponentH=OurH and OponentT=OurT and OponentU=OurU)) else '0';

end;