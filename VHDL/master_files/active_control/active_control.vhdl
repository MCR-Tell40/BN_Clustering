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
		clk, rst : IN std_logic;

		-- Router Interface
		rd_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		rd_en	:	OUT std_logic;
		rd_buff :	IN 	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

		-- MEP Interface
		wr_addr : 	OUT std_logic_vector ( RAM_ADDR_SIZE-1 downto 0);
		wr_en	:	OUT std_logic;
		wr_buff :	OUT	std_logic_vector ( (IF_WORD_LENGTH*32)-1 downto 0);

	);

END Active_Control;

ARCHITECTURE a OF Active_Control IS
BEGIN

	COMPONENT data_processor IS
		PORT(
		    global_rst			    : IN    std_logic;
		    global_clk_160MHz	  : IN    std_logic;
		    router_data_in		  : IN 	  dataTrain;
		    train_size          : IN    std_logic_vector(7 downto 0);
		    sorted_data_out     : OUT 	dataTrain;
		    process_complete    : INOUT std_logic;
		    ctrl_loop_in        : IN    std_logic;
		    ctrl_loop_out       : OUT   std_logic
		   );
	END COMPONENT;

end a;