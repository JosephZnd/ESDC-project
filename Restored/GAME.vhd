library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH;

entity game is
	port (
		clk50, nrst: in std_logic;
		New_Game, Sel : in std_logic;  
		RDY_RECEIVED: in std_logic;  
		Pos_X, Pos_Y : in integer range 7 downto 0;
		In_Piece : in std_logic_vector(2 downto 0);
		ready_to_TX, Turn, Color: in std_logic;  
		SEND_RDY : out std_logic;
		led_turn, turn_read, freeze_kb : out std_logic;
		Ram_X, Ram_Y : out integer range 7 downto 0;
		X_To_Sent, Y_To_Sent: out integer range 7 downto 0;
		Write_Piece: out std_logic_vector(2 downto 0));
end game;


architecture main of game is
	type state_type is (st_Wait_Game, st_W_Tx1, st_S_Rdy, st_W_Rdy, st_Start_Game, st_Turn, st_Wait_Turn, st_Read_Ram, st_Check_Piece, st_Check_Second_Move, st_Capture, st_Check_capture,
	st_Move_Piece, st_Write_Ram, st_Invalid_Move, st_Finish_Turn, st_Assign_Position);
	
	signal state : state_type;
	signal s_whites : std_logic:='0';
	signal while_Capturing : std_logic:='0';
	signal sel_Selected : std_logic:='0';
	signal piece_Moved : std_logic:='0';
	signal piece_Removed : std_logic:='0';
	
	signal counter : STD_LOGIC_VECTOR(3 downto 0) := "0000";
	
	signal sel_X : integer range 7 downto 0 := 0;
	signal sel_Y : integer range 7 downto 0 := 0;
	signal old_X : integer range 7 downto 0 := 0;
	signal old_Y : integer range 7 downto 0 := 0;
	signal to_Move_X : integer range 7 downto 0 := 0;
	signal to_Move_Y : integer range 7 downto 0 := 0;
	signal pos_To_Capture_X : integer range 7 downto 0;
	signal pos_To_Capture_Y : integer range 7 downto 0;
	
	
	signal piece_To_Move: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal piece_To_Capture : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal arriving_Cell: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal piece_To_Write: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal last_Piece: STD_LOGIC_VECTOR(2 downto 0) := "000";

	
	signal s_Ram_X : integer range 7 downto 0;
	signal s_Ram_y : integer range 7 downto 0;
	signal address_To_Capture : STD_LOGIC_VECTOR(5 downto 0) := "000000";
	
begin

process (clk50, nrst) 
	begin
	if nrst = '0' then
		state <= st_Wait_Game;
	elsif clk50'event and clk50 = '1' then
			sel_X <= Pos_X;
			sel_Y <= Pos_Y;
		case state is
			when st_Wait_Game =>
				if New_Game = '1' then
					state <= st_W_Tx1;
				end if;

			when st_W_Tx1 => 
				if Color='1' then 
					s_whites <='1';
				end if;
				
				if ready_to_TX = '1' then
					state <= st_S_RDY;
				end if;
				
			when st_S_RDY => 
				state <= st_W_Rdy;
			
			--when st_W_RDY =>
				--if RDY_Received = '1' then
					--state <= st_Code;
				--end if;
				
			when st_W_Rdy =>
				if RDY_Received = '1' then
					state <= st_Start_Game;
				end if;
				
			-- Hay sincronzacion de RDYs
			
			when st_Start_Game => state <= st_Wait_Turn;
				
			when st_Wait_Turn => 
				if Turn='1' then state <= st_Turn; end if;
			
			when st_Turn =>
				if Sel = '1' then --don't write rising edge here
					if(sel_Selected = '0') then
						state <= st_Assign_Position;
						s_Ram_X <= sel_X;
						s_Ram_Y <= sel_Y;
					else
						state <= st_Assign_Position;
						s_Ram_X <= old_X;
						s_Ram_Y <= old_Y;
					end if;
				end if;
			
			when st_Assign_Position =>
			counter <= "0000";
				if sel_Selected = '0' then
					old_X <= sel_X;
					old_Y <= sel_Y;
					state <= st_Read_Ram;
				elsif sel_Selected = '1' then	
					to_Move_X <= sel_X;
					to_Move_Y <= sel_Y;
					state <= st_Read_Ram;
				end if;
				
			when st_Read_Ram =>
					counter <= counter +1;
					if counter = "0100" then
						if sel_Selected = '0' then
							piece_To_Move <= In_Piece;
							state <= st_Check_Piece;
						elsif while_Capturing = '1' then
							piece_To_Capture <= In_Piece;
							state <= st_Check_Capture;	
						else	
							arriving_Cell <= In_Piece;
							state <= st_Check_Second_Move;
						end if;
					end if;
			
			when st_Check_Piece =>
				if ((s_whites = '1' and piece_To_Move = "001") or (s_whites = '1' and piece_To_Move = "010")) then
					sel_Selected <= '1';
					state <= st_Turn;
				elsif ((s_whites = '0' and piece_To_Move = "110") or (s_whites = '0' and piece_To_Move = "111")) then
					sel_Selected <= '1';
					state <= st_Turn;
				else 
					state <= st_Invalid_Move;
				end if;
			
			when st_Check_Second_Move => 
				if (to_Move_X = old_X+1) and (to_Move_Y = old_Y+1) then	
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif (to_Move_X = old_X +1) and (to_Move_Y = old_Y-1) then
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif (to_Move_X = old_X -1) and (to_Move_Y = old_Y+1) then
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif (to_Move_X = old_X -1) and (to_Move_Y = old_Y-1) then
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif to_Move_X = old_X +2 and to_Move_Y = old_Y+2 then	
					if arriving_Cell = "100" then
						state <= st_Capture;
						pos_To_Capture_X <= old_X+1;
						pos_To_Capture_Y <= old_Y+1;
					else 
						state <= st_Invalid_Move;
					end if;

				elsif to_Move_X = old_X +2 and to_Move_Y = old_Y-2 then
					if arriving_Cell = "100" then
						pos_To_Capture_X <= old_X+1;
						pos_To_Capture_Y <= old_Y-1;
						state <= st_Capture;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif to_Move_X = old_X -2 and to_Move_Y = old_Y+2 then
					if arriving_Cell = "100" then
						pos_To_Capture_X <= old_X-1;
						pos_To_Capture_Y <= old_Y+1;
						state <= st_Capture;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif to_Move_X = old_X -2 and to_Move_Y = old_Y-2 then
					if arriving_Cell = "100" then
						pos_To_Capture_X <= old_X-1;
						pos_To_Capture_Y <= old_Y-1;
						state <= st_Capture;
					else 
						state <= st_Invalid_Move;
					end if;	
				else 
					state <= st_Invalid_Move;
				end if;	
				
			when st_Capture =>
				counter <= "0000";
				while_Capturing <= '1';
				state <= st_Read_Ram;
			
			when st_Check_Capture =>
				if s_whites = '1' then
					if piece_To_Capture = "111" or piece_To_Capture = "110" then
						state <= st_Move_Piece;
					else
						state <= st_Invalid_Move;
					end if;
				elsif s_whites = '0' then
					if piece_To_Capture = "001" or piece_To_Capture = "010" then
						state <= st_Move_Piece;
					else
						state <= st_Invalid_Move;
					end if;
				end if;
				
			when st_Move_Piece =>
				counter <= "0000";	
				if while_Capturing = '1' then
					s_Ram_X <= pos_To_Capture_X;
					s_Ram_Y <= pos_To_Capture_Y;
					piece_To_Write <= "100";
					state <= st_Write_Ram; 
				elsif piece_Moved = '1' then
					s_Ram_X <= old_X;
					s_Ram_Y <= old_Y;
					piece_To_Write <= "100";
					state <= st_Write_Ram;
				else 
					s_Ram_X <= to_Move_X;
					s_Ram_Y <= to_Move_Y;
					piece_To_Write <= piece_To_Move;
					state <= st_Write_Ram;
				end if;
				
			when st_Write_Ram => 
				counter <= counter +1;
				if counter = "1111" then
					if while_Capturing = '1' then
						while_Capturing <= '0';
						state <= st_Move_Piece;
					elsif piece_Moved = '1' then
						piece_Moved <= '0';
						state <= st_Finish_Turn;
					else
						piece_Moved <= '1';
						state <= st_Move_Piece;
					end if;
				end if;
				
			when st_Invalid_Move =>
				sel_Selected <= '0';
				while_Capturing <='0';
				piece_Moved <='0';
				state <= st_Turn;	
				
			when st_Finish_Turn =>
				sel_Selected <= '0';
				while_Capturing <='0';
				piece_Moved <='0'; 
				state <= st_Wait_Turn;
				
		
			when others =>
				end case; 
	end if;
end process;
Ram_X <= s_Ram_X when (state = st_Write_Ram or state = st_Read_Ram);
Ram_Y <= s_Ram_Y when (state = st_Write_Ram or state = st_Read_Ram);
Write_Piece <= piece_To_Write when state = st_Write_Ram;

Y_To_Sent <= s_Ram_Y when state = st_Write_Ram;
X_To_Sent <= s_Ram_X when state = st_Write_Ram;

SEND_DT <= '1' when state = st_Write_Ram else '0';

led_turn <='1' when state = st_Turn else '0';

turn_read <='1' when state = st_Turn else '0';
freeze_kb <='0' when state = st_Turn else '1';

--enterCode <= '1' when state = st_Code else '0';

frame_received <= '1' when state= st_Start_Game; --or state = st_Code or state = st_FR_R or ((state = st_W_FR or state = st_W_FR2 ) and 
--(EQ_RECEIVED = '1' or GR_RECEIVED = '1' or SM_RECEIVED = '1')) else '0';

end;