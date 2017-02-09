-- Control entity for dataprocessing the BCID's below the sort threshord AND ahead of schedule
-- Author: Nicholas Mead
-- Date Created: 26 Apr 2016

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Isolation_Flagging_Package.all;
--USE IEEE.STD_LOGIC_ARITH.ALL; -- seems this package is superfluous, was making unsigned() not work, may have been conflicting with other pckage
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Detector_Constant_Declaration.all;

ENTITY Bypass_Control IS 

	GENERIC(

		ADDR_PER_RAM 		: INTEGER := 32;
		MAX_RAM_ADDR_STORE 	: INTEGER := 512;
		SPP_PER_ADDR 		: INTEGER := 16

		);

	PORT(
		-- standard
		clk, rst, en : IN std_logic;

		-- Router Interface
		rd_addr : 	OUT std_logic_vector ( RD_RAM_ADDR_SIZE - 1 downto 0);
		rd_en	:	OUT std_logic;
		rd_data :	IN 	std_logic_vector ( RD_WORD_SIZE -1 downto 0);

		-- MEP Interface
		wr_addr : 	OUT std_logic_vector ( WR_RAM_ADDR_SIZE - 1 downto 0);
		wr_en	:	OUT std_logic;
		wr_data :	OUT	std_logic_vector ( WR_WORD_SIZE - 1 downto 0);

		-- Bypass Interace
		FIFO_rd_en 	:	OUT std_logic;
		FIFO_data	:	IN  std_logic_vector (6 downto 0);
		FIFO_empty  : 	IN 	std_logic
	);

END Bypass_Control;

ARCHITECTURE a OF Bypass_Control IS

	SIGNAL bcid 			: std_logic_vector(8 downto 0);

	SHARED VARIABLE spp_count 		: INTEGER;
	SHARED VARIABLE rd_itteration 	: INTEGER RANGE 0 to (RD_SPP_PER_BCID*RD_SPP_SIZE/RD_WORD_SIZE) -1;
	SHARED VARIABLE wr_itteration 	: INTEGER RANGE 0 to (WR_SPP_PER_BCID*WR_SPP_SIZE/WR_WORD_SIZE) -1;
	SHARED VARIABLE state 			: INTEGER := 0;

	SIGNAL inter_reg : std_logic_vector(WR_WORD_SIZE - 1 downto 0); ------------------------------------- << need const for this << -----------------------------------

BEGIN


	rd_addr <= bcid(4 downto 0) & std_logic_vector(to_unsigned(rd_itteration, RD_RAM_ADDR_SIZE - 5));
	wr_addr <= bcid(4 downto 0) & std_logic_vector(to_unsigned(wr_itteration, WR_RAM_ADDR_SIZE - 5));

	PROCESS(clk, rst, en)
	BEGIN
	
		IF rst = '1' OR en = '0' THEN

			bcid 				<= (others => '0');
			--current_read_cycle 	:= 0;
			state 				:= 0;

			rd_en 		<= '0';
			wr_en 		<= '0';
			FIFO_rd_en 	<= '0';

		ELSIF rising_edge(clk) THEN

			IF state = 0 THEN
				-- pre state 1
				FIFO_rd_en <= '1';
				state := 1;

			ELSIF state = 1 THEN

				spp_count := to_integer(unsigned(FIFO_data));

				wr_en <= '0'; -- for when state returns to 1 from 4

				IF to_integer(unsigned(FIFO_data)) > 0 THEN
					-- stop reading FIFO, stare bypassing
					FIFO_rd_en <= '0';
					rd_en <= '1';
					rd_itteration := 0;
					state := 2;

				ELSE
					--re-do state for next bcid
					bcid <= bcid + "1";

				END IF;

			ELSIF state = 2 THEN

				FOR i IN 1 TO 15 LOOP

					inter_reg(((i * 32) - 1 ) downto ((i - 1) * 32) ) <= "0X00" & rd_data(((i * 24) - 1)  downto ((i - 1) * 24));

				END LOOP;

				IF (rd_itteration + 1) * 8 >= spp_count THEN

					rd_en <= '0';
					state := 4;

				ELSE

					rd_itteration := rd_itteration + 1;
					state := 3;
				END IF;

			ELSIF state = 3 THEN

				wr_en <= '1';
				wr_data <= inter_reg;
				wr_itteration := rd_itteration - 1;

				FOR i IN 1 TO 15 LOOP

					inter_reg(((i * 32) - 1 ) downto ((i - 1) * 32) ) <= "0X00" & rd_data(((i * 24) - 1)  downto ((i - 1) * 24));

				END LOOP;

				IF (rd_itteration + 1) * 8 >= spp_count THEN

					rd_en <= '0';
					state := 4;

				ELSE

					rd_itteration := rd_itteration + 1;
					state := 3;
				END IF;

			ELSIF state = 4 THEN

				wr_en <= '1';
				wr_data <= inter_reg;
				wr_itteration := rd_itteration;

				FIFO_rd_en <= '1'; -- ready for state 1
				state := 1;

			END IF;

		END IF;

	END PROCESS;


END a;

