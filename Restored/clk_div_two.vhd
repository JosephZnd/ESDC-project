-----------------------------------------------------------
 -- Clock_div_two  clock divider per two: from 50MHz to 25 MHz
 -- Author: Josep Altet
 -- Date: 20-09-2020
 ----------------------------------------------------------
 
 LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY clk_div_two IS

	PORT(clock_50Mhz, nrst		: IN	STD_LOGIC;
		clock_25MHz			: OUT std_logic);
		
End clk_div_two;

Architecture simple of clk_div_two is

signal clk_int : std_logic;  -- definition of internal signal.
Begin

	clock_25MHz <= clk_int;
--	clock_25MHz <= clock_50Mhz;
	
	Process(clock_50Mhz, nrst)
	Begin
		if (nrst = '0') then clk_int <= '0';
		elsif (clock_50Mhz'event and clock_50Mhz = '1') then
			clk_int <= not(clk_int);
		end if;
	End Process;
End simple;
	
		