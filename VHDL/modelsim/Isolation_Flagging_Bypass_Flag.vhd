------------------------------------------------------------------------------------------
-- Bypass Flag FIFO 																	--
-- output data width = 6, 4 downto 0 = #SPP in BCID, bit 5 = Bypass if high				--
-- Author: Nicholas Mead,																--
-- Referanced from: http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/				--
-- Date: 10 Mar 2016																	--
------------------------------------------------------------------------------------------

library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bypass_decision IS
	PORT(
		-- output --
		dataout 					: OUT STD_LOGIC_VECTOR(5 downto 0),
		dataout_write_enable 		: OUT STD_LOGIC,
		
		-- input --
		datain 						: IN  STD_LOGIC_VECTOR(4 downto 0),
		datain_read_enable 			: OUT STD_LOGIC,
		datain_RAM_Access_Pointer 	: OUT STD_LOGIC_VECTOR(8 downto 0)

		-- control --
		clk, rst					: IN STD_LOGIC

		);
END bypass_decision;

ARCHITECTURE Behavioral OF bypass_decision IS
	
	PROCESS(clk,rst)
		VARIABLE state 		: NATURAL RANGE 0 TO 1;
		VARIABLE timeing 	: NATURAL RANGE 0 TO 511;
		VARIABLE phase		: NATURAL RANGE 0 TO 32;
	BEGIN

		IF (rst = '1') THEN 
			dataout <= '0'
			dataout_write_enable <= '0'
			datain_read_enable <= '0'
			datain_RAM_Access_Pointer <= (OTHERS => '0')


		ELSIF (rising_edge(clk)) THEN

			IF (state = 0 AND timeing = 0) THEN
				state := 1;

			ELSIF (state = 1) THEN

				IF (phase = 32) THEN -- end of phase
					phase := 0;
					state := 0;

				ELSE
					
					datain_read_enable <= 0;
									





		END IF;

	END PROCESS;


END Behavioral;