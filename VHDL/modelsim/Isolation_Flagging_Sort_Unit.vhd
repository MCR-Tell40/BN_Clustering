-- Bubble Sort Even Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.Isolation_Flagging_Package.all;
USE work.Detector_Constant_Declaration.all;

ENTITY Isolation_Flagging_Sort_Unit IS
	

  PORT(

   	rst 			: in 	std_logic;	
   	dataIn      	: in 	dataTrain;
   	parity 			: in 	std_logic; -- high if odd
   	clk				: in 	std_logic;
  	dataOut   		: out 	dataTrain
  );

 END ENTITY;

ARCHITECTURE a OF Isolation_Flagging_Sort_Unit IS
	SHARED VARIABLE inter_reg : dataTrain; --intermediate shift regester

BEGIN

	PROCESS(clk, rst)
	BEGIN

		IF rst = '1' THEN

			dataOut <= reset_patten_train;
			inter_reg := reset_patten_train;

		ELSIF rising_edge(clk) THEN
			FOR i IN 0 to (OVERFLOW_SIZE - 1) LOOP
				-- check even
				IF ((i mod 2 = 1) AND parity = '1') OR ((i mod 2 = 0) AND parity = '0') THEN

					-- check if switch is required -- sorting by both Chip ID and column
					IF (to_integer(unsigned(dataIn(i)(23 downto 14))) > to_integer(unsigned(dataIn(i+1)(23 downto 14)))) THEN
						-- make switch
						inter_reg(i) 	:= dataIn(i+1);
						inter_reg(i+1) 	:= dataIn(i);
					ELSE
						-- dont make switch
						inter_reg(i) 	:= dataIn(i);
						inter_reg(i+1) 	:= dataIn(i+1); 
					END IF;
				END IF;
			END LOOP;

			IF parity = '1' THEN
				inter_reg(0) := dataIn(0);
				inter_reg(OVERFLOW_SIZE) := dataIn(OVERFLOW_SIZE);
			END IF;
			dataOut <= inter_reg;
		END IF;
	END PROCESS;
END a;