-- Bubble Sort Even Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.bubble_sort_package.all;
USE work.Detector_Constant_Declaration.all;

ENTITY BubbleSort IS
	

  PORT(

   	rst 			: in 	std_logic;	

   	dataIn      	: in 	dataTrain;
   	parity 			: in 	std_logic; -- high if odd
   	clk				: in 	std_logic;

  	dataOut   		: out 	dataTrain
  );

 END ENTITY;

ARCHITECTURE a OF BubbleSort IS
	SHARED VARIABLE inter_reg : dataTrain; --intermediate shift regester

BEGIN
	
	--dataOut <= inter_reg;

	PROCESS(clk, rst)
	BEGIN

		IF rst = '1' THEN

			dataOut <= reset_patten_train;
			inter_reg := reset_patten_train;

		ELSIF rising_edge(clk) THEN
			FOR i IN 0 to (OVERFLOW_SIZE - 1) LOOP
				-- check even
				IF ((i mod 2 = 1) AND parity = '1') OR ((i mod 2 = 0) AND parity = '0') THEN
					report "comparison being made " & integer'image(i);
					-- check if switch is required
					IF (to_integer(unsigned(dataIn(i)(15 downto 8))) > to_integer(unsigned(dataIn(i+1)(15 downto 8)))) THEN
						-- make switch
						report "swapping " & integer'image(i);
						inter_reg(i) 	:= dataIn(i+1);
						inter_reg(i+1) 	:= dataIn(i);
					ELSE
						-- dont make switch
						report "keeping " & integer'image(i);
						inter_reg(i) 	:= dataIn(i);
						inter_reg(i+1) 	:= dataIn(i+1); 
					END IF;
				ELSE
					report "skipping comparison " & integer'image(i);
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