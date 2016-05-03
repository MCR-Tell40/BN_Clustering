-- Control entity for dataprocessing the BCID's below the sort threshord AND ahead of schedual
-- Author: Nicholas Mead
-- Date Created: 14 Apr 2016

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.Isolation_Flagging_Package.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Detector_Constant_Declaration.all;

ENTITY Active_Control IS 

	PORT(
		-- standard
		clk, rst, en : IN std_logic;

		-- Router Interface
		rd_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		rd_en	:	OUT std_logic;
		rd_data :	IN 	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- Train Size RAM interface ct=count
		ct_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		ct_data :	IN 	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- MEP Interface
		wr_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		wr_en	:	OUT std_logic;
		wr_data :	OUT	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- Bypass Interace
		FIFO_wr_en 	:	OUT std_logic;
		FIFO_data	:	OUt std_logic_vector (6 downto 0);
		bypass_en 	: 	OUT STD_LOGIC;
	);

END Active_Control;

ARCHITECTURE a OF Active_Control IS

	-- in process variables
	SHARED VARIABLE rd_state 			: INTEGER range 0 to 4;
	SHARED VARIABLE rd_data_store 		: datatrain;
	SHARED VARIABLE rd_processor_num 	: INTEGER range 0 to data_processor_count-1;
	SHARED VARIABLE rd_bcid_store		: std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	SHARED VARIABLE rd_size_store		: std_logic_vector(7 downto 0);
	SHARED VARIABLE rd_iteration 		: INTEGER range 0 to 7;

	-- out process variables
	SHARED VARIABLE wr_state 			: INTEGER range 0 to 4;
	SHARED VARIABLE wr_processor_num 	: INTEGER range 0 to data_processor_count-1;
	SHARED VARIABLE wr_data_store 		: datatrain;
	SHARED VARIABLE wr_addr_store		: std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	SHARED VARIABLE wr_size_store		: std_logic_vector(7 downto 0);
	SHARED VARIABLE wr_iteration 		: INTEGER range 0 to 7;

	COMPONENT data_processor IS
		PORT(
			-- Common control signals
		    rst				: IN    std_logic; -- rst
		    clk 			: IN    std_logic; -- clk-- Control entity for dataprocessing the BCID's below the sort threshord AND ahead of schedual
		    
		    -- Data transfer
		    data_in     	: IN 	dataTrain; -- data in
		    data_out    	: OUT 	dataTrain; -- data out

		    data_size_in   	: IN    std_logic_vector(7 downto 0);
		    data_size_out 	: OUT   std_logic_vector(7 downto 0);
		    
		    -- Data processor active flag
		    process_ready 	: INOUT std_logic;
		    process_complete: INOUT std_logic;

		    -- BCID Address
		    BCID_in        	: IN    std_logic_vector(RAM_ADDR_SIZE-1 downto 0); 
		    BCID_out       	: OUT   std_logic_vector(RAM_ADDR_SIZE-1 downto 0)
		   );
	END COMPONENT;

BEGIN
	
	GEN_processors: for I in 0 to data_processor_count-1 GENERATE
		processor_X: data_processor port map(
			rst,
		    clk,
		    
		    -- Data transfer
		    processor_in(I),
		    processor_out(I),
		    
		    processor_size_in(I),
		    processor_size_out(I),
		    
		    -- Data processor active flag
		    processor_ready(I),
		    processor_complete(I),

		    -- BCID Address
		    processor_bcid_in(I),
		    processor_bcid_out(I)
			);
	END GENERATE GEN_processors;

	PROCESS(rst, clk, en) -- data in process
	BEGIN

		IF (rst = '1' OR en = '0') THEN

			FIF0_wr_en <= '0'
			rd_en <= '0';
			wr_en <= '0';

			ct_addr <= '0X000';

			rd_state := 0;

			rd_processor_num := 0;

		ELSIF rising_edge(clk) THEN

			IF rd_state = 0 THEN

				IF ct_data <= OVERFLOW_SIZE AND ct_data != '0X000' THEN

					-- mark as processed
					FIFO_data <= (OTHERS => '0');
					FIFO_wr_en <= '1';

					-- store addr and size
					rd_bcid_store <= ct_addr;
					rd_size_store <= ct_data;

					-- read data in
					rd_state := 1;
				ELSE

					-- flag for bypass
					FIFO_data <= ct_data;
					FIFO_wr_en <= '1';

					-- prep for next addr
					IF rd_addr = '0X1FF' THEN
						rd_addr <= '0X000';
					ELSE
						rd_addr <= rd_addr + 1;
					END IF;
					
					IF ct_addr = '0X1FF' THEN
						ct_addr <= '0X000';
					ELSE
						ct_addr <= ct_addr + 1;
					END IF;
				END IF;

			ELSIF rd_state = 1 THEN

				FIFO_wr_en <= '0';

				-- Bens read from ram code goes here
				rd_data_store <= 'Full Data train' -- sudo code

				-- prep for next state
				rd_state := 2;
				rd_processor_num := rd_processor_num + 1;

			ELSIF rd_state = 2 THEN

				IF processor_ready(rd_processor_num) = '0' THEN -- Check if processor is free
					rd_processor_num := rd_processor_num + 1; -- This **shouldn't** ever be needed, but just in case.
				ELSE
					-- pass data to processor
					processor_in 		(rd_processor_num) <= rd_data_store;
					processor_bcid_in 	(rd_processor_num) <= rd_bcid_store;
					processor_size_in 	(rd_processor_num) <= rd_size_store;
					processor_ready 	(rd_processor_num) <= '0';

					-- prep for next addr
					IF rd_addr = '0X1FF' THEN
						rd_addr <= '0X000';
					ELSE
						rd_addr <= rd_addr + 1;
					END IF;
					
					IF ct_addr = '0X1FF' THEN
						ct_addr <= '0X000';
					ELSE
						ct_addr <= ct_addr + 1;
					END IF;

					rd_state := 0;

				END IF;
			END IF;
		END IF;

	END PROCESS;

	-- continious input assignment
	rd_addr <= rd_bcid_store(4 downto 0) & std_logic_vector(to_unsigned(rd_itteration, sppram_rd_address_size - 1));
	rd_data_split(rd_itteration) <= rd_data;

	PROCESS(rst,clk) -- data out process
	BEGIN

		IF rst = '1' THEN

			wr_en <= '0';
			wr_processor_num := 0;

		ELSIF rising_edge(clk) THEN

			IF wr_state = 0 THEN -- look for finished processor


				IF process_complete(wr_processor_num) = '1' THEN

					-- collect from processor
					wr_data_store <= processor_out(wr_processor_num);
					wr_size_store <= processor_size_out(wr_processor_num);
					wr_bcid_store <= processor_bcid_out(wr_processor_num);

					-- signal collection
					processor_complete(wr_processor_num) <= '0';

					-- next state prep
					wr_state := 1;
					wr_en <= '1';
					wr_iteration := 0;

				ELSE
					-- check next processor
					wr_processor_num := wr_processor_num + 1;
				END IF;

			ELSIF wr_state = 1 THEN -- read out 

				-- check if last itteration
				IF wr_iteration*16 >= wr_size_store THEN
					state := 0;
					wr_en <= '0'
				ELSE
					wr_iteration := wr_iteration + 1;
				END IF;

			END IF;

		END IF;

	END PROCESS;
	
	-- continious output assignment	
	wr_addr <= wr_bcid_store(4 downto 0) & std_logic_vector(to_unsigned(wr_iteration, sppram_wr_address_size - 1));
	wr_data <= wr_data_split(wr_iteration);

end a;