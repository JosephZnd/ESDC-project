library ieee;
use ieee.std_logic_1164.all;

entity Main is 	
	port(clk, nrst, hash, whites, whites_rx, rdy_rx, dt_rx, frame3 : in std_logic ;
	Turn, Colour, Main_wr_addr, Main_wr_piece, WEN_Main, White_LED, ON_LED, SEND_rdy, SEND_whites, frame_read: out std_logic);
end Main;


architecture arq of Main is
type state_type is (S_Wait, S_Start, S_Op_First, S_P_First, S_You_Chose_White, S_Send_White,S_Ready_Game,S_New_Game, S_Change_Turn, S_Wait_Turn, S_Write_RAM,S_Write_Ends);
signal state : state_type;
signal hash_int, white_int, colour_int, whit_rx_int, last_frame_rx_int, dt_rx_int, set_W_L , set_O_L: std_logic;
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
				if hash='1' then hash_int <='1';
					end if;
				if whites ='1' then 
					white_int <='1';
					
					end if;
				if whites_rx = '1' then whit_rx_int <='1';
					end if;
				if rdy_rx ='1' then
					if hash_int ='1' then 
						state <= S_P_First;
					else state <= S_Start;
					end if;
				end if;
			when S_Start =>
				if hash='1' then 
					state <= S_Op_First;--This means that the other opponent chose colour first
				end if;
			when S_Op_First =>
				if whit_rx_int='1' and white_int='1' then
					state <= S_Ready_Game;
					white_int<='0';
				elsif whit_rx_int<='0' and white_int='0' then
					state <= S_Ready_Game;
					white_int<='1';
				else 
					white_int<=white_int;
					state <= S_Ready_Game;
					
			
				end if;
			when S_P_First =>
				if white_int='1' then state <= S_You_Chose_White;
				else state <= S_Ready_Game;
				end if;
			when S_You_Chose_White =>state <= S_Send_White;
--				
			when S_Send_White => 
				state <= S_Ready_Game;
			when S_Ready_Game =>
				colour_int <= white_int;
				state <= S_New_Game;
				
			when S_New_Game =>
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
				if dt_rx_int ='1' then --cuando mandan el primer frame, activar escritura por main
					dt_rx_int <= '0';
					state <= S_Write_RAM;
				end if;
			when S_Write_RAM =>
				if frame3='1' then	last_frame_rx_int <='1'; --REVISAR QUE NO DE PROBLEMAS
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
					else state <=S_Wait_Turn;
				end if;				
					-- cuando mandan el tercer frame, ir a Turn
				
				
		end case;
	end if;

end process;

White_LED<= set_W_L;
ON_LED <= set_O_L;

SEND_rdy <= hash when state=S_Wait or state=S_Start else '0';
SEND_whites <= white_int when state=S_Wait else '0';
Colour <= colour_int when state=S_New_Game else '0';
Main_wr_addr <= '1'when state = S_Write_RAM else '0';
Main_wr_piece <= '1' when state = S_Write_RAM  else '0';
WEN_Main <='1' when state = S_Write_RAM else '0';
frame_read <='1' when state=S_Write_Ends or state = S_Start or state = S_P_First else '0';
Turn <='1' when state=S_Change_Turn else '0';
end;