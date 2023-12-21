library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity game is
	port (
		clk50, nrst: in std_logic;
		new_game : in std_logic;  
		RDY_RECEIVED, GR_RECEIVED, EQ_RECEIVED, SM_RECEIVED, DT_RECEIVED: in std_logic;  
		OponentH, OponentT, OponentU : in std_logic_vector(3 downto 0);
		OurH, OurT, OurU : in std_logic_vector(3 downto 0);
		bank_ready, ready_to_TX, Turn, Color: in std_logic; 
		pos_x, pos_y : in integer range 0 to 7; 
		Sel	: in std_logic;
		in_piece :  in std_logic_vector(2 downto 0);
		SEND_RDY, SEND_GR, SEND_EQ, SEND_SM, SEND_DT : out std_logic;
		frame_received : out std_logic;
		LightD, LightG, LightS, Light_WIN, Light_Loose, Light_Tie : out std_logic;
		enterCode, led_turn, turn_read, freeze_kb, wen_game, mux_ram : out std_logic;
		x_out, y_out : out integer range 0 to 7; 
		out_piece :  out std_logic_vector(2 downto 0);
		led_test : out std_logic);
end game;


architecture main of game is
	type state_type is (st_wait_game, st_W_TX1, st_S_RDY, st_W_RDY, st_Start_Game, 
	st_Turn, st_Wait_Turn, st_rFigure, st_Move, s_Turn0, s_Turn1, st_Invalid, 
	S_Turn2, S_Validate, S_Place_Figure, S_End_Turn, st_Code, st_W_Code, st_W_TX2, st_S_DT, st_W_DT,
	sT_FR_R, st_W_TX3, st_S_GRorSM, st_W_FR, st_S_EQ, st_W_FR2);
	
	signal state : state_type;
	signal s_white, SelMode : std_logic;
	signal Opponent_Gr_Our : std_logic;
	signal selX, selY, oldX, oldY, s_x_out, s_y_out : integer range 0 to 7; 
	signal temp_piece, aux_piece, ext_piece : std_logic_vector(2 downto 0);
	signal count : integer range 0 to 5; 

	
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
		s_white <= '0';
		SelMode <= '0';
		count<=0;
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
				if( Sel='1')then 
					selX <= pos_x; 		-- podemos hacer que x e y vayan tanto a RAM como input a Game
					selY <= pos_y;
					state <= st_rFigure;
				end if;
				
			when st_rFigure => 
				count <= count + 1;
				if (count = 4) then state <= st_Move ; end if;
							
			when st_Move => 
				count <= 0;
				if(SelMode = '0') then
					temp_piece <= in_piece;
					oldX <= selX; --pero que no se lea en Game hasta que no se pulsa Sel
					oldY <= selY;
					state <= s_Turn0;
				else 
					aux_piece <= temp_piece;
					state <= s_Turn1;
				end if;
				
			when s_Turn0 =>
				if(temp_piece < "100" and s_white = '1') then 
						state <= S_Validate;
					elsif (temp_piece > "100" and s_white = '0') then
						state <= S_Validate;
					else state <= st_Invalid;
					end if;
					
			when st_Invalid => state <= st_Turn;
				SelMode <= '0';
			
			when s_Turn1 => 
				temp_piece <= in_piece;
				state <= s_Turn2;
			
			when s_Turn2 =>
				
				
				
			when S_Validate =>
				aux_piece <= temp_piece;
				s_x_out <= selX; 
				s_y_out <= selY; 
				ext_piece <= "100"; --hay que poner como vacia la casilla
				state <= S_Place_Figure;
			
			when S_Place_Figure =>
				count <= count + 1;
				if (count = 4) then state <= S_End_Turn ; end if;
			--ensure they wait enough time to write
					
				
			when S_End_Turn => 
				SelMode <= not(SelMode);
				state <= st_Turn;
			
					
			
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

x_out <= s_x_out;
y_out <= s_y_out;

led_turn <='1' when state = st_Turn else '0';
led_test <='1' when state = S_End_Turn else '0';
turn_read <='1' when state = st_Turn else '0';
freeze_kb <='0' when state = st_Turn else '1';
--s_sel <= Sel when state = st_Turn else '0';
wen_game <= '1' when state = S_Place_Figure else '0';
mux_ram <= '1' when state = S_Place_Figure else '0';
out_piece <= ext_piece when state = S_Place_Figure else "000";
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