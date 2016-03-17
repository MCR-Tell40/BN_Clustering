-- Isolation tagger
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 09/02/2016

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Isolation_Flagging_Package.all;
USE work.Detector_Constant_Declaration.all;


ENTITY isolation_flagger IS
	
  PORT(

   	rst 			: in 	std_logic;	
   	clk				: in 	std_logic;
   	data_in			: in 	datatrain;
   	data_out		: out 	datatrain

  );

 END ENTITY;

ARCHITECTURE a OF isolation_flagger IS
	
	SHARED VARIABLE inter_reg : datatrain;

BEGIN
	
	PROCESS(clk, rst)
	BEGIN

		IF rst = '1' THEN

			data_out <= reset_patten_train;

		ELSIF rising_edge(clk) THEN


			inter_reg(0) := data_in(0);
			inter_reg(OVERFLOW_SIZE-1) := data_in(OVERFLOW_SIZE-1);

			IF (to_integer(unsigned(data_in(OVERFLOW_SIZE)(13 downto 8))) - to_integer(unsigned(data_in(OVERFLOW_SIZE-1)(13 downto 8)))) > 1 THEN

				inter_reg(OVERFLOW_SIZE) := data_in(OVERFLOW_SIZE) OR x"80_00_00";

			ELSE

				inter_reg(OVERFLOW_SIZE) := data_in(OVERFLOW_SIZE);

			END IF;

			FOR i IN 1 to (OVERFLOW_SIZE - 2) LOOP

				IF (to_integer(unsigned(data_in(i)(13 downto 8))) - to_integer(unsigned(data_in(i-1)(13 downto 8))) > 1) AND 
					(to_integer(unsigned(data_in(i+1)(13 downto 8))) - to_integer(unsigned(data_in(i)(13 downto 8))) > 1) THEN

					inter_reg(i) := data_in(i) OR x"80_00_00";

				ELSE

					inter_reg(i) := data_in(i);

				END IF;

			END LOOP;

		END IF;

		data_out <= inter_reg;

	END PROCESS;
END a;