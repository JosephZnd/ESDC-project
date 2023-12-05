library ieee;
use ieee.std_logic_1164.all;

entity Design1 is
	port (clk, nrst:in std_logic;
		TX_RDY, TX_GR, TX_EQ, TX_SM, TX_DT, FR_Read: in std_logic;
		TX_DATAH, TX_DATAT, TX_DATAU: in std_logic_vector(3 downto 0);
		RDY_RX, GREATHER_RX, EQUAL_RX, SMALLER_RX,DATA_RX: out std_logic;
		DataH_RX, DataT_RX, DataU_RX: out std_logic_vector(3 downto 0);
		Ready_to_TX: out std_logic;
		new_FR_RX: out std_logic					   
		);
end Design1;


architecture main of Design1 is

------------------------------------------------------------------------------------------------
signal s_tx_empty: std_logic;
signal s_send: std_logic;
signal s_tx_data: std_logic_vector(7 downto 0);
signal s_serial: std_logic;
signal s_data_read: std_logic;
signal s_rx_data: std_logic_vector(7 downto 0);
signal s_rx_new: std_logic;
------------------------------------------------------------------------------------------------
	
component rx_module2 
			port( 	clk, nrst, rx, data_read : in std_logic;
					rx_data : out std_logic_vector(7 downto 0);   
					rx_new, rx_data_lost  : out std_logic
			);
end component;

component tx_module
			port (	clk, nrst, send : in std_logic;
					tx_data : in std_logic_vector(7 downto 0);
					tx, tx_empty : out std_logic
			);
end component;

component protocol_tx
			port (
					clk50, nrst: in std_logic;
					SEND_RDY, SEND_GR, SEND_EQ, SEND_SM, SEND_DT: in std_logic;  -- Frame to transmit.
					tx_data : out std_logic_vector(7 downto 0);  -- Byte sent to the UART TX for transmission
					dataH, dataT, dataU : in std_logic_vector(3 downto 0);  -- Data to trasmit if FRAME is DATA.
					ready_to_TX, send : out std_logic;  -- Flag. Active high if protocol is ready to tx (not transmiting a frame)
														-- send: to the UART. Active to send a new byte.
					tx_empty : in std_logic  -- Signal from the UART TX. Active if new byte can be transmitted.
			);
end component;

component protocol_rx
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
end component;

begin

u1: 	protocol_tx port map(	clk50 => clk,
								nrst => nrst,
								SEND_RDY => TX_RDY,
								SEND_GR => TX_GR,
								SEND_EQ => TX_EQ,
								SEND_SM => TX_SM,
								SEND_DT => TX_DT,
								dataH => TX_DATAH,
								dataT => TX_DATAT,
								dataU => TX_DATAU,
								tx_empty => s_tx_empty,
								ready_to_TX => Ready_to_TX,	
								send => s_send,
								tx_data => s_tx_data
		);

u2: 	tx_module port map(		clk => clk,
								nrst => nrst,
								send => s_send,
								tx_data => s_tx_data,
								tx => s_serial,
								tx_empty => s_tx_empty
		);

u3: 	rx_module2 port map(	rx => s_serial,
								nrst => nrst,
								clk => clk,
								data_read => s_data_read,
								rx_data => s_rx_data,
								rx_new => s_rx_new
		);
								
u4:		protocol_rx port map(	clk50 => clk,
								nrst => nrst,
								rx_data => s_rx_data,
								rx_new => s_rx_new,
								frame_read => FR_Read,
								RDY_RECEIVED => RDY_RX,
								GR_RECEIVED => GREATHER_RX,
								EQ_RECEIVED => EQUAL_RX,
								SM_RECEIVED => SMALLER_RX,
								DT_RECEIVED => DATA_RX,
								dataH => DataH_RX,
								dataT => DataT_RX,
								DataU => DataU_RX,
								new_frame => new_FR_RX,
								data_read => s_data_read
		);





end;