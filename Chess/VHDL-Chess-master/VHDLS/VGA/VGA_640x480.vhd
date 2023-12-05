--used for setting up the VGA h and v sync and to provid the pixel counter for doing graphics
Library IEEE;
use IEEE.STD_LOGIC_1164.All;
use IEEE.Numeric_Std.All;

entity VGA_640x480 is
	port(	Hsync,Vsync,VidOn:out std_logic;
			Hpx:out integer range 0 to 640;
			Vpx:out integer range 0 to 480;
			CLK,Clear:in std_logic);
end VGA_640x480;

architecture Behavioral of VGA_640x480 is
signal HC:integer range 0 to 640 :=0;
signal VC:integer range 0 to 480 :=0;
begin
	process(CLK,Clear) begin
		if(Clear = '1') then
			HC <= 0;
			VC <= 0;
		elsif (rising_edge(CLK)) then
			HC <= HC + 1;
			if(HC=799) then
				VC <= VC+1;
				HC <= 0;
				if(VC=524) then
					VC <= 0;
				end if;
			end if;
		end if;
	end process;
	process(HC,VC) begin
		if((HC >= 0) and (HC<128)) then
			Hsync <= '1';
		else Hsync <= '0';
		end if;
		if(VC=0 or VC=1)	then
			Vsync <= '1';
		else Vsync <= '0';
		end if;
		if(HC >= 144 and HC < 784) and (VC >= 35 and VC <= 515) then
			VidOn <= '1';
			Hpx <= HC-144;
			Vpx <= VC-35;
		else 
			VidOn <= '0';
			Hpx <= 640;
			Vpx <= 480;
		end if;
	end process;
end Behavioral;