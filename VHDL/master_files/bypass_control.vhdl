-- Control entity for dataprocessing the BCID's below the sort threshord AND ahead of schedual
-- Author: Nicholas Mead
-- Date Created: 26 Apr 2016

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.Isolation_Flagging_Package.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Detector_Constant_Declaration.all;

ENTITY Bypass_Control IS 

	GENERIC(

		ADDR_PER_RAM : INTEGER := 32;
		MAX_RAM_ADDR_STORE : INTEGER := 512;
		SPP_PER_ADDR : INTEGER := 16

		);

	PORT(
		-- standard
		clk, rst, en : IN std_logic;

		-- Router Interface
		rd_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		rd_en	:	OUT std_logic;
		rd_buff :	IN 	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- MEP Interface
		wr_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		wr_en	:	OUT std_logic;
		wr_buff :	OUT	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- Bypass Interace
		FIFO_rd_en 	:	OUT std_logic;
		FIFO_buff	:	IN  std_logic_vector (6 downto 0)
	);

END Bypass_Control;

ARCHITECTURE a OF Bypass_Control IS

	VARIABLE current_bcid : INTEGER 0 to ADDR_PER_RAM - 1;
	VARIABLE current_rd_cycle : INTEGER 0 to (MAX_RAM_ADDR_STORE/SPP_PER_ADDR) -1;
	VARIABLE current_wr_cycle : INTEGER 0 to (MAX_RAM_ADDR_STORE/SPP_PER_ADDR) -1;
	VARIABLE state : INTEGER 0;

	SIGNAL data_in  : std_logic_vector(**constant** downto 0);
	SIGNAL data_out : std_logic_vector(**constant** downto 0);

BEGIN

	PROCESS(clk, rst, en)
	BEGIN
	
		IF rst = '1' OR en = '0' THEN

			current_bcid := 0;
			current_read_cycle := 0;
			state := 0;

			rd_en <= '0';
			wr_en <= '0';
			FIFO_rd_en <= '0';

		ELSIF rising_edge(clk) THEN

			IF state  = 0 THEN -- prep state
				-- prep for state 1
				FIFO_rd_en <= '1';

			ELSIF state = 1 THEN -- desicion state
				-- decide if BCID needs to be bypassed
				IF FIFO_buff > 0 THEN
					-- bypass
					FIFO_rd_en <= '0'
					rd_en <= '1'
					state := 2;

				ELSE
					-- next bcid
					current_bcid := current_bcid + 1;
				END IF;

			ELSIF state = 2 THEN -- bypass first read in

				data_in <= rd_buff;
				current_rd_cycle := 1;
				state := 3;

			ELSIF state = 3 THEN -- first data padding bypass

				FOR i IN 0 to NUMBER_OF_SPP_IN_RAM_ADDR - 1 LOOP
					data_out(i + 31 downto i) <= '0X00' & data_in(i + 23 downto 0);
				END LOOP;

				data_in <= rd_buff;

				IF current_rd_cycle > FIFO_buff / NUMBER_OF_SPP_IN_RAM_ADDR THEN
					state := finalstate;
				ELSE
					state := 4
				END

			ELSIF state = 4 THEN

				wr_buff <= data_out;
				wr_en <= '1';

				FOR i IN 0 to NUMBER_OF_SPP_IN_RAM_ADDR - 1 LOOP
					data_out(i + 31 downto i) <= '0X00' & data_in(i + 23 downto 0);
				END LOOP;

				data_in <= rd_buff;






		END IF;

	END PROCESS;


END a;