library ieee;
use ieee.std_logic_1164.all;

entity rx_block is
		port (	clk, nrst, UART_RXD, frame_read: in std_logic;
				RD_R, GR_R, EQ_R, SM_R, DT_R : out std_logic;
				OponentH, OponentT, OponentU: out std_logic_vector(3 downto 0)
			);
end rx_block;

architecture main of rx_block is
------------------------------------------------------
signal s_data_read: std_logic;
signal s_byte_rx: std_logic_vector(7 downto 0);
signal s_new_rx: std_logic;
------------------------------------------------------
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

component rx_module2 
			port( 	clk, nrst, rx, data_read : in std_logic;
					rx_data : out std_logic_vector(7 downto 0);   
					rx_new, rx_data_lost  : out std_logic
			);
end component;



begin

rx_mod: rx_module2 port map(
							clk => clk,
							nrst => nrst,
							rx => UART_RXD,
							data_read => s_data_read,
							rx_data => s_byte_rx,
							rx_new => s_new_rx
							);
rx_p: protocol_rx port map(
							clk50 => clk,
							nrst => nrst,
							rx_data => s_byte_rx,
							rx_new => s_new_rx,
							frame_read => frame_read,
							RDY_RECEIVED => RD_R,
							GR_RECEIVED => GR_R,
							EQ_RECEIVED => EQ_R,
							SM_RECEIVED => SM_R,
							DT_RECEIVED => DT_R,
							dataH => OponentH,
							dataT => OponentT,
							dataU => OponentU,
							data_read => s_data_read
							);
end;