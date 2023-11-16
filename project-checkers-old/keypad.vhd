-- 4x4 keypad analyser
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity keypad is
  port (
    clk, nrst    : in  std_logic;
    key          : out std_logic;
    keycode, row : out std_logic_vector(3 downto 0);
    col          : in  std_logic_vector(3 downto 0)
    );
    
end keypad;


architecture arc_keypad of keypad is
  component count4b
    port (
      clk, nclr : in  std_logic;
      output    : out integer range 0 to 15);
  end component;
  type   states is (wait0, check0, kra0, kra1, kra2, kra3, wait1, check1);
  signal current_state, next_state : states;
  signal comp                      : integer range 0 to 15;
  signal rowq, colq                : std_logic_vector(3 downto 0);
  signal look, kpressed            : std_logic;
begin  -- arc_keypad


   
--look generation
  counter : count4b port map (
    clk    => clk,
    nclr   => nrst,
    output => comp);
  look <= '1' when comp = 15 else '0';

--kpressed generation
  reg4 : process (clk, nrst)
  begin  -- process reg4
    if nrst = '0' then
      colq <= "0000";
    elsif clk'event and clk = '0' then
      colq <= col;
    end if;
  end process reg4;
  kpressed <= not (colq(3) and colq(2) and colq(1) and colq(0));

--whatkey state machine declaration, made with a synchronous state register, plus
--two combinational blocs, one generates the next state and the other the outputs
  --state register definition
  whatkey : process (clk, nrst)
  begin  -- process keyanal
    if nrst = '0' then
      current_state <= wait0;
    elsif clk'event and clk = '1' then
      current_state <= next_state;
    end if;
  end process whatkey;

  --next state function
  next_state <= check0 when (look = '1' and current_state = wait0)                                                                            else
                wait0  when ((kpressed = '0' and (current_state = wait0 or current_state = kra3 or current_state = check1)) or 
                             (look = '0' and current_state = wait0))                                                                          else
                kra0   when (kpressed = '1' and current_state = check0)                                                                       else
                kra1   when (kpressed = '0' and current_state = kra0)                                                                         else
                kra2   when (kpressed = '0' and current_state = kra1)                                                                         else
                kra3   when (kpressed = '0' and current_state = kra2)                                                                         else
                wait1  when ((kpressed = '1' and (current_state = kra0 or current_state = kra1 or current_state = kra2 or 
                                                  current_state = kra3 or current_state = check1)) or (look = '0' and current_state = wait1)) else
                check1 when (look = '1' and current_state = wait1)                                                                                                                                                    else
                wait0;

  --output functions
  with current_state select
    rowq <=
    "1111" when wait0  | wait1,
    "0000" when check0 | check1,
    "1110" when kra0,
    "1101" when kra1,
    "1011" when kra2,
    "0111" when kra3,
    "1111" when others;
  key <= '0' when (current_state = wait0 or current_state = check0 or current_state = wait1 or
                   current_state = check1 or colq = "1111") else '1';
  keycode <= x"1" when (current_state = kra0 and colq(0) = '0') else
             x"2" when (current_state = kra0 and colq(1) = '0') else
             x"3" when (current_state = kra0 and colq(2) = '0') else
             x"a" when (current_state = kra0 and colq(3) = '0') else
             x"4" when (current_state = kra1 and colq(0) = '0') else
             x"5" when (current_state = kra1 and colq(1) = '0') else
             x"6" when (current_state = kra1 and colq(2) = '0') else
             x"b" when (current_state = kra1 and colq(3) = '0') else
             x"7" when (current_state = kra2 and colq(0) = '0') else
             x"8" when (current_state = kra2 and colq(1) = '0') else
             x"9" when (current_state = kra2 and colq(2) = '0') else
             x"c" when (current_state = kra2 and colq(3) = '0') else
             x"e" when (current_state = kra3 and colq(0) = '0') else
             x"0" when (current_state = kra3 and colq(1) = '0') else
             x"f" when (current_state = kra3 and colq(2) = '0') else
             x"d" when (current_state = kra3 and colq(3) = '0') else
             x"0";
  --keyanal end

  --tristate buffers
  tribuf: for i in 0 to 3 generate
    row(i) <= '0' when rowq(i) = '0' else 'Z';
  end generate tribuf;
  
end arc_keypad;
