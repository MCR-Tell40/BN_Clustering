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

		-- MEP Interface
		wr_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		wr_en	:	OUT std_logic;
		wr_buff :	OUT	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- Bypass Interace
		FIFO_en :	OUT std_logic;
		FIFO_buff:	OUt std_logic_vector (6 downto 0)
	);

END Active_Control;

ARCHITECTURE a OF Active_Control IS

	SHARED VARIABLE state : INTEGER range 0 to 4;

	COMPONENT data_processor IS
		PORT(
			-- Common control signals
		    rst		: IN    std_logic; --rst
		    clk 	: IN    std_logic; --clk
		    
		    -- Data transfer
		    data_in     : IN 	  dataTrain; --data_in
		    data_out    : OUT 	dataTrain; --data_out
		    data_size   : IN    std_logic_vector(7 downto 0);
		    
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
		    processor_size(I),
		    
		    -- Data processor active flag
		    processor_complete(I),

		    -- BCID Address
		    processor_Addr_in(I),
		    processor_Addr_out(I)
			);
	END GENERATE GEN_processors;

	

end a;