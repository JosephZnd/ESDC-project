library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity game is
	port (
		clk50, nrst: in std_logic;
		new_game : in std_logic;  
		RDY_RECEIVED, DT_RECEIVED: in std_logic;  
		Oponent_x,Oponent_y: in integer range 0 to 7;
		Oponent_fig: in std_logic_vector(2 downto 0);
		bank_ready, ready_to_TX, Turn, Color: in std_logic; 
		pos_x, pos_y : in integer range 0 to 7; 
		Sel	: in std_logic;
		in_piece :  in std_logic_vector(2 downto 0);
		SEND_RDY, SEND_DT : out std_logic;
		frame_received : out std_logic;
		led_turn, turn_read, freeze_kb, wen_game, mux_ram : out std_logic;
		x_out, y_out, send_x, send_y : out integer range 0 to 7; 
		out_piece, send_piece :  out std_logic_vector(2 downto 0);
		led_test, clr_cursor : out std_logic);
end game;


architecture main of game is
	type state_type is (st_wait_game, st_W_TX1, st_S_RDY, st_W_RDY, st_Start_Game, 
	st_Turn, st_Wait_Turn, st_rFigure, st_Move, s_Turn0, s_Turn1, st_Invalid, 
	S_Turn2, S_Validate, S_Place_Figure, S_Move_Black ,S_Move_White, st_wrFigure, S_End_Turn,
	st_Send_1, st_Pre_Send, S_Tx_1, st_Send_2, S_Tx_End, S_Send_End, st_Refresh, st_Receive
	);
	
	signal state : state_type;
	signal s_white, SelMode : std_logic;
	signal Opponent_Gr_Our : std_logic;
	signal selX, selY, oldX, oldY, s_x_out, s_y_out, iselX, iselY, ioldX, ioldY, iauX, iAuY, s_sendy,s_sendx : integer range 0 to 7:=0; 
	signal temp_piece, aux_piece, ext_piece, s_sendfig : std_logic_vector(2 downto 0);
	signal count : integer range 0 to 5; 
	signal s_frame : std_logic;

	
begin

process (clk50, nrst) begin
--variable iselX, iselY, ioldX, ioldY, iauX, iAuY : integer range 0 to 7;

	if nrst = '0' then
		state <= st_wait_game;
		s_frame <='0';
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
	
			when st_W_RDY =>
				if RDY_Received = '1' then
					state <= st_Start_Game;
				end if;
				
			-- Hay sincronzacion de RDYs
			
			when st_Start_Game => state <= st_Wait_Turn;
				
			when st_Wait_Turn =>
				s_frame <='0';
				if Turn='1' then state <= st_Turn; end if;
				if DT_RECEIVED ='1' then 
				s_x_out <= Oponent_x; 
				s_y_out <= Oponent_y;
				ext_piece <= Oponent_fig;
				state <=  st_Receive; end if;
			
			when st_Turn =>
				--selX <= pos_x; 		
				--selY <= pos_y;
				if( Sel='1')then 
					oldX <= selX; --pero que no se lea en Game hasta que no se pulsa Sel
					oldY <= selY;
					state <= st_rFigure;
				end if;
				
			when st_rFigure =>
				--oldX <= selX; --pero que no se lea en Game hasta que no se pulsa Sel
				--oldY <= selY;
				selX <= pos_x; 		-- podemos hacer que x e y vayan tanto a RAM como input a Game
				selY <= pos_y;
				count <= count + 1;
				if (count = 4) then state <= st_Move ; end if;
							
			when st_Move => 
				count <= 0;
				temp_piece <= in_piece;
				if(SelMode = '0') then
					--temp_piece <= in_piece;

					--oldX <= selX; --pero que no se lea en Game hasta que no se pulsa Sel
					--oldY <= selY;
					state <= s_Turn0;
				else 
					--temp_piece <= in_piece;
					state <= s_Turn1;
				end if;
				
			when s_Turn0 =>
				if(temp_piece < "100" and s_white = '1') then 
						state <= S_Validate;
					elsif (temp_piece > "100" and s_white = '0') then
						state <= S_Validate;
					else state <= st_Invalid;
					end if;
					
			when st_Invalid => 
				if SelMode='0' then state <= st_Turn;
				else SelMode <= '0'; --piece back to where it came.
					ext_piece <= aux_piece;
					temp_piece <= "100";
					state <= S_Place_Figure;
				end if;		
				
				SelMode <= '0';
			
			when s_Turn1 => 
				--temp_piece <= in_piece;
				--aux_piece <= temp_piece;
				state <= s_Turn2;
			
			when s_Turn2 =>
				if(selX = oldX and selY = oldY) then state <= st_Invalid;
				elsif (aux_piece < "100" and s_white ='1') then -- This to allow only white movements
					state <= S_Move_White;
				elsif (aux_piece > "100" and s_white ='0') then state <= S_Move_Black;
				else state <= st_Invalid; --cualquier otro caso, vuelves a elegir, no puedes elegir de otro color
				end if;
				
			when S_Move_White =>
				ioldX <= oldX;
				ioldY <= oldY;
				iselX <= selX;
				iselY <= selY;
				--peon blanco
				if aux_piece = "010" then
					-- primer cuadrante, dcha-arriba. 
					if ((ioldY - iselY) = (iselX - ioldX)  and (iselY < ioldY) and (iselX > ioldX)) then --Quad1
						if temp_piece > "100" then --se dispone a comer la pieza
							iauY <= ioldY-1;
							iauX <= ioldX+1;
							--state <= S_Check;
						elsif temp_piece = "100" then
							--s_x_out <= selX; 
							--s_y_out <= selY; 
							ext_piece <= aux_piece;
							state <= S_Place_Figure;
						else state <= st_Turn;		
						end if;
						
					-- segundo cuadrante, izda arriba
					elsif ((ioldY - iselY) = (ioldX - iselX)  and iselY < ioldY and iselX < ioldX) then --Quad2
						if temp_piece > "100" then
								iauY <= ioldY-1;
								iauX <= ioldX-1;
								--state <= S_Check;
						elsif temp_piece = "100" then
							ext_piece <= aux_piece;
							--s_addW <= selY & selX;
							state <= S_Place_Figure;
						else state <= st_Turn;
						end if;
					end if;
				end if;
				
			when S_Move_Black =>
				ioldX <= oldX;
				ioldY <= oldY;
				iselX <= selX;
				iselY <= selY;
				--peon negr
				if aux_piece = "111" then
					-- tercer cuadrante, izda abajo
					if ((iselY - ioldY) = (ioldX - iselX)  and iselY > ioldY and iselX < ioldX) then --Quad3
						if temp_piece < "100" then
								iauY <= ioldY+1;
								iauX <= ioldX-1;
								--state <= S_Check;
						elsif temp_piece = "100" then
							ext_piece <= aux_piece;
							--s_addW <= selY & selX;
							state <= S_Place_Figure;
						else state <= st_Turn;							
						end if;
					
					-- cuarto cuadrante, dcha abajo
					elsif ((iselY - ioldY) = (iselX - ioldX)  and iselY > ioldY and iselX > ioldX) then --Quad2
						if temp_piece < "100" then
								iauY <= ioldY+1;
								iauX <= ioldX+1;
								--state <= S_Check;
						elsif temp_piece = "100" then
							ext_piece <= aux_piece;
							--s_addW <= selY & selX;
							state <= S_Place_Figure;
						else state <= st_Turn;		
						end if;
					end if;
				end if;
					
				
				
				
			when S_Validate =>
				aux_piece <= temp_piece;
				s_x_out <= selX; 
				s_y_out <= selY; 
				ext_piece <= "100"; --hay que poner como vacia la casilla
				state <= S_Place_Figure;
			
			when S_Place_Figure => state <= st_wrFigure;
				s_x_out <= selX; 
				s_y_out <= selY;
				
			when st_wrFigure =>
				count <= count + 1;
				if (count = 4) then
					if s_frame = '1' then state <= st_Wait_Turn ;
					end if;
					state <= S_End_Turn ; end if;
			--ensure they wait enough time to write
					
				
			when S_End_Turn => 
				count <= 0;
				SelMode <= not(SelMode);
				if SelMode = '0' then state <= st_Turn; --cuando clickas una vez
				else state <= st_Pre_Send; --mandas
				end if;
				
			when st_Pre_Send =>
				if ready_to_TX = '1' then state <= st_Send_1;
				end if;
			
			when st_Send_1 =>
			--send packet 1
				s_sendfig <= "100";
				s_sendx <= oldX;
				s_sendy <= oldY;
				state <= S_Tx_1;
			
			when S_Tx_1 =>
				if ready_to_TX = '1' then state <= st_Send_2;
					--if three_packets ='0' then
						--state <= S_Send_2;
					--elsif three_packets ='1' then
						--state <= S_Send_3;
					--end if;
				end if;
			
			--when S_Send_3 =>
				--s_x <= auX;
				--s_y <= auY;
				--s_figure <= temp_piece;
				--state <= S_Tx_2;
			
			--when S_Tx_2 =>
				--if s_tx_ready = '1' then
				--state <= S_Send_2;
				--end if;	
				
			when st_Send_2 =>
				s_sendfig <= aux_piece;
				s_sendx <= selX;
				s_sendy <= selY;
				--if three_packets ='0' then
					--s_figure <= temp_piece;
				--else
					--s_figure <= "100";
				--end if;
				state <= S_Tx_End;
								
			when S_Tx_End =>
				if ready_to_TX = '1' then
				state <= S_Send_End;
				end if;	
				
			when S_Send_End =>
				--three_packets <= '0';
				temp_piece <= "100";
				state <= st_Wait_turn;
				
			when st_Receive =>
				
				state <= st_Refresh;
			
			when st_Refresh => 
				s_frame <= '1';
				state <= st_wrFigure;
					
			when others =>
				end case; 
	end if;
end process;
--selX <= pos_x; 		
--selY <= pos_y;
x_out <= s_x_out when state = S_Place_Figure ;
y_out <= s_y_out  when state = S_Place_Figure ;
send_y <= s_sendy; 
send_x <= s_sendx;
send_piece <= s_sendfig;
led_turn <='1' when state = st_Turn else '0';
led_test <='1' when state = S_End_Turn else '0';
turn_read <='1' when state = st_Turn else '0';
freeze_kb <='0' when state = st_Turn else '1';
clr_cursor <='1' when state = S_Place_Figure or state = st_Invalid else '0';
--s_sel <= Sel when state = st_Turn else '0';
wen_game <= '1' when state = st_wrFigure else '0';
mux_ram <= '1' when state = st_wrFigure else '0';
out_piece <= ext_piece when state = st_wrFigure else "000";
SEND_RDY <= '1' when state = st_S_RDY else '0';
SEND_DT <= '1' when state = st_Send_2 or state = st_Send_1 else '0';

frame_received <= '1' when state= st_Start_Game or state = st_Receive else '0';


end;