-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.bubble_sort_package.all;
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

			IF (to_integer(unsigned(dataIn(1)(15 downto 8))) - to_integer(unsigned(dataIn(0)(15 downto 8)))) > 1 THEN
			
				-- data_in(0) is isolated
				inter_reg(0) := data_in(0) & X"80000000";
			
			ELSE

				inter_reg(0) := data_in(0);

			END IF;

			IF (to_integer(unsigned(dataIn(OVERFLOW_SIZE)(15 downto 8))) - to_integer(unsigned(dataIn(OVERFLOW_SIZE-1)(15 downto 8)))) > 1 THEN

				inter_reg(OVERFLOW_SIZE) := data_in(OVERFLOW_SIZE) & X"80000000" 

			ELSE

				inter_reg(OVERFLOW_SIZE) := data_in(OVERFLOW_SIZE);

			END IF;

			FOR i IN 1 to (OVERFLOW_SIZE - 1) LOOP

				IF (to_integer(unsigned(dataIn(i)(15 downto 8))) - to_integer(unsigned(dataIn(i-1)(15 downto 8))) > 1) AND 
					(to_integer(unsigned(dataIn(i+1)(15 downto 8))) - to_integer(unsigned(dataIn(i)(15 downto 8))) > 1) THEN

					inter_reg(i) := data_in(OVERFLOW_SIZE) & X"80000000";

				ELSE

					inter_reg(i) := data_in(OVERFLOW_SIZE);

				END IF;

			END LOOP;

		END IF;

		data_out <= inter_reg;

	END PROCESS;
END a;