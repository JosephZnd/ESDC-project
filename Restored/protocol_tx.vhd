library ieee;
use ieee.std_logic_1164.all;

entity protocol_tx is
	port (
		clk50, nrst: in std_logic;
		Send_Dt, Send_Rdy: in std_logic;  -- Frame to transmit.
		Pos_X, Pos_Y : in std_logic_vector(2 downto 0);  -- Byte sent to the UART TX for transmission
		Figure : in std_logic_vector(2 downto 0);  -- Data to trasmit if FRAME is DATA.
		Ready_To_Tx, Send : out std_logic;
		Tx_Data: out std_logic_vector(7 downto 0);  -- Flag. Active high if protocol is ready to tx (not transmiting a frame)
											-- send: to the UART. Active to send a new byte.
		tx_empty : in std_logic  -- Signal from the UART TX. Active if new byte can be transmitted.
		);
end protocol_tx;


architecture main of protocol_tx is
	type state_type is (st_pr_wait, st_pr_rdy, st_to_send_rdy, st_send_rdy, st_to_send_type, st_send_type, st_pr_dt,
	st_to_send_x, st_send_x, st_to_send_y, st_send_y, st_to_send_figure, st_send_figure, st_finish_Tx );
	 
	 -- Definition of the diferent FRAME TYPE
	constant RDY_TO_PLAY : std_logic_vector(7 downto 0) := x"A1";
	constant WHITES : std_logic_vector(7 downto 0) := x"51";
	
	constant WHITE_PAWN : std_logic_vector(7 downto 0) := x"01";
	constant WHITE_QUEEN : std_logic_vector(7 downto 0) := x"02";
	constant BLACK_PAWN : std_logic_vector(7 downto 0) := x"07";
	constant BLACK_QUEEN : std_logic_vector(7 downto 0) := x"06";
	
	constant ADDRESS : std_logic_vector(7 downto 0) := x"AD";
	
	constant FRAME_ID : std_logic_vector(7 downto 0) := x"AA";

	-- Definition of the state register
	
	signal state : state_type;
	
	-- Definition of the registers in the process unit
	signal s_whites : std_logic:='0';
	signal frame_type: std_logic_vector(7 downto 0);
	signal i_Pos_X, i_Pos_Y : std_logic_vector(2 downto 0);  -- Data to trasmit if FRAME is DATA.
	signal i_Figure : std_logic_vector(2 downto 0);
	
begin

PROTOCOL_FSM : process (clk50, nrst) begin
	if nrst = '0' then
		state <= st_pr_wait;
		ready_to_tx <= '1';
	elsif clk50'EVENT and clk50 = '1' then
		case state is
			
			when st_pr_wait =>
				if SEND_DT = '1' then 
					state <= st_pr_dt; 
					i_Pos_X <= Pos_X;
					i_Pos_Y <= Pos_Y;
					i_Figure <= Figure;
				elsif Send_Rdy = '1' then
					state <= st_pr_rdy;
				else state <= st_pr_wait; end if;

			-- Filling TX_DATA with frame ID and updating FRAME_TYPE.	
			when st_pr_rdy => 
				ready_to_tx <= '0';
				frame_type <= RDY_TO_PLAY;
				Tx_Data <= FRAME_ID;
				state <= st_to_send_rdy;
			
			when st_to_send_rdy => state <= st_send_rdy;
			
			when st_send_rdy =>
				if tx_empty = '1' then
					Tx_Data <= frame_type;
					state <= st_finish_Tx;
				end if;
				
			when st_pr_dt => 
				ready_to_tx <= '0';
				frame_type <= ADDRESS;
				Tx_Data <= FRAME_ID;
				state <= st_to_send_type;	
			
			when st_to_send_type => state <= st_send_type;
				
			when st_send_type => 
				if tx_empty = '1' then
					Tx_Data <= frame_type;
					state <= st_to_send_x;
				end if;

			when st_to_send_x => state <= st_send_x;
			
			when st_send_x => 
				if tx_empty = '1' then
					Tx_Data <= "00000" & i_Pos_X;
					state <= st_to_send_y;
				end if;

			when st_to_send_y => state <= st_send_y;
				
			when st_send_y => 
				if tx_empty = '1' then
					Tx_Data <= "00000" & i_Pos_Y;
					state <= st_to_send_figure;
				end if;
	
			when st_to_send_figure => state <= st_send_figure;
			
			when st_send_figure => 
				if tx_empty = '1' then
					Tx_Data <= "00000" & i_Figure;
					state <= st_finish_Tx;
				end if;
				
			when st_finish_Tx => 
				state <= st_pr_wait;
				ready_to_tx <= '1';
				
			when others =>
				end case;
	end if;
end process;

-- Activation of the signal SEND when the state is any of the pr_s

send <= '1' when state = st_pr_rdy or state = st_pr_dt or state = st_send_rdy or state = st_send_x or state = st_send_y or state = st_send_figure;
end;