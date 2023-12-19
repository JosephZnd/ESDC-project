library ieee;
use ieee.std_logic_1164.all;

entity protocol_rx is
	port (
		clk50, nrst: in std_logic;
		rx_data : in std_logic_vector(7 downto 0);  -- Byte received from the UART RX
		rx_new, frame_read : in std_logic;  -- Signal from the UART RX. Active if new byte has been received.
										   -- Frame READ: frame has been read. Frame received has to be deactivated.
		WHITES_RECEIVED, RDY_RECEIVED, DT_RECEIVED: out std_logic;  -- Frame received.
		address_received : out std_logic_vector(5 downto 0);
		piece : out std_logic_vector(2 downto 0);  -- Data received if FRAME is DATA.
		data_read,new_frame, frame_final : out std_logic  -- Flag. Active high if protocol is ready to tx (not transmiting a frame)
											-- new_frame: active if a new frame is received.
		
		);
end protocol_rx;


architecture main of protocol_rx is
	type state_type is (pr_ini, pr_w1, pr_r1, pr_w2, pr_r2, pr_f_type, pr_s_rdy, pr_s_wh, pr_w3, pr_r3, pr_w4, pr_r4, pr_w5, pr_r5, pr_s_dt, pr_s_dt_init );
	 
	 -- Definition of the diferent FRAME TYPE
	constant RDY_TO_PLAY : std_logic_vector(7 downto 0) := x"A1";
	constant FIGURE : std_logic_vector(7 downto 0) := x"A6";	
	constant POSX : std_logic_vector(7 downto 0) := x"B2";
	constant POSY : std_logic_vector(7 downto 0) := x"C3";
	
	constant FRAME1 : std_logic_vector(7 downto 0) := x"D4";
	constant FRAME2 : std_logic_vector(7 downto 0) := x"E1";
	constant FRAME3 : std_logic_vector(7 downto 0) := x"E5";

	constant WHITES : std_logic_vector(7 downto 0) := x"F6";
	
	constant FRAME_ID : std_logic_vector(7 downto 0) := x"AA";

	-- Definition of the state register
	
	signal state : state_type;
	
	-- Definition of the registers in the process unit

	signal frame_type: std_logic_vector(7 downto 0);
	signal s_old_X, s_old_Y : std_logic_vector(2 downto 0);
	-- Signals to activate the output flags
	signal set_RDY_RECEIVED, set_WHITES_RECEIVED, set_DT_RECEIVED: std_logic;
	signal set_new_frame,  set_frame_final : std_logic;
	
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
				elsif frame_type = WHITES then state <= pr_s_wh;
				elsif frame_type = FRAME1 OR frame_type = FRAME2 or frame_type = FRAME3 then state <= pr_w3;
				end if;
				
			-- Activation of flags if frame is not CODE
			-- Flags should be activated within a combinational system.
			when pr_s_rdy =>
				state <= pr_ini;
				
			when pr_s_wh =>
				state <= pr_ini;
			
				
			-- If FRAME is CODE, three extra bytes should be transmited.
			-- Waiting for Hundreds to arive
			when pr_w3 => 
				if rx_new = '1' then state <= pr_r3;
				end if;	
			-- HUNDREDS ARRIVED. 
			-- Data Read should be activated within a combinational system	
			when pr_r3 => 
				s_old_X <= rx_data(2 downto 0);
				state <= pr_w4;
				
			-- Waiting for tens to arive
			when pr_w4 => 
				if rx_new = '1' then state <= pr_r4;
				end if;	
			-- TENS ARRIVED. 
			-- Data Read should be activated within a combinational system	
			when pr_r4 => 
				s_old_Y <= rx_data(2 downto 0);
				state <= pr_w5;	
				
			-- Waiting for units to arive
			when pr_w5 =>
				address_received <= s_old_Y & s_old_X;
				if rx_new = '1' then state <= pr_r5;
				end if;	
			-- UNITS ARRIVED. 
			-- Data Read should be activated within a combinational system	
			when pr_r5 => 
				piece <= rx_data(2 downto 0);
				if frame_type = FRAME2 then
					state <= pr_s_dt_init; --case first or second frame
				elsif frame_type = FRAME1 or frame_type = FRAME3 then state <= pr_s_dt;
				end if;
				
			-- Activation of the CODE Flag
			-- Activation must be done in a combinational system
			when pr_s_dt =>
				state <= pr_w1;	 --case third frame
			when pr_s_dt_init =>
				state <= pr_w1;
			
			when others =>
				end case;
	end if;
end process;


-- Combinational system for the signals that activate
frame_final <= '1' when state = pr_s_dt_init else '0';
set_RDY_RECEIVED <= '1' when state = pr_s_rdy else '0'; 
set_WHITES_RECEIVED <= '1' when state = pr_s_wh else '0';
set_DT_RECEIVED <= '1' when state = pr_s_dt else '0';
data_read <= '1' when state = pr_r1 or state = pr_r2 or state = pr_r3 or 
	state = pr_r4 or state = pr_r5 else '0';

JK: process(clk50, nrst) begin
		if nrst = '0' then
			RDY_RECEIVED <= '0'; 
			WHITES_RECEIVED <= '0';
			DT_RECEIVED <= '0'; 
			new_frame <= '0';
		elsif clk50'EVENT and clk50 = '1' then 
			if set_RDY_RECEIVED = '1' then RDY_RECEIVED <= '1'; new_frame <= '1'; end if;
			if set_WHITES_RECEIVED = '1' then WHITES_RECEIVED <= '1'; new_frame <= '1'; end if;
			if set_DT_RECEIVED = '1' then DT_RECEIVED <= '1'; new_frame <= '1'; end if;
			if frame_read = '1' then
				RDY_RECEIVED <= '0';
				new_frame <= '0'; 
				WHITES_RECEIVED <= '0'; 
				DT_RECEIVED <= '0';
			end if;
		end if;
	end process;
		
end;