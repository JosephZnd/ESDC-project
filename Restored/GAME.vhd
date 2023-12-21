library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH;

entity game is
	port (
		clk50, nrst: in std_logic;
		New_Game, Sel : in std_logic;  
		RDY_RECEIVED, GR_RECEIVED, EQ_RECEIVED, SM_RECEIVED, DT_RECEIVED: in std_logic;  
		Pos_X, Pos_Y : in std_logic_vector(2 downto 0);
		In_Piece : in std_logic_vector(2 downto 0);
		bank_ready, ready_to_TX, Turn, Color: in std_logic;  
		SEND_RDY, SEND_GR, SEND_EQ, SEND_SM, SEND_DT : out std_logic;
		frame_received : out std_logic;
		enterCode, led_turn, turn_read, freeze_kb : out std_logic;
		Addr_W, Addr_R : out std_logic_vector(5 downto 0);
		X_To_Sent, Y_To_Sent, Write_Piece: out std_logic_vector(2 downto 0));
end game;


architecture main of game is
	type state_type is (st_Wait_Game, st_W_Tx1, st_S_Rdy, st_W_Rdy, st_Start_Game, st_Turn, st_Wait_Turn, st_Read_Ram, st_Check_Piece, st_Check_Second_Move, st_Capture, st_Check_capture,
	st_Move_Piece, st_Write_Ram, st_Invalid_Move, st_Finish_Turn);
	
	signal state : state_type;
	signal s_whites : std_logic:='0';
	signal while_Capturing : std_logic:='0';
	signal sel_Selected : std_logic:='0';
	signal piece_Moved : std_logic:='0';
	signal checking_Second_Move: std_logic:='0';
	
	signal counter : STD_LOGIC_VECTOR(3 downto 0) := "0000";
	
	signal sel_X : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal sel_Y : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal old_X : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal old_Y : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal to_Move_X : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal to_Move_Y : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal pos_To_Capture_X : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal pos_To_Capture_Y : STD_LOGIC_VECTOR(2 downto 0) := "000";
	
	
	signal piece_To_Move: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal piece_To_Capture : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal arriving_Cell: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal piece_To_Write: STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal last_Piece: STD_LOGIC_VECTOR(2 downto 0) := "000";

	
	signal s_Addr_R : STD_LOGIC_VECTOR(5 downto 0) := "000000";
	signal s_Addr_W : STD_LOGIC_VECTOR(5 downto 0) := "000000";
	signal address_To_Capture : STD_LOGIC_VECTOR(5 downto 0) := "000000";
	
begin

process (clk50, nrst, In_Piece) 
	variable int_To_Move_X, int_To_Move_Y, int_Old_X, int_Old_Y, int_Pos_To_Capture_X, int_Pos_To_Capture_Y : integer range 0 to 7;
	begin
	if nrst = '0' then
		state <= st_Wait_Game;
	elsif clk50'event and clk50 = '1' then
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
				sel_X <= Pos_X;
				sel_Y <= Pos_Y;
				if( Sel='1')then --don't write rising edge here
					if(sel_Selected = '0') then
						old_X <= sel_X; --pero que no se lea en Game hasta que no se pulsa Sel
						old_Y <= sel_Y;
						s_Addr_R <= old_X & old_Y;
						state <= st_Read_Ram;
					else
						to_Move_X <= sel_X;
						to_Move_Y <= sel_Y;
						s_Addr_R <= old_X & old_Y;
						state <= st_Read_Ram;
					end if;
				end if;
				
			when st_Read_Ram =>
					if last_Piece /= In_Piece then
						last_Piece <= In_Piece;
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
				int_To_Move_X := to_integer(unsigned(to_Move_X));
				int_To_Move_Y := to_integer(unsigned(to_Move_Y));
				int_Old_X := to_integer(unsigned(old_X));
				int_Old_Y := to_integer(unsigned(old_Y));
				if (int_To_Move_X = int_Old_X+1 and int_To_Move_Y = int_Old_Y+1) then	
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif int_To_Move_X = int_Old_X +1 and int_To_Move_Y = int_Old_Y-1 then
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif int_To_Move_X = int_Old_X -1 and int_To_Move_Y = int_Old_Y+1 then
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif int_To_Move_X = int_Old_X -1 and int_To_Move_Y = int_Old_Y-1 then
					if arriving_cell = "100" then
						state <= st_Move_Piece;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif int_To_Move_X = int_Old_X +2 and int_To_Move_Y = int_Old_Y+2 then	
					if arriving_Cell = "100" then
						state <= st_Capture;
						int_Pos_To_Capture_X := int_Old_X+1;
						int_Pos_To_Capture_Y := int_Old_Y+1;
					else 
						state <= st_Invalid_Move;
					end if;

				elsif int_To_Move_X = int_Old_X +2 and int_To_Move_Y = int_Old_Y-2 then
					if arriving_Cell = "100" then
						int_Pos_To_Capture_X := int_Old_X+1;
						int_Pos_To_Capture_Y := int_Old_Y-1;
						state <= st_Capture;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif int_To_Move_X = int_Old_X -2 and int_To_Move_Y = int_Old_Y+2 then
					if arriving_Cell = "100" then
						int_Pos_To_Capture_X := int_Old_X-1;
						int_Pos_To_Capture_Y := int_Old_Y+1;
						state <= st_Capture;
					else 
						state <= st_Invalid_Move;
					end if;
				elsif int_To_Move_X = int_Old_X -2 and int_To_Move_Y = int_Old_Y-2 then
					if arriving_Cell = "100" then
						int_Pos_To_Capture_X := int_Old_X-1;
						int_Pos_To_Capture_Y := int_Old_Y-1;
						state <= st_Capture;
					else 
						state <= st_Invalid_Move;
					end if;	
				else 
					state <= st_Invalid_Move;
				end if;	
				
			when st_Capture =>
				pos_To_Capture_X <= std_logic_vector(to_unsigned(int_Pos_To_Capture_X, 3));
				pos_To_Capture_Y <= std_logic_vector(to_unsigned(int_Pos_To_Capture_Y, 3));
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
					s_Addr_W <= pos_To_Capture_X & pos_To_Capture_Y;
					piece_To_Write <= "100";
					state <= st_Write_Ram; 
				elsif piece_Moved = '1' then
					s_Addr_W <= old_X & old_Y;
					piece_To_Write <= "100";
					state <= st_Write_Ram;
				else 
					s_Addr_W <= to_Move_X & to_Move_Y;
					piece_To_Write <= piece_To_Move;
					state <= st_Write_Ram;
				end if;
				
			when st_Write_Ram => 
				counter <= counter +1;
				if counter = "1111" then
					if checking_Second_Move = '1' then 
						state <= st_Turn;
					elsif while_Capturing = '1' then
						while_Capturing <= '0';
						piece_Moved <= '1';
						state <= st_Move_Piece;
					elsif piece_Moved = '1' then
						piece_Moved <= '0';
						state <= st_Finish_Turn;
					end if;
				end if;
				
			when st_Invalid_Move =>
				sel_Selected <= '0';
				while_Capturing <='0';
				piece_Moved <='0';
				checking_Second_Move <='0'; 
				state <= st_Turn;	
				
			when st_Finish_Turn =>
				sel_Selected <= '0';
				while_Capturing <='0';
				piece_Moved <='0';
				checking_Second_Move <='0'; 
				state <= st_Wait_Turn;
				
		
			when others =>
				end case; 
	end if;
end process;
Addr_W <= s_Addr_W when state = st_Write_Ram;
Addr_R <= s_Addr_W when state = st_Read_Ram;
Write_Piece <= piece_To_Write when state = st_Write_Ram;

Y_TO_Sent <= s_Addr_W(5 downto 3) when state = st_Write_Ram;
X_To_Sent <= s_Addr_W(2 downto 0) when state = st_Write_Ram;

SEND_DT <= '1' when state = st_Write_Ram else '0';

led_turn <='1' when state = st_Turn else '0';

turn_read <='1' when state = st_Turn else '0';
freeze_kb <='0' when state = st_Turn else '1';

--enterCode <= '1' when state = st_Code else '0';

frame_received <= '1' when state= st_Start_Game; --or state = st_Code or state = st_FR_R or ((state = st_W_FR or state = st_W_FR2 ) and 
--(EQ_RECEIVED = '1' or GR_RECEIVED = '1' or SM_RECEIVED = '1')) else '0';

end;