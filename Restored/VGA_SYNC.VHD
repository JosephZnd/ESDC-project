----------------------------------------------------
-- VGA video sync generator for the ZYBO
--  Written by J. Altet and F. Moll based on code from the book
-- "Rapid prototyping of digital systems" by Hamblen and Furman
-- 
-- Output ports and names adapted to ZYBO and provided xdc file
-- Version 1 23 April 2018
-- Version 2 25 July 2018: input color is now a bus
-- Version 3 29 September 2020: Adapted for the DE2 Altera Board. Names adapted to ALTERA BOARD.
---------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

-- VGA Video Sync generation

-- DE2 supports 30 bits to encode the color of each pixel:
-- Red: 10 bits
-- Green: 10 bits
-- Blue: 10 bits
-- In this design, only 3-bit color depth is supported. Feel free of using more colors if needed!

ENTITY VGA_SYNC IS

	PORT(clock_25Mhz		: IN	STD_LOGIC;
	     color_in							: IN STD_LOGIC_VECTOR(2 downto 0); -- (2):R (1):G (0):B
		 vga_r, vga_b, vga_g				: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- 9 bits color output. Only 8 color levels.
		 vga_hs, vga_vs						: OUT	STD_LOGIC; -- sync outputs, for the VGA
		 vga_blank, vga_sync				: OUT	STD_LOGIC; -- for the ADC, to generate BLANK signals. Active low. 
		 pixel_row, pixel_column			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);-- video memory address counter
		 vga_clk							: OUT	STD_LOGIC); -- Output CLK for the DAC

END VGA_SYNC;

ARCHITECTURE a OF VGA_SYNC IS
	SIGNAL red, green, blue		: STD_LOGIC; -- internal signals connected to inputs
	SIGNAL red_out, green_out, blue_out		: STD_LOGIC;
	SIGNAL horiz_sync, vert_sync 			: STD_LOGIC;
	SIGNAL video_on, video_on_v, video_on_h : STD_LOGIC;
	SIGNAL h_count, v_count 				: STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN

 red <= color_in(2);
 green <= color_in(1);
 blue <= color_in(0);
 vga_blank <= '1';  -- This signal is left de-activated all the time

-- video_on is high only when RGB data is being displayed
 video_on <= video_on_H AND video_on_V;
 vga_sync <= video_on;
 vga_clk <= clock_25Mhz;  -- Output clock is the same as input clock

--Generate Horizontal and Vertical Timing Signals for Video Signal

 PROCESS
 BEGIN
	WAIT UNTIL(clock_25Mhz'EVENT) AND (clock_25Mhz='1');

	-- H_count counts pixels (640 + extra time for sync signals)
	-- 
	--  Horiz_sync  ------------------------------------__________--------
	--  H_count       0                640             659       755    799
	--
	IF (h_count = 799) THEN
   		h_count <= "0000000000";
	ELSE
   		h_count <= h_count + 1;
	END IF;

	--Generate Horizontal Sync Signal using H_count
	IF (h_count <= 755) AND (h_count >= 659) THEN
 	  	horiz_sync <= '0';
	ELSE
 	  	horiz_sync <= '1';
	END IF;


	--V_count counts rows of pixels (480 + extra time for sync signals)
	--  
	--  Vert_sync      ----------------------------------_______------------
	--  V_count         0                         480    493-494          524
	--
	IF (v_count >= 524) AND (h_count >= 699) THEN
   		v_count <= "0000000000";
	ELSIF (h_count = 699) THEN
   		v_count <= v_count + 1;
	END IF;

		-- Generate Vertical Sync Signal using V_count
	IF (v_count <= 494) AND (v_count >= 493) THEN
   		vert_sync <= '0';
	ELSE
  		vert_sync <= '1';
	END IF;

		-- Generate Video on Screen Signals for Pixel Data
	IF (h_count <= 639) THEN
   		video_on_h <= '1';
   		pixel_column <= h_count;
	ELSE
	   	video_on_h <= '0';
	END IF;

	IF (v_count <= 479) THEN
   		video_on_v <= '1';
   		pixel_row <= v_count;
	ELSE
   		video_on_v <= '0';
	END IF;

				-- Put all video signals through DFFs to elminate 
				-- any logic delays that can cause a blurry image
		red_out 		<= red AND video_on;
		green_out 		<= green AND video_on;
		blue_out 		<= blue AND video_on;
		vga_hs 	<= horiz_sync;
		vga_vs 	<= vert_sync;
		
		--  RGB components for 8 colors. There are only 8 color levels.
		vga_r <= red_out & red_out & red_out & red_out & red_out & red_out & red_out & red_out & red_out & red_out;
		vga_b <= blue_out & blue_out & blue_out & blue_out & blue_out & blue_out & blue_out & blue_out & blue_out & blue_out;
		vga_g <= green_out & green_out & green_out & green_out & green_out & green_out & green_out & green_out & green_out & green_out;
		

 END PROCESS;

END a;
