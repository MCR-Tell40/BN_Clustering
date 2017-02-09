-- counting unit
-- Author Nicholas Mead
-- Date Created 19/11/2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.detector_constant_declaration.all;

ENTITY counter_8bit IS
	PORT(
		clk 	: IN std_logic;
		rst 	: IN std_logic;
		en  	: IN std_logic;
		count 	: OUT std_logic_vector(DATA_SIZE_MAX_BIT - 1 downto 0)
		);
END ENTITY;


ARCHITECTURE a OF counter_8bit IS

		SIGNAL inter_reg : std_logic_vector(DATA_SIZE_MAX_BIT - 1 downto 0);
	
BEGIN

	PROCESS (clk,rst,en)
	
	BEGIN

		IF (rst = '1') THEN

			inter_reg <= x"00";

		ELSIF (rising_edge(clk) AND en = '1') THEN

			IF (inter_reg = x"FF") THEN

				inter_reg <= x"00";

			ELSE

				inter_reg <= inter_reg + 1;

			END IF;

		END IF;

	END PROCESS;

	count <= inter_reg;

END a; 