-----------------------------------------------------------------------------------------
-- Block wr_memory: writes into a RAM memory in order to have a 120x120 square represented on a VGA screen
-- x_t: left top column coordinate. 8 MSB of the 10 bits needed.
-- y_t: left top row coordinate. 7 MSB of the 9 bitw needed.
-- color_t: RGB components of the square to plot. 3 bits
-- DONE: is going to be active only 1 period of clock when the writing process is finished
-- Start: order to start writing the memory.
-- Author: Josep Altet. 
-- Version 1.0 : Date: 12-02-2019.
-- Version 2.0 : Date: 25-02-2020 (Adapted to Theory lecture).
-- Version 3.0 : Date: 08-09-2021 Adapted to Design 1.
-- Electronic System Design for Communications - ESDC - ETSTB. UPC. Barcelona.
----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity wr_memory is
  port( clk_d1, start, nrst 	: in std_logic;
		x_t				: in std_logic_vector(7 downto 0);
		y_t				: in std_logic_vector(6 downto 0);
		color_t 			: in std_logic_vector(2 downto 0);
		we, done		: out std_logic;  --To be connected to the RAM WE
		data 			: out std_logic_vector(2 downto 0);  -- To be connected to the RAM data bus
		adr_memo		: out std_logic_vector(14 downto 0) );  -- To be connected to the RAM ADD Bus.
end wr_memory;


architecture functional of wr_memory is
  -- Size of the square
  constant SQUARE_WIDTH : integer := 14; --25<<4 = 100.
  -- State definition:
  type state_memo is (s0, s1, s2, s3, s4, s5, s6);
  -- Internal signals
  -- Output of the state register
  signal st_write : state_memo;
  -- Internal address memory bus
  signal address_t : std_logic_vector(14 downto 0);
  -- Output of two counters
  signal i, j : integer range 0 to SQUARE_WIDTH; 
  

Begin
-- Control Unit for memo operation:
-- All signals updated inside if (clk_d1'event and clk_d1='1') are output of registers!!
-- With this VHDL description, Control Unit and Process Unit are described with one single Process.
-- Control Unit: state flow.
-- Process Unit: Blocks that process data (counters, registers).
-- Control signals: they are not specified in the VHDL description, but they will be in the final implemented design. 
-- Only output control signals are presented.
	process(clk_d1, nrst)
	Begin
		if (nrst = '0') then
			st_write <= s0;
		elsif (clk_d1'event and clk_d1='1') then
			case st_write is
				when s0  => if start = '1' then st_write <= s1; end if;
				when s1 => st_write <= s2;
					j <= 0; i <= 0;
					-- adress = y(8:1) concatenated with x(9:1)
					address_t(14 downto 8) <= y_t(6 downto 0);
					address_t(7 downto 0) <= x_t(7 downto 0);
					data <= color_t;
				-- In s2 wr_memo should be active and data is stored in the cell address_t.
				when s2 => st_write <= s3; 
					i <= i+1;  -- i loop: to write a square row.
					
				when s3 => if (i<SQUARE_WIDTH) then 
									st_write <= s2;
									address_t <= address_t + 1; -- Increase of collumn. Same Row 
							else st_write <= s4; end if;
				when s4 => st_write <= s5;
					i <= 0; j <= j+1;  -- Now we are writting the following square row
				when s5 => if (j<SQUARE_WIDTH) then st_write <= s2; 
							address_t(14 downto 8) <= address_t(14 downto 8) +1; -- Increase Row
							address_t(7 downto 0) <= x_t(7 downto 0);  --Original Collumn
							else st_write <= s6; end if;
				when s6 => st_write <= s0;
			End Case;
		End If;
	End process;
	
-- Combinationals outputs of the control unit to operate with memory:
we <= '1' when st_write = s2 else '0';
done <= '1' when st_write = s6 else '0';
adr_memo <= address_t;

End functional;
	