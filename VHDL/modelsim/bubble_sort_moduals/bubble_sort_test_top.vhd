
-- bubble_sort_test_top
-- top level used for testing of bubble sort
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 3/12/2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

use work.bubble_sort_package.all;

ENTITY bubble_sort_test_top IS
PORT (
	test_clk, test_rst: IN std_logic
	);
END bubble_sort_test_top;


ARCHITECTURE a OF bubble_sort_test_top IS

	COMPONENT bubbleSortController IS
	  port(    
	    global_rst			: IN    std_logic;
	 	global_clk_160MHz	: IN    std_logic;
	    router_data_in		: IN 	dataTrain;
	    sorted_data_out     : OUT 	dataTrain;
	    process_complete    : INOUT std_logic
	  );
	END COMPONENT;


	COMPONENT reader is
	  
	  port(
	    clk  		: in  std_logic;
	    rst  		: in  std_logic;
	    --valid_out : out std_logic;
	    out_train 	: out  datatrain
	    );
	end COMPONENT ;

	-- SIGNALS
	signal reader_bubble_train_out, router_data_in, sorted_data_out		: datatrain;
	signal process_complete								: std_logic;
  -- ##### Reset Constants ##### --
	CONSTANT reset_patten_spp    : std_logic_vector(29 downto 0) := (others => '0');
	CONSTANT reset_patten_train  : dataTrain := (others => reset_patten_spp);

	BEGIN

	   readerinst1: reader
	   	PORT MAP (
	    	rst             => test_rst,
	    	clk             => test_clk,
	    	out_train       => reader_bubble_train_out
	    );

	    bubbleinst1: bubbleSortController
	     port map (
	       	global_rst			  => test_rst,  
		 	global_clk_160MHz	  => test_clk,
		    router_data_in		  => router_data_in,
		    sorted_data_out		  => sorted_data_out,
		    process_complete      => process_complete 
	  );

	PROCESS(test_clk, test_rst)
	BEGIN

		if test_rst='1' then

			router_data_in <= reset_patten_train;
			--process_complete <= '0';

		elsif rising_edge(test_clk) then 

			--process_complete <= '1';
			router_data_in <= reader_bubble_train_out;

		end if;

	END PROCESS;
END a;

