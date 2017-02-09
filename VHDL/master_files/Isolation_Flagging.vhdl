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

ENTITY isolation_flagging IS 

	PORT(
		-- standard
		clk, rst : IN std_logic;

		rd_addr 	: 	OUT std_logic_vector ( RD_RAM_ADDR_SIZE-1 downto 0);
		rd_en		:	OUT std_logic;
		rd_data 	:	INOUT 	std_logic_vector ( RD_WORD_SIZE -1 downto 0);

		-- Train Size RAM interface ct=count
		ct_addr : 	OUT std_logic_vector ( 8 downto 0);
		ct_data :	IN 	std_logic_vector ( COUNT_RAM_WORD_SIZE - 1 downto 0);

		-- MEP Interface
		wr_addr 	: 	OUT std_logic_vector ( WR_RAM_ADDR_SIZE-1 downto 0);
		wr_en		:	OUT std_logic;
		wr_data 	:	OUT	std_logic_vector ( WR_WORD_SIZE - 1 downto 0);

		-- Bypass Interace
		FIFO_rd_en 	:	OUT std_logic;
		FIFO_data	:	IN  std_logic_vector (6 downto 0);
		FIFO_empty  : 	IN 	std_logic

	);

END isolation_flagging;

ARCHITECTURE a OF isolation_flagging IS
	
	SHARED VARIABLE clk_count : natural;
	
	---------- ---------- SIGNALS ---------- ----------
	SIGNAL inter_clk, inter_rst : STD_LOGIC;

	-- count ram pipes
	SIGNAL ct_addr_pipe : 	std_logic_vector ( 8 downto 0);
	SIGNAL ct_data_pipe :	std_logic_vector ( COUNT_RAM_WORD_SIZE - 1 downto 0);

	-- fifo pipes
	SIGNAL FIFO_wr_en_pipe, FIFO_rd_en_pipe, FIFO_empty_pipe : STD_LOGIC;
	SIGNAL FIFO_wr_data_pipe, FIFO_rd_data_pipe :  std_logic_vector (6 downto 0);

	-- active controll pipes
	SIGNAL ac_en_pipe: std_logic;
	SIGNAL ac_rd_addr_pipe	 					: 	std_logic_vector( RD_RAM_ADDR_SIZE-1 downto 0);
	SIGNAL ac_wr_addr_pipe						: 	std_logic_vector( WR_RAM_ADDR_SIZE-1 downto 0);
	SIGNAL ac_rd_data_pipe 						: 	std_logic_vector( RD_WORD_SIZE - 1 downto 0);
	SIGNAL ac_wr_data_pipe						: 	std_logic_vector( WR_WORD_SIZE - 1 downto 0);
	SIGNAL ac_rd_en_pipe, 		ac_wr_en_pipe 	:	std_logic;
	SIGNAL bypass_en_pipe 						: 	std_logic;

	-- Bypass controll pipes
	SIGNAL by_rd_addr_pipe 						: 	std_logic_vector ( RD_RAM_ADDR_SIZE-1 downto 0);
	SIGNAL by_wr_addr_pipe 						: 	std_logic_vector ( WR_RAM_ADDR_SIZE-1 downto 0);
	SIGNAL by_rd_data_pipe 						: 	std_logic_vector ( RD_WORD_SIZE - 1 downto 0);
	SIGNAL by_wr_data_pipe 						:	std_logic_vector ( WR_WORD_SIZE - 1 downto 0);
	SIGNAL by_rd_en_pipe, 		by_wr_en_pipe 	:	std_logic;
	---------- ---------- COMPONENTS ---------- ----------

	COMPONENT active_control IS
		PORT(
			-- Common control signals
		    clk 		: IN    std_logic; 
		    rst			: IN    std_logic; 
		    en 			: IN 	std_logic;

		    -- Router Interface
			rd_addr : 	OUT std_logic_vector ( RD_RAM_ADDR_SIZE-1 downto 0);
			rd_en	:	OUT std_logic;
			rd_data :	IN 	std_logic_vector ( RD_WORD_SIZE - 1 downto 0);

			-- Train Size RAM interface ct=count
			ct_addr : 	OUT std_logic_vector ( 8 downto 0);
			ct_data :	IN 	std_logic_vector ( COUNT_RAM_WORD_SIZE - 1 downto 0);

			-- MEP Interface
			wr_addr : 	OUT std_logic_vector ( WR_RAM_ADDR_SIZE-1 downto 0);
			wr_en	:	OUT std_logic;
			wr_data :	OUT	std_logic_vector ( WR_WORD_SIZE - 1 downto 0);

			-- Bypass Interace
			FIFO_wr_en 	:	OUT std_logic;
			FIFO_data	:	OUt std_logic_vector (6 downto 0);
			bypass_en 	: 	OUT std_logic
		   );
	END COMPONENT;

	COMPONENT interface_FIFO is
		
		Generic (
		
			constant DATA_WIDTH  : positive := 6;
			constant FIFO_DEPTH	: positive := 32
		
		);
		
		Port ( 
			-- INPUT
			clk		: in  STD_LOGIC;
			rst		: in  STD_LOGIC;
			WriteEn	: in  STD_LOGIC;
			DataIn	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
			ReadEn	: in  STD_LOGIC;
			-- OUTPUT
			DataOut	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
			Empty	: out STD_LOGIC;
			Full	: out STD_LOGIC
		);

	end COMPONENT;

	COMPONENT Bypass_Control IS 

		GENERIC(

			ADDR_PER_RAM 		: INTEGER := 32;
			MAX_RAM_ADDR_STORE 	: INTEGER := 512;
			SPP_PER_ADDR 		: INTEGER := 16

			);

		PORT(
			-- standard
			clk, rst, en : IN std_logic;

			-- Router Interface
			rd_addr : 	OUT std_logic_vector ( RD_RAM_ADDR_SIZE-1 downto 0);
			rd_en	:	OUT std_logic;
			rd_data :	IN 	std_logic_vector ( RD_WORD_SIZE - 1 downto 0);

			-- MEP Interface
			wr_addr : 	OUT std_logic_vector ( WR_RAM_ADDR_SIZE-1 downto 0);
			wr_en	:	OUT std_logic;
			wr_data :	OUT	std_logic_vector ( WR_WORD_SIZE - 1 downto 0);

			-- Bypass Interace
			FIFO_rd_en 	:	OUT std_logic;
			FIFO_data	:	IN  std_logic_vector (6 downto 0);
			FIFO_empty  : 	IN 	std_logic 
		);

	END COMPONENT;

BEGIN

	active_control1 : active_control
    PORT MAP (
	    clk       => inter_clk,
	    rst       => inter_rst,
	    en 		  => ac_en_pipe,

	    rd_addr 	=> ac_rd_addr_pipe,
		rd_en		=> ac_rd_en_pipe,
		rd_data 	=> ac_rd_data_pipe,

		-- Train Size RAM interface ct=count
		ct_addr 	=> ct_addr_pipe,
		ct_data 	=> ct_data_pipe,

		-- MEP Interface
		wr_addr 	=> ac_wr_addr_pipe,
		wr_en		=> ac_wr_en_pipe,
		wr_data 	=> ac_wr_data_pipe,

		-- Bypass Interace
		FIFO_wr_en 		=> FIFO_wr_en_pipe,
		FIFO_data		=> FIFO_wr_data_pipe,
		bypass_en 		=> bypass_en_pipe
    );

    interface_FIFO1 : interface_FIFO
    PORT MAP(
    	clk		=> inter_clk,
		rst		=> inter_rst,
		WriteEn	=> FIFO_wr_en_pipe,
		DataIn	=> FIFO_wr_data_pipe,
		ReadEn	=> FIFO_rd_en_pipe,
		-- OUTPUT
		DataOut	=> FIFO_rd_data_pipe,
		Empty	=> FIFO_empty_pipe
    );
	
	bypass_control1 : bypass_control
    PORT MAP (
	    clk 	=> inter_clk,
	    rst     => inter_rst,
	    en 		=> bypass_en_pipe,

	    rd_addr 	=> by_rd_addr_pipe,
		rd_en		=> by_rd_en_pipe,
		rd_data 	=> by_rd_data_pipe,

		-- MEP Interface
		wr_addr 	=> by_wr_addr_pipe,
		wr_en		=> by_wr_en_pipe,
		wr_data 	=> by_wr_data_pipe,

		-- Bypass Interace
		FIFO_rd_en 	=> FIFO_rd_en_pipe,
		FIFO_data	=> FIFO_rd_data_pipe,
		FIFO_empty  => FIFO_empty_pipe
    );

process(clk)
begin
    IF bypass_en_pipe = '1' THEN

    	rd_addr <= by_rd_addr_pipe;
    	rd_data <= by_rd_data_pipe;
    	rd_en 	<= by_rd_en_pipe;

    	wr_addr <= by_wr_addr_pipe;
    	wr_data <= by_wr_data_pipe;
    	wr_en 	<= by_wr_en_pipe;

    ELSE -- active control

    	rd_addr <= ac_rd_addr_pipe;
    	rd_data <= ac_rd_data_pipe;
    	rd_en 	<= ac_rd_en_pipe;

    	wr_addr <= ac_wr_addr_pipe;
    	wr_data <= ac_wr_data_pipe;
    	wr_en 	<= ac_wr_en_pipe;    	

    END IF;
end process;
    process(rst, clk)
begin

    	IF rst = '1' THEN
    		clk_count := 0;
    		ac_en_pipe <= '0';
    	ELSIF rising_edge(clk) THEN

    		IF clk_count < BUFFER_LIFETIME-1 THEN
    			ac_en_pipe <= '1';
    			clk_count := clk_count + 1;
    		ELSE
    			ac_en_pipe <= '0';
    			clk_count := 0;
    		END IF;

    	END IF;

    END process;

end a;