-- Isolation tagger
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 09/02/2016

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Isolation_Flagging_Package.all;
USE work.Detector_Constant_Declaration.all;

ENTITY Flagger IS
	
  PORT(

   	rst 			: in 	std_logic;	
   	clk				: in 	std_logic;
   	data_in			: in 	datatrain;
   	data_out		: out 	datatrain
  );

 END ENTITY;

ARCHITECTURE a OF Flagger IS
	
	SHARED VARIABLE inter_reg : datatrain;

BEGIN
	
	PROCESS(clk, rst)
	BEGIN

		IF rst = '1' THEN

			data_out <= reset_pattern_train;

		ELSIF rising_edge(clk) THEN

			-- propogate first and last SPP - these are always edge cases, so not flagged
			inter_reg(0) := data_in(0);
			inter_reg(MAX_FLAG_SIZE-1) := data_in(MAX_FLAG_SIZE-1);

			FOR i IN 1 to (MAX_FLAG_SIZE - 2) LOOP
			
				-- if next SPP is all zeros, must be edge case, so don't flag
				IF (data_in(i+1) = x"00_00_00_00") THEN

					inter_reg(i) := data_in(i);

				ELSE 

					-- check if isolated by seeing if neighbouring BCID signals are present 
					IF (to_integer(unsigned(data_in(i)(13 downto 8))) - to_integer(unsigned(data_in(i-1)(13 downto 8))) > 1) AND 
						(to_integer(unsigned(data_in(i+1)(13 downto 8))) - to_integer(unsigned(data_in(i)(13 downto 8))) > 1) THEN

						inter_reg(i) := data_in(i) OR x"80_00_00_00";

					ELSE

						inter_reg(i) := data_in(i);

					END IF;
				END IF;
			END LOOP;

		END IF;

		-- pass internal register to the output
		data_out <= inter_reg;

	END PROCESS;
END a;

