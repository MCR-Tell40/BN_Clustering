-- Bubble Sort Even Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.sort_function.all;

ENTITY BubbleSort IS
	

  PORT(

   	rst 			: in 	std_logic;	

   	dataIn      	: in 	dataTrain;
   	parity 			: in 	std_logic; -- high if odd

  	dataOut   		: out 	dataTrain
  );

 END BubbleSort;

-----------------------------------------------------------------------
--------------------------- Even Architecture -------------------------

ARCHITECTURE a OF BubbleSort IS
	-- reset patterns
	constant reset_patten_spp 	: std_logic_vector(29 downto 0) := (others => '0');
	constant reset_patten_train : dataTrain := (others => reset_patten_spp);

		
BEGIN

	PROCESS(parity)
		VARIABLE mod_value : integer; 
	BEGIN
		IF parity'event THEN
			IF parity = '1' THEN
				mod_value := 1;
			ELSIF parity = '0' THEN
				mod_value := 0;
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
		END IF;
	END PROCESS;
END a;