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
	
	-- temps to contain info for chip id and column info
	-- 14 downto 6 will be chip id, 5 downto 0 will be column info
	SHARED VARIABLE temp_1 : std_logic_vector(14 downto 0);	
	SHARED VARIABLE temp_2 : std_logic_vector(14 downto 0);


BEGIN

	PROCESS(clk, rst)
	BEGIN

		IF rst = '1' THEN

			dataOut <= reset_patten_train;
			inter_reg := reset_patten_train;

		ELSIF rising_edge(clk) THEN
			FOR i IN 0 to (OVERFLOW_SIZE - 1) LOOP
				-- check even
				
				-- create temp_1 for dataIn(i)
				temp_1(14 downto 6) := dataIn(i)(29 downto 21);
				temp_1(5 downto 0)  := dataIn(i)(13 downto 8);

				-- create temp_2 for dataIn(i+1)
				temp_2(14 downto 6) := dataIn(i+1)(29 downto 21);
				temp_2(5 downto 0)  := dataIn(i+1)(13 downto 8);				

				IF ((i mod 2 = 1) AND parity = '1') OR ((i mod 2 = 0) AND parity = '0') THEN

					-- check if switch is required
					IF (to_integer(unsigned(temp_1) > to_integer(unsigned(temp_2)) THEN
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