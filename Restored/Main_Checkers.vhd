library ieee;
use ieee.std_logic_1164.all;

entity Main_Checkers is 	
	port(clk, nrst, hash, whites_rx, rdy_rx, dt_rx, frame3 : in std_logic ;
	Turn, Colour, Main_wr_addr, Main_wr_piece, WEN_Main, White_LED, ON_LED, SEND_rdy, SEND_whites, frame_read: out std_logic);
end Main_Checkers;


architecture arq of Main_Checkers is
type state_type is (S_Wait, S_Wait_Rdy, S_Send_Rdy, S_Rdy_4_Game, S_Start_Game, S_Change_Turn, S_Wait_Turn, S_Write_RAM,S_Write_Ends);
signal state : state_type;
signal hash_int, white_int, colour_int, whit_rx_int, last_frame_rx_int, enable_Ram_wr, set_W_L , set_O_L, set_send_rdy: std_logic;
signal count: integer :=0;
begin

--When we press 1, saves it an internal value the colour White	
process(clk, nrst)
	begin
	if nrst='0' then
		hash_int<='0';
		set_O_L<='0';
		white_int <='0';
		whit_rx_int <='0';
		state <= S_Wait;
	elsif clk'EVENT and clk='1' then
		
		case state is
			when S_Wait => --we wait until it is pressed hash
				set_O_L<='1';
				if hash='1' then 
					white_int <='1';
					colour_int <='1';
					state <= S_Wait_Rdy;
				end if;
				if whites_rx = '1' then 
					whit_rx_int <='1';
					colour_int <='0';
					state <= S_Send_Rdy;
				end if;
				
			when S_Wait_Rdy =>
				if rdy_rx ='1' then
					state <= S_Rdy_4_Game;
				end if;
				
			when S_Send_Rdy =>
				set_send_rdy <= '1';
				state <= S_Wait_turn;
				
			when S_Rdy_4_Game => state <= S_Start_Game;

			when S_Start_Game =>
				set_O_L<='0';
				if white_int='1' then 
					state <= S_Change_Turn;
					set_W_L<='1'; --Don't forget to put a NEG to bright the BLACK led
				else 
					state <= S_Wait_Turn;
				end if;
				
			when S_Change_Turn => state <= S_Wait_Turn;
					--activate Turn
					--deactivate writing by main
					
			when S_Wait_Turn =>
				if dt_rx ='1' then --cuando mandan el primer frame, activar escritura por main
					enable_Ram_wr <= '0';
					state <= S_Write_RAM;
				end if;
				
			when S_Write_RAM =>
				if frame3='1' then	
					last_frame_rx_int <='1'; --REVISAR QUE NO DE PROBLEMAS
				end if;
				count <= count + 1;
				if count=5 then--Wait 4 cycles to ensure writes the RAM
					count <= 0;
					state <= S_Write_Ends;
				end if;
				
			when S_Write_Ends =>
				if last_frame_rx_int ='1' then
					last_frame_rx_int <= '0';
					state <= S_Change_Turn;
					enable_Ram_wr <= '1';
				else state <=S_Wait_Turn;
				end if;				
					-- cuando mandan el tercer frame, ir a Turn
				
				
		end case;
	end if;

end process;

White_LED<= set_W_L;
ON_LED <= set_O_L;

SEND_rdy <= set_send_rdy when state=S_Send_Rdy;
SEND_whites <= white_int when state=S_Wait else '0';
Colour <= colour_int when state=S_Rdy_4_Game else '0';
Main_wr_addr <= '1'when state = S_Write_RAM else '0';
Main_wr_piece <= '1' when state = S_Write_RAM  else '0';
WEN_Main <='1' when state = S_Write_RAM else '0';
frame_read <='1' when state=S_Write_Ends or state = S_Rdy_4_Game;
Turn <='1' when state=S_Change_Turn else '0';
end;