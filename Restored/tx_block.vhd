library ieee;
use ieee.std_logic_1164.all;

entity tx_block is
		port(
			clk, nrst, send_RDY, send_GR, send_EQ, send_SM, send_D: in std_logic;
			GuessH, GuessT, GuessU: in std_logic_vector (3 downto 0);
			UART_TXD, TX_ready: out std_logic
		);
end tx_block;

architecture main of tx_block is
------------------------------------------------------
signal s_send: std_logic;
signal s_tx_data: std_logic_vector(7 downto 0);
signal s_UART_TX_READY: std_logic;
------------------------------------------------------
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


begin

p_tx: protocol_tx port map (
							clk50 => clk,
							nrst => nrst,
							SEND_RDY => send_RDY,
							SEND_GR => send_GR,
							SEND_EQ => send_EQ,
							SEND_SM => send_SM,
							SEND_DT => send_D,
							dataH => GuessH,
							dataT => GuessT,
							dataU => GuessU,
							tx_empty => s_UART_TX_READY,
							send => s_send,
							tx_data => s_tx_data,
							ready_to_TX => TX_ready
							);
mod_tx: tx_module port map (
							clk => clk,
							nrst => nrst,
							send => s_send,
							tx_data => s_tx_data,
							tx => UART_TXD,
							tx_empty => s_UART_TX_READY
							);
							
end;