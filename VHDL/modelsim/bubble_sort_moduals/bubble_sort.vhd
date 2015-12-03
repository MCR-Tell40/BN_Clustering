-- Bubble Sort Even Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.bubble_sort_package.all;

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
		
BEGIN

	PROCESS(clk)
		VARIABLE mod_value : integer; 
	BEGIN
		IF rising_edge(clk) THEN
			IF parity = '1' THEN
				mod_value := 1;
			ELSIF parity = '0' THEN
				mod_value := 0;
			END IF;
		END IF;
		
		-- itterate over data train
		FOR i IN 0 to 98 LOOP
			-- check even
			IF (i mod 2 = mod_value) THEN
				-- check if switch is required
				IF (makeSwitch(dataIn(i),dataIn(i+1)) = '1') THEN
					-- make switch
					dataOut(i) 		<= dataIn(i+1);
					dataOut(i+1) 	<= dataIn(i);
				ELSE
					-- dont make switch
					dataOut(i) 		<= dataIn(i);
					dataOut(i+1) 	<= dataIn(i+1); 
				END IF;
			END IF;
		END LOOP;
	END PROCESS;
END a;