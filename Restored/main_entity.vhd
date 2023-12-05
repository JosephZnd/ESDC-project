library ieee;
use ieee.std_logic_1164.all;

entity main_entity is
			port(
				OSC_50, UART_RXD, KEY: in std_logic;
				COL: in std_logic_vector (3 downto 0);
				UART_TXD: out std_logic;
				ROW: out std_logic_vector (3 downto 0);
				HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7: out std_logic_vector (6 downto 0);
				VGA_R, VGA_G, VGA_B: out std_logic_vector(9 downto 0);
				LED_RED:out std_logic_vector (2 downto 0);
				LED_GREEN: out std_logic_vector (7 downto 0);
				VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK, nrst: out std_logic
			);
end main_entity;

architecture main of main_entity is
------------------------------------------------------------------------------------------------
signal s_frame_read, s_RD_R, s_GR_R, s_EQ_R, s_SM_R, s_DT_R: std_logic; --RX
signal s_OponentH, s_OponentT, s_OponentU: std_logic_vector(3 downto 0);--RX
signal s_send_RDY, s_send_GR, s_send_EQ, s_send_SM, s_send_D, s_TX_ready: std_logic;--Tx
signal s_GuessH, s_GuessT, s_GuessU, s_keycode, s_keycode_in: std_logic_vector (3 downto 0);		--TX	
signal s_hash, s_bcd, s_ast, s_key_read_main, s_key_read_guess, s_key_read_user, s_LED_CODE: std_logic;
signal s_light_enter_guess_code, s_GREATHER, s_SMALLER, s_GAME_OVER: std_logic;
signal s_krey_pressed : std_logic;
signal s_inclk:  std_logic_vector (3 downto 0);
signal s_winner, s_loser, s_tie: std_logic;
signal s_clk, s_nrst: std_logic;
signal s_key_pressed: std_logic;
------------------------------------------------------------------------------------------------
component rx_block
				port (	
					clk, nrst, UART_RXD, frame_read: in std_logic;
					RD_R, GR_R, EQ_R, SM_R, DT_R : out std_logic;
					OponentH, OponentT, OponentU: out std_logic_vector(3 downto 0)
					);
end component;

component tx_block
				port(
					clk, nrst, send_RDY, send_GR, send_EQ, send_SM, send_D: in std_logic;
					GuessH, GuessT, GuessU: in std_logic_vector (3 downto 0);
					UART_TXD, TX_ready: out std_logic
					);
end component;

component big_block
				port (clk, nrst: in std_logic;
						hash, bcd, ast: in std_logic;
						RDY_RECEIVED, GR_RECEIVED, EQ_RECEIVED, SM_RECEIVED, DT_RECEIVED, ready_to_TX: in std_logic;
						keycode, OpponentH, OpponentT, OpponentU: in std_logic_vector(3 downto 0);
						key_read_main, key_read_guess, key_read_user, LED_CODE, SEND_RDY, SEND_GR, SEND_EQ, SEND_SM, SEND_DT, frame_received: out std_logic;
						LightD, LightG, LightS, game_over: out std_logic;
						winner, loser, tie: out std_logic			   
				);
end component;

component keypad
				port (
					clk, nrst    : in  std_logic;
					key          : out std_logic;
					keycode, row : out std_logic_vector(3 downto 0);
					col          : in  std_logic_vector(3 downto 0)
					);
end component; 

component keytest_h_v2 
  port ( clk, nrst   : in  std_logic;
		key         : in std_logic;  -- From the keytest.
		bcd, ast, hash, A, B, C, D: out std_logic;  -- key identifier
		new_code	: out std_logic;  -- activated when there is a new code in the register.
		code_read	: in std_logic;  -- used to de-activate new_code.
		keycode_kt	 : in std_logic_vector(3 downto 0);  -- Keycode from keytest
		keycode      : out std_logic_vector(3 downto 0) );  -- output of the register.
end component;

component  clk_video_altclkctrl_6df
	 PORT 
	 ( 
		 clkselect	:	IN  STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
		 ena	:	IN  STD_LOGIC := '1';
		 inclk	:	IN  STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
		 outclk	:	OUT  STD_LOGIC
	 ); 
END component;
 
component f_div
  port( nrst,clkin : in std_logic; 
        clkout : out std_logic );
end component;

component i_o_manager_vga
	PORT
	(
		BTN0 :  IN  STD_LOGIC;
		GAME_OVER :  IN  STD_LOGIC;
		USER_CODE :  IN  STD_LOGIC;
		GUES_CODE :  IN  STD_LOGIC;
		GREATHER :  IN  STD_LOGIC;
		SMALLER :  IN  STD_LOGIC;
		WINER :  IN  STD_LOGIC;
		LOSER :  IN  STD_LOGIC;
		TIE :  IN  STD_LOGIC;
		CLK_50 :  IN  STD_LOGIC;
		Gues_CodeD :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Gues_CodeH :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Gues_CodeU :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		key_code :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		NC :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Oponent_CodeH :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Oponent_CodeT :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		Oponent_CodeU :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		nrst :  OUT  STD_LOGIC;
		R0 :  OUT  STD_LOGIC;
		R1 :  OUT  STD_LOGIC;
		R2 :  OUT  STD_LOGIC;
		G0 :  OUT  STD_LOGIC;
		G1 :  OUT  STD_LOGIC;
		G2 :  OUT  STD_LOGIC;
		G7 :  OUT  STD_LOGIC;
		G6 :  OUT  STD_LOGIC;
		vga_hs :  OUT  STD_LOGIC;
		bga_vs :  OUT  STD_LOGIC;
		Vga_blank :  OUT  STD_LOGIC;
		Vga_Sync :  OUT  STD_LOGIC;
		VGA_Clock :  OUT  STD_LOGIC;
		B :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
		G :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
		H0 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H3 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H4 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H5 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H6 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		H7 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		R :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END component;

begin

rx_b: rx_block port map(
					clk => s_clk,
					nrst => s_nrst,
					UART_RXD => UART_RXD,
					frame_read => s_frame_read,
					RD_R => s_RD_R,
					GR_R => s_GR_R,
					EQ_R => s_EQ_R,
					SM_R => s_SM_R,
					DT_R => s_DT_R,
					OponentH => s_OponentH,
					OponentT => s_OponentT,
					OponentU => s_OponentU
);
tx_b: tx_block port map(
					clk => s_clk,
					nrst => s_nrst,
					send_RDY => s_send_RDY,
					send_GR => s_send_GR,
					send_EQ => s_send_EQ,
					send_SM => s_send_SM,
					send_D => s_send_D,
					GuessH => s_GuessH,
					GuessT => s_GuessT,
					GuessU => s_GuessU,
					UART_TXD => UART_TXD,
					TX_ready => s_TX_ready
	
);
big_b: big_block port map(
						clk => s_clk, 
						nrst => s_nrst, 
						hash => s_hash, 
						bcd => s_bcd, 
						ast => s_ast, 
						RDY_RECEIVED => s_RD_R, 
						GR_RECEIVED => s_GR_R, 
						EQ_RECEIVED => s_EQ_R, 
						SM_RECEIVED => s_SM_R, 
						DT_RECEIVED => s_DT_R, 
						ready_to_TX => s_TX_ready, 
						keycode => s_keycode,
						OpponentH => s_OponentH,
						OpponentT => s_OponentT,
						OpponentU => s_OponentU,
						key_read_main => s_key_read_main, 
						key_read_guess => s_key_read_guess, 
						key_read_user => s_key_read_user, 
						LED_CODE => s_LED_CODE,
						SEND_RDY => s_send_RDY,
						SEND_GR => s_send_GR,
						SEND_EQ => s_send_EQ,
						SEND_SM => s_send_SM,
						SEND_DT => s_send_D,
						frame_received => s_frame_read,
						LightD => s_light_enter_guess_code,
						LightG => s_GREATHER,
						LightS => s_SMALLER,
						game_over => s_GAME_OVER,
						winner => s_winner,
						loser => s_loser,
						tie => s_tie
);
keyp: keypad port map(
					clk => s_clk,
					nrst => s_nrst,
					col => COL,
					key => s_krey_pressed,
					keycode => s_keycode_in,
					row => ROW
					
);
keyt: keytest_h_v2 port map(
						clk => s_clk,
						nrst => s_nrst,
						key => s_key_pressed,
						code_read => (s_key_read_main OR s_key_read_guess OR s_key_read_user),
						keycode_kt => s_keycode_in,
						bcd => s_bcd, 
						ast => s_ast, 
						hash => s_hash, 
						keycode => s_keycode
);
clk_v: clk_video_altclkctrl_6df port map(
										inclk => s_inclk,
										outclk => s_clk

);
f_d: f_div port map(
					nrst => s_nrst,
					clkin => OSC_50,
					clkout => s_inclk(0)
);
io_man: i_o_manager_vga port map(
	BTN0 => KEY,
	GAME_OVER => s_GAME_OVER,
	USER_CODE => s_LED_CODE,
	GUES_CODE => s_light_enter_guess_code,
	GREATHER => s_GREATHER,
	SMALLER => s_SMALLER,
	WINER => s_winner, --Quesitooooooooooooon 
	LOSER => s_loser,	-- Van al main de dentro del big_block (game->main)
	TIE => s_tie,	-- Y vienen aqui tambien 			( game -> vga)
	CLK_50 => OSC_50,
	Gues_CodeD => s_GuessT,
	Gues_CodeH => s_GuessH,
	Gues_CodeU => s_GuessU,
	key_code => s_keycode,
	Oponent_CodeH => s_OponentH,
	Oponent_CodeT => s_OponentT,
	Oponent_CodeU => s_OponentU,
	nrst => s_nrst,
	R0 => LED_RED(0),
	R1 => LED_RED(1),
	R2 => LED_RED(2),
	G0 => LED_GREEN(0),
	G1 => LED_GREEN(1),
	G2 => LED_GREEN(2),
	G7 => LED_GREEN(7),
	G6 => LED_GREEN(6),
	vga_hs => VGA_HS,
	bga_vs => VGA_VS,
	Vga_blank => VGA_BLANK,
	Vga_Sync => VGA_SYNC,
	VGA_Clock => VGA_CLK,
	R => VGA_R,
	G => VGA_G,
	B => VGA_B,
	H0 => HEX0,
	H1 => HEX1,
	H2 => HEX2,
	H3 => HEX3,
	H4 => HEX4,
	H5 => HEX5,
	H6 => HEX6,
	H7 => HEX7,
	NC => "0000"
);

end;