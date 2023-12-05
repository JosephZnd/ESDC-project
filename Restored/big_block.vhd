library ieee;
use ieee.std_logic_1164.all;

entity big_block is
	port (clk, nrst:in std_logic;
		hash, bcd, ast: in std_logic;
        RDY_RECEIVED, GR_RECEIVED, EQ_RECEIVED, SM_RECEIVED, DT_RECEIVED, ready_to_TX: in std_logic;
		keycode, OpponentH, OpponentT, OpponentU: in std_logic_vector(3 downto 0);
		key_read_main, key_read_guess, key_read_user, LED_CODE, SEND_RDY, SEND_GR, SEND_EQ, SEND_SM, SEND_DT, frame_received: out std_logic;
		LightD, LightG, LightS, game_over: out std_logic;
		winner, loser, tie: out std_logic			   
		);
end big_block;


architecture main of big_block is

------------------------------------------------------------------------------------------------
signal s_code_entered, s_winer, s_loser, s_tie, s_new_code, s_new_game: std_logic;
signal s_user_code_ready, s_enter_user_code, s_LED_USER_CODE:std_logic;
signal s_enter_guess_code, s_guess_code_ready: std_logic;
signal s_DataH_user, s_DataT_user, s_DataU_user: std_logic_vector(3 downto 0);
signal s_DataH_guess, s_DataT_guess, s_DataU_guess: std_logic_vector(3 downto 0);
------------------------------------------------------------------------------------------------

component main
			port (
                clk50, nrst: in std_logic;
                hash, code_entered: in std_logic;  
                winer, loser, tie: in std_logic; 
                new_code, key_read : out std_logic;
                game_over, new_game : out std_logic;
                LED_CODE : out std_logic
			);
end component;

component registerbank
			port (
                clk, nrst: in std_logic;
                bcd, ast, new_code: in std_logic;  
                keycode: in std_logic_vector(3 downto 0);
                DataH, DataT, DataU : out std_logic_vector(3 downto 0);
                key_read, bank_ready : out std_logic
			);
end component;

component game 
			port( 	
                clk50, nrst: in std_logic;
                new_game : in std_logic;  
                RDY_RECEIVED, GR_RECEIVED, EQ_RECEIVED, SM_RECEIVED, DT_RECEIVED: in std_logic;  
                OpponentH, OpponentT, OpponentU : in std_logic_vector(3 downto 0);
                OurH, OurT, OurU : in std_logic_vector(3 downto 0);
                bank_ready, ready_to_TX: in std_logic;  
                SEND_RDY, SEND_GR, SEND_EQ, SEND_SM, SEND_DT : out std_logic;
                frame_received : out std_logic;
                LightD, LightG, LightS, Light_WIN, Light_Lose, Light_Tie : out std_logic;
                enterCode : out std_logic
			);
end component;


begin

m_M:    main port map(	    
                    clk50 => clk,
                    nrst => nrst,
                    hash => hash, 
                    code_entered => s_user_code_ready, 
                    winer => s_winer,
                    loser => s_loser, 
                    tie => s_tie,
                    new_code => s_enter_user_code, 
                    key_read => key_read_main,
                    game_over => game_over, 
                    new_game => s_new_game,
                    LED_CODE => s_LED_USER_CODE
		);

m_RB_usercode: 	registerbank port map(		
						clk => clk, 
						nrst => nrst,
						bcd => bcd, 
						ast => ast, 
						new_code => s_enter_user_code,  
						keycode => keycode,
						DataH => s_DataH_user, 
						DataT => s_DataT_user, 
						DataU =>s_DataU_user,
						key_read => key_read_user, 
						bank_ready => s_user_code_ready
		);
m_RB_guesscode: 	registerbank port map(		
                    clk => clk, 
                    nrst => nrst,
                    bcd => bcd, 
                    ast => ast, 
                    new_code => s_enter_guess_code,  
                    keycode => keycode,
                    DataH => s_DataH_guess, 
                    DataT => s_DataT_guess, 
                    DataU =>s_DataU_guess,
                    key_read => key_read_guess, 
                    bank_ready => s_guess_code_ready
		);

m_G: 	game port map(
                    clk50 => clk,
                    nrst => nrst,
                    new_game => s_new_game ,  
                    RDY_RECEIVED => RDY_RECEIVED,
                    GR_RECEIVED => GR_RECEIVED, 
                    EQ_RECEIVED => EQ_RECEIVED, 
                    SM_RECEIVED => SM_RECEIVED, 
                    DT_RECEIVED => DT_RECEIVED,  
                    OpponentH => OpponentH, 
                    OpponentT => OpponentT, 
                    OpponentU => OpponentU,
                    OurH => s_DataH_user, 
                    OurT => s_DataT_user, 
                    OurU => s_DataU_user,
                    bank_ready => s_guess_code_ready, 
                    ready_to_TX => ready_to_TX,  
                    SEND_RDY => SEND_RDY, 
                    SEND_GR => SEND_GR, 
                    SEND_EQ => SEND_EQ, 
                    SEND_SM => SEND_SM, 
                    SEND_DT => SEND_DT,
                    frame_received => frame_received,
                    LightD => LightD, 
                    LightG => LightG, 
                    LightS => LightS, 
                    Light_WIN => s_winer, 
                    Light_Lose => s_loser, 
                    Light_Tie => s_tie,
                    enterCode => s_enter_guess_code
		);
winner <= s_winer;
loser <= s_loser;
tie <= s_tie;
end;