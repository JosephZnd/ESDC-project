--Serial receiver. 
--Default baud rate is 56000 bps from a 50MHz clock.
--Version 1.2 october 2016.

library ieee;
use ieee.std_logic_1164.all;

entity rx_module2 is
port( clk, nrst, rx, data_read : in std_logic;
	   rx_data : out std_logic_vector(7 downto 0);   
	   rx_new, rx_data_lost  : out std_logic );
end rx_module2;

architecture main of rx_module2 is

type state_type is (rx_idle, rx_start, rx_shift, rx_stop);
signal state : state_type;

signal bit_count : integer range 0 to 7;   -- bit count within the received data word
constant max : integer range 0 to 7 := 4;		-- set to 4 only for simulation purposes
--constant max : integer range 0 to 8191 := 891;  -- 50M/5208~9600, /1302~38400, /892~56000, etc.
signal baud : integer range 0 to max; -- rx counter at the baud rate

-- Added from the old version
signal set_rx_new: std_logic; -- to set rx_new to one.
signal rx_new_internal: std_logic;  -- replica of rx_new to be read.

begin

--------- RECEIVER_FSM ---------
RX_FSM: process(clk, nrst) begin

if nrst = '0' then
	state <= rx_idle;
	baud <= 0;
	--rx_new <= '0';
	rx_data_lost <= '0';

elsif clk'event and clk = '1' then
	case state is
	when rx_idle => bit_count <= 0;
					--rx_new <= '0';
					if rx = '0' then
						baud <= 0;
						state <= rx_start;
					end if;
	when rx_start => if (baud = (max-1)/2) then
						baud <= 0;
						if rx = '0' then
							state <= rx_shift;
							bit_count <= 0;
						else
							state <= rx_idle;
						end if;
					else
						baud <= baud + 1;
					end if;
	when rx_shift => if (baud = max) then
						baud <= 0;
						bit_count <= bit_count+1;
						rx_data(bit_count) <= rx;							
						if (bit_count = 7) then
							bit_count <= 0;
							state <= rx_stop;
							--rx_new <='1';
							-- Added from the old version:
							if (rx_new_internal = '1') then 
								rx_data_lost <= '1';
							end if;
						end if;
					 else
						baud <= baud + 1;
					 end if;
	when rx_stop => --rx_new <= '0';
					if (baud = max) then
						baud <= 0;
						bit_count <= 0;
						state <= rx_idle;
					else
						baud <= baud + 1;
					end if;
	when others =>
	end case;
end if;
end process;

-- Added from the old version:

-- Signal set to activate rx_new.

--set_rx_new <= '1' when state = rx_shift and bit_count = 7 and baud = max else '0';
set_rx_new <= '1' when state = rx_stop and baud = max else '0';

-- Process to hand shake with the user.
-- J K flip flop to set and reset rx_new.

process(clk, nrst) begin

	if (nrst = '0') then
		rx_new_internal <= '0';
	elsif clk'event and clk = '1' then
		if (set_rx_new = '1') then
			rx_new_internal <= '1';
		elsif (data_read = '1') then
			rx_new_internal <= '0';
		end if;
	end if;
end process;

rx_new <= rx_new_internal;
	
end;
