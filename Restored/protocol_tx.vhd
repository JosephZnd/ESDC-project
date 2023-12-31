library ieee;
use ieee.std_logic_1164.all;

entity protocol_tx is
	port (
		clk50, nrst: in std_logic;
		SEND_RDY, SEND_WHITES, SEND_EQ, SEND_SM, SEND_DT: in std_logic;  -- Frame to transmit.
		tx_data : out std_logic_vector(7 downto 0);  -- Byte sent to the UART TX for transmission
		dataH, dataT, dataU : in std_logic_vector(3 downto 0);  -- Data to trasmit if FRAME is DATA.
		ready_to_TX, send : out std_logic;  -- Flag. Active high if protocol is ready to tx (not transmiting a frame)
											-- send: to the UART. Active to send a new byte.
		tx_empty : in std_logic  -- Signal from the UART TX. Active if new byte can be transmitted.
		);
end protocol_tx;


architecture main of protocol_tx is
	type state_type is (pr_wait, pr_rdy, pr_gr, pr_sm, pr_eq, pr_dt, pr_s1, pr_w1, pr_s2, pr_w2,
	 pr_check_data, pr_s3, pr_w3, pr_s4, pr_w4, pr_s5, pr_w5, pr_set_TX );
	 
	 -- Definition of the diferent FRAME TYPE
	constant RDY_TO_PLAY : std_logic_vector(7 downto 0) := x"A1";
	constant CODE : std_logic_vector(7 downto 0) := x"A3";
	constant WHITES : std_logic_vector(7 downto 0) := x"51";
	constant SMALLER : std_logic_vector(7 downto 0) := x"53";
	constant EQUAL : std_logic_vector(7 downto 0) := x"55";
	
	constant FRAME_ID : std_logic_vector(7 downto 0) := x"AA";

	-- Definition of the state register
	
	signal state : state_type;
	
	-- Definition of the registers in the process unit
	signal s_whites : std_logic:='0';
	signal frame_type: std_logic_vector(7 downto 0);
	signal dataH_i, dataT_i, dataU_i : std_logic_vector(3 downto 0);  -- Data to trasmit if FRAME is DATA.
	
begin

PROTOCOL_FSM : process (clk50, nrst) begin
	if nrst = '0' then
		state <= pr_wait;
		ready_to_tx <= '1';
	elsif clk50'EVENT and clk50 = '1' then
		case state is
			
			when pr_wait =>
				if SEND_RDY = '1' then state <= pr_rdy; 
				elsif ((SEND_WHITES = '1') and  (s_whites ='0')) then state <= pr_gr;
				elsif SEND_EQ = '1' then state <= pr_eq; 
				elsif SEND_SM = '1' then state <= pr_sm; 
				elsif SEND_DT = '1' then 
					state <= pr_dt; 
					dataH_i <= dataH;
					dataT_i <= dataT;
					dataU_i <= dataU;
				else state <= pr_wait; end if;

			-- Filling TX_DATA with frame ID and updating FRAME_TYPE.	
			when pr_rdy => 
				ready_to_tx <= '0';
				frame_type <= RDY_TO_PLAY;
				tx_data <= FRAME_ID;
				state <= pr_s1;
			when pr_gr => 
				s_whites <='1';
				ready_to_tx <= '0';
				frame_type <= WHITES;
				tx_data <= FRAME_ID;
				state <= pr_s1;	
			when pr_eq => 
				ready_to_tx <= '0';
				frame_type <= EQUAL;
				tx_data <= FRAME_ID;
				state <= pr_s1;
			when pr_sm => 
				ready_to_tx <= '0';
				frame_type <= SMALLER;
				tx_data <= FRAME_ID;
				state <= pr_s1;
			when pr_dt => 
				ready_to_tx <= '0';
				frame_type <= CODE;
				tx_data <= FRAME_ID;
				state <= pr_s1;	
				
			-- Sending FRAME_ID. SEND should be activated with a combinational system. 
			when pr_s1 =>
				state <= pr_w1;
				
			when pr_w1 =>
				if tx_empty = '1' then 
					state <= pr_s2;
					tx_data <= frame_type;
				end if;
				
			-- Sending FRAME TYPE. Send should be activated with a combinational system.	
			when pr_s2 =>
				state <= pr_w2;
					
			when pr_w2 =>
				if tx_empty = '1' then 
					state <= pr_check_data;
				end if;
				
			-- Checking if FRAME TYPE is DATA. If so, 3 bytes with data should be sent.
			when pr_check_data => 
				if frame_type = CODE then
					state <= pr_s3;
					tx_data <= x"0" & dataH_i;
				else
					state <= pr_set_TX;
				end if;
				
			-- IF DATA. Let's send the 3 data bytes.
			-- Sending hundreds. Send should be activated with a combinational system.
			when pr_s3 =>
				state <= pr_w3;
					
			when pr_w3 =>
				if tx_empty = '1' then 
					state <= pr_s4;
					tx_data <= x"0" & dataT_i;
				end if;
				
			when pr_s4 =>
				state <= pr_w4;
					
			when pr_w4 =>
				if tx_empty = '1' then 
					state <= pr_s5;
					tx_data <= x"0" & dataU_i;
				end if;
				
			when pr_s5 =>
				state <= pr_w5;
					
			when pr_w5 =>
				if tx_empty = '1' then 
					state <= pr_set_TX;
				end if;
			
			-- Final STATE. The frame has been sent. TX_EMPTY should be set to 1
			
			when pr_set_TX => 
				state <= pr_wait;
				ready_to_tx <= '1';
			when others =>
				end case;
	end if;
end process;

-- Activation of the signal SEND when the state is any of the pr_s

send <= '1' when state = pr_s1 or state = pr_s2 or state = pr_s3 or state = pr_s4 or state = pr_s5 else '0';
end;