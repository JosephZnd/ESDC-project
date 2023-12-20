library ieee;
use ieee.std_logic_1164.all;

entity protocol_rx is
	port (
		clk50, nrst: in std_logic;
		RDY_RECEIVED, GR_RECEIVED, EQ_RECEIVED, SM_RECEIVED, DT_RECEIVED: out std_logic;  -- Frame received.
		rx_data : in std_logic_vector(7 downto 0);  -- Byte received from the UART RX
		dataH, dataT, dataU : out std_logic_vector(3 downto 0);  -- Data received if FRAME is DATA.
		data_read,new_frame : out std_logic;  -- Flag. Active high if protocol is ready to tx (not transmiting a frame)
											-- new_frame: active if a new frame is received.
		rx_new, frame_read : in std_logic  -- Signal from the UART RX. Active if new byte has been received.
										   -- Frame READ: frame has been read. Frame received has to be deactivated.
		);
end protocol_rx;


architecture main of protocol_rx is
	type state_type is (pr_ini, pr_w1, pr_r1, pr_w2, pr_r2, pr_f_type, pr_s_rdy, pr_s_gr, pr_s_sm,
	pr_s_eq, pr_w3, pr_r3, pr_w4, pr_r4, pr_w5, pr_r5, pr_s_dt );
	 
	 -- Definition of the diferent FRAME TYPE
	constant RDY_TO_PLAY : std_logic_vector(7 downto 0) := x"A1";
	constant CODE : std_logic_vector(7 downto 0) := x"A3";
	constant GREATHER : std_logic_vector(7 downto 0) := x"51";
	constant SMALLER : std_logic_vector(7 downto 0) := x"53";
	constant EQUAL : std_logic_vector(7 downto 0) := x"55";
	
	constant FRAME_ID : std_logic_vector(7 downto 0) := x"AA";

	-- Definition of the state register
	
	signal state : state_type;
	
	-- Definition of the registers in the process unit

	signal frame_type: std_logic_vector(7 downto 0);
	
	-- Signals to activate the output flags
	signal set_RDY_RECEIVED, set_GR_RECEIVED, set_EQ_RECEIVED, set_SM_RECEIVED, set_DT_RECEIVED : std_logic;
	signal set_new_frame : std_logic;
	
begin

PROTOCOL_FSM : process (clk50, nrst) begin
	if nrst = '0' then
		state <= pr_ini;

	elsif clk50'EVENT and clk50 = '1' then
		case state is
			when pr_ini => 
				state <= pr_w1;
			
			-- Waiting for frame_ID to arrive
			when pr_w1 =>
				if rx_new = '1' then state <= pr_r1;
				end if;

			-- Frame ID arrived. We do not check it..	
			-- Data_read should be activated within a combinational system
			when pr_r1 => 
				state <= pr_w2;
				
			-- Waiting for FRAME TYPE to arive
			when pr_w2 => 
				if rx_new = '1' then state <= pr_r2;
				end if;	
			-- FRAME TYPE ARRIVED. 
			-- Data Read should be activated within a combinational system	
			when pr_r2 => 
				frame_type <= rx_data;
				state <= pr_f_type;
				
			-- Checking frame type. If type is data the system read 3 extra bytes.	
			when pr_f_type => 
				if frame_type = RDY_TO_PLAY then state <= pr_s_rdy;
				elsif frame_type = GREATHER then state <= pr_s_gr;
				elsif frame_type = SMALLER then state <= pr_s_sm;
				elsif frame_type = EQUAL then state <= pr_s_eq;
				elsif frame_type = CODE then state <= pr_w3;
				end if;
				
			-- Activation of flags if frame is not CODE
			-- Flags should be activated within a combinational system.
			when pr_s_rdy =>
				state <= pr_ini;
				
			when pr_s_gr =>
				state <= pr_ini;
				
			when pr_s_sm =>
				state <= pr_ini;
				
			when pr_s_eq =>
				state <= pr_ini;
				
			-- If FRAME is CODE, three extra bytes should be transmited.
			-- Waiting for Hundreds to arive
			when pr_w3 => 
				if rx_new = '1' then state <= pr_r3;
				end if;	
			-- HUNDREDS ARRIVED. 
			-- Data Read should be activated within a combinational system	
			when pr_r3 => 
				dataH <= rx_data(3 downto 0);
				state <= pr_w4;
				
			-- Waiting for tens to arive
			when pr_w4 => 
				if rx_new = '1' then state <= pr_r4;
				end if;	
			-- TENS ARRIVED. 
			-- Data Read should be activated within a combinational system	
			when pr_r4 => 
				dataT <= rx_data(3 downto 0);
				state <= pr_w5;	
				
			-- Waiting for units to arive
			when pr_w5 => 
				if rx_new = '1' then state <= pr_r5;
				end if;	
			-- UNITS ARRIVED. 
			-- Data Read should be activated within a combinational system	
			when pr_r5 => 
				dataU <= rx_data(3 downto 0);
				state <= pr_s_dt;
				
			-- Activation of the CODE Flag
			-- Activation must be done in a combinational system
			when pr_s_dt =>
				state <= pr_w1;	
			
			when others =>
				end case;
	end if;
end process;


-- Combinational system for the signals that activate
set_RDY_RECEIVED <= '1' when state = pr_s_rdy else '0'; 
set_GR_RECEIVED <= '1' when state = pr_s_gr else '0';
set_EQ_RECEIVED <= '1' when state = pr_s_eq else '0';
set_SM_RECEIVED <= '1' when state = pr_s_sm else '0';
set_DT_RECEIVED <= '1' when state = pr_s_dt else '0';
data_read <= '1' when state = pr_r1 or state = pr_r2 or state = pr_r3 or 
	state = pr_r4 or state = pr_r5 else '0';

JK: process(clk50, nrst) begin
		if nrst = '0' then
			RDY_RECEIVED <= '0'; 
			GR_RECEIVED <= '0';
			EQ_RECEIVED <= '0';
			SM_RECEIVED <= '0';
			DT_RECEIVED <= '0'; 
			new_frame <= '0';
		elsif clk50'EVENT and clk50 = '1' then 
			if set_RDY_RECEIVED = '1' then RDY_RECEIVED <= '1'; new_frame <= '1'; end if;
			if set_GR_RECEIVED = '1' then GR_RECEIVED <= '1'; new_frame <= '1'; end if;
			if set_EQ_RECEIVED = '1' then EQ_RECEIVED <= '1'; new_frame <= '1'; end if;
			if set_SM_RECEIVED = '1' then SM_RECEIVED <= '1'; new_frame <= '1'; end if;
			if set_DT_RECEIVED = '1' then DT_RECEIVED <= '1'; new_frame <= '1'; end if;
			if frame_read = '1' then
				RDY_RECEIVED <= '0';
				new_frame <= '0'; 
				GR_RECEIVED <= '0'; 
				EQ_RECEIVED <= '0';
				SM_RECEIVED <= '0'; 
				DT_RECEIVED <= '0';
			end if;
		end if;
	end process;
		
end;