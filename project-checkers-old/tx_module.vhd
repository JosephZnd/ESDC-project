library ieee;
use ieee.std_logic_1164.all;

entity tx_module is
	port (
		clk, nrst, send : in std_logic;
		tx_data : in std_logic_vector(7 downto 0);
		tx, tx_empty : out std_logic
		);
end tx_module;


architecture main of tx_module is
	type state_type is (tx_idle, tx_start, tx_shift, tx_stop);
	signal state : state_type;
	signal bit_count : integer range 0 to 7; -- bit count within the received data word
	constant max : integer range 0 to 7 := 4; -- set to 4 only for simulation purposes
	--constant max : integer range 0 to 8191 := 891; -- 50M/5208~9600, /1302~38400, /892~56000, etc.
	signal baud : integer range 0 to max; -- rx counter at the baud rate
begin

TX_FSM : process (clk, nrst) begin
	if nrst = '0' then
		state <= tx_idle;
		baud <= 0;
		--- Added from original version:
		tx <= '1';
		tx_empty <= '1';
	elsif clk'EVENT and clk = '1' then
		case state is
			when tx_idle => bit_count <= 0;
				tx <= '1';
				baud <= 0;
				tx_empty <= '1';
				if send = '1' then
						tx_empty <= '0';
						state <= tx_start;
				end if;
			when tx_start => tx <= '0';
				if (baud = max) then
					baud <= 0;
					state <= tx_shift;
				else
					baud <= baud + 1;
				end if;
			when tx_shift => tx <= tx_data(bit_count);
					if (baud = max) then
						baud <= 0;
						bit_count <= bit_count + 1;
						if (bit_count = 7) then
							bit_count <= 0;
							state <= tx_stop;
						end if;
					else
						baud <= baud + 1;
					end if;
			when tx_stop => tx <= '1';
					if (baud = max) then
						baud <= 0;
						state <= tx_idle;
					else
						baud <= baud + 1;
					end if;
			when others =>
				end case;
	end if;
end process;
end;