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

	GENERIC(
		CONSTANT data_processor_count : NATURAL := 16;
	);

	PORT(
		-- standard
		clk, rst : IN std_logic;

		-- Router Interface
		rd_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		rd_en	:	OUT std_logic;
		rd_buff :	IN 	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- Train Size RAM interface ct=count
		ct_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		ct_buff :	IN 	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- MEP Interface
		wr_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		wr_en	:	OUT std_logic;
		wr_buff :	OUT	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- Bypass Interace
		FIFO_wr_en 	:	OUT std_logic;
		FIFO_buff	:	OUt std_logic_vector (6 downto 0)
	);

END Active_Control;

ARCHITECTURE a OF Active_Control IS

	SHARED VARIABLE in_state 		: INTEGER range 0 to 4;
	SHARED VARIABLE in_register 	: datatrain;
	SHARED VARIABLE processor_num 	: INTEGER range 0 to data_processor_count-1;
	SHARED VARIABLE addr_store		: std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	SHARED VARIABLE size_store		: std_logic_vector(7 downto 0);

	COMPONENT data_processor IS
		PORT(
			-- Common control signals
		    rst		: IN    std_logic; --rst
		    clk 	: IN    std_logic; --clk
		    
		    -- Data transfer
		    data_in     : IN 	dataTrain; --data_in
		    data_out    : OUT 	dataTrain; --data_out

		    data_size_in   	: IN    std_logic_vector(7 downto 0);
		    data_size_out 	: OUT   std_logic_vector(7 downto 0);
		    
		    -- Data processor active flag
		    process_complete    : INOUT std_logic;

		    -- BCID Address
		    BCID_Addr_in        : IN    std_logic_vector(RAM_ADDR_SIZE-1 downto 0); 
		    BCID_Addr_out       : OUT   std_logic_vector(RAM_ADDR_SIZE-1 downto 0)
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
		    processor_complete(I),

		    -- BCID Address
		    processor_Addr_in(I),
		    processor_Addr_out(I)
			);
	END GENERATE GEN_processors;

	PROCESS(rst, clk)
	BEGIN

		IF (rst = '1') THEN

			rd_addr <= '0X000';
			rd_en <= '0';

			ct_addr <= '0X000';

			wr_addr <= '0X000';
			wr_en <= '0';

			FIF0_wr_en <= '0'

			in_state := 0;

			processor_num := 0;

		ELSIF rising_edge(clk) THEN

			IF in_state = 0 THEN

				IF ct_buff <= OVERFLOW_SIZE AND ct_buff != '0X000' THEN

					-- mark as processed
					FIFO_buff <= (OTHERS => '0');
					FIFO_wr_en <= '1';

					-- store addr and size
					addr_store <= ct_addr;
					size_store <= ct_buff;

					-- read data in
					in_state := in_state + 1;
				ELSE

					-- flag for bypass
					FIFO_buff <= ct_buff;
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

			ELSIF in_state = 1 THEN

				-- Bens read from ram code goes here
				in_register <= 'Full Data train' -- sudo code

				-- prep for next state
				in_state := in_state + 1;
				processor_num := processor_num + 1;

			ELSIF in_state = 2 THEN

				IF processor_complete(processor_num) = '0' THEN -- Check if processor is free
					processor_num := processor_num + 1; -- This **shouldn't** ever be needed, but just in case.
				ELSE
					-- pass data to processor
					processor_in 		(processor_num) <= in_register;
					processor_addr_in 	(processor_num) <= addr_store;
					processor_size_in 	(processor_num) <= size_store;
					processor_complete 	(processor_num) <= '0';

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

					in_state := 0;

				END IF;


			END IF;



		END IF;

	END PROCESS;

	

end a;