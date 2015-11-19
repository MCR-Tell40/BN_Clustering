-- Bubble Sort Top
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- type def for array of std logic vectors
TYPE dataTrain IS array (99 downto 0) OF std_logic_vector(29 downto 0);

entity bubble_sort_top is
  port(
    
    global_rst			: IN    std_logic;
 	global_clk_40MHz	: IN    std_logic;
    router_data_in		: IN 	dataTrain;

    sorted_data_out		: OUT 	dataTrain

    );
end bubble_sort_top;

architecture a of bubble_sort_top is
    
	-- ##### Components ##### --

  	COMPONENT BubbleSortEven IS
 	 	PORT(
  			clk				: in 	std_logic;
  			rst 			: in 	std_logic;	

   			dataIn      	: in 	dataTrain;
    		beginSortValid	: in 	std_logic; -- not convinsed this is needed

    		dataOut   		: out 	dataTrain;
    		switchMadeValid : out 	std_logic;
    		switchMadeReset : in 	std_logic
   		);
	END COMPONENT;
  
  	COMPONENT BubbleSortOdd IS
 	 	PORT(
  			clk				: in 	std_logic;
  			rst 			: in 	std_logic;	

   			dataIn      	: in 	dataTrain;
    		beginSortValid	: in 	std_logic; -- not convinsed this is needed

    		dataOut   		: out 	dataTrain;
    		switchMadeValid : out 	std_logic;
    		switchMadeReset : in 	std_logic
   		);
	END COMPONENT;

	-- ##### Data Busses ##### --

	SIGNAL Router_to_BubbleSortEven	: dataTrain;
	SIGNAL BubbleSortEven_to_Odd	: dataTrain;
	SIGNAL BubbleSortOdd_to_Even	: dataTrain;

	SIGNAl BubbleSortEven_out		: datatrain;
	SIGNAl BubbleSortOdd_out		: datatrain;

	-- ##### Validation Signals ##### --

	SIGNAL BubbleSortEven_SwitchMade 	: std_logic;
	SIGNAL BubbleSortOdd_SwitchMade 	: std_logic;

	-- ##### Clock and Reset ##### --

	SIGNAL clk_160MHz 	: std_logic;
	SIGNAL rst 			: std_logic;	

  
BEGIN
  
  
  -- ##### not yet done ##### --
  
  read_inst1 : the_reader
    PORT MAP (
      clk_40MHz         => clock160_reg,
      rst	        => reset_reg,
      pixel_read 	=> read_to_descramble
      );
  
  
  RX_inst1 : scrambler
    PORT MAP (
      rst 	        => reset_reg,
      clk_160MHz 	=> clock160_reg,
--      data_in           => read_to_descramble,
      data_in           => "000000000011111111110000000000",
      data_out  	=> descramble_to_write
      );		
  
  write_inst1 : the_writer
    PORT MAP (
      pixel_write       => descramble_to_write,
      rst	        => reset_reg,
      clk_40MHz	        => clock160_reg
      );
  


  PROCESS(csi_Clock_160MHz, rsi_Reset)
  BEGIN

    reset_reg <= rsi_Reset;
    clock160_reg <= csi_Clock_160MHz;		

    If (rsi_Reset = '1') THEN 
      
      
      --scrambler_data_out <= (OTHERS => '0');

    ELSIF rising_edge(csi_Clock_160MHz) THEN     
      
      --scrambler_data_out <= data_output_reg;		
      --report "data_output_reg=" & stdvec_to_str(data_output_reg);

    END IF;
    
  END PROCESS;

END a;