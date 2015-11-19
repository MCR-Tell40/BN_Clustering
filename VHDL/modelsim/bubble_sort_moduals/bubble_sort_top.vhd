-- Bubble Sort Top
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- type def for array of std logic vectors
TYPE dataTrain IS array (99 downto 0) OF std_logic_vector(29 downto 0);

entity bubbleSortController is
  port(
    
    global_rst			    : IN    std_logic;
 	  global_clk_160MHz	  : IN    std_logic;
    router_data_in		  : IN 	  dataTrain;

    sorted_data_out     : OUT 	dataTrain
    );
end bubbleSortController;

architecture a of bubbleSortController is
    
	-- ##### Components ##### --

  	COMPONENT BubbleSort IS
 	 	PORT(
  			clk				: in 	std_logic;
  			rst 			: in 	std_logic;	

   			dataIn          : in 	dataTrain;
    		beginSortValid	: in 	std_logic; -- not convinsed this is needed

    		dataOut   		  : out dataTrain;
    		switchMadeValid : out std_logic;
    		switchMadeReset : in 	std_logic
   		);
	END COMPONENT;

	-- ##### Data Busses ##### --

	SIGNAL Router_Control          	  : dataTrain;
	SIGNAL BubbleSortEven_Control     : dataTrain;
	SIGNAL BubbleSortOdd_Control	    : dataTrain;

  SIGNAL Conrol_DataOut             : dataTrain;
  SIGNAL Conrol_BubbleSortEven      : dataTrain;
  SIGNAL Conrol_BubbleSortOdd       : dataTrain;

	-- ##### Validation Signals ##### --

	SIGNAL BubbleSortEven_SwitchMade 	: std_logic;
	SIGNAL BubbleSortOdd_SwitchMade 	: std_logic;

	-- ##### Clock and Reset ##### --

	SIGNAL clk_160MHz  : std_logic;
	SIGNAL rst 			   : std_logic;	

BEGIN
  
  BubbleSortOdd : BubbleSort(odd)
    PORT MAP (
      clk             => global_clk_40MHz;
      rst             => global_rst;
      );

  BubbleSortEven : BubbleSort(even)
    PORT MAP (
      clk             => global_clk_160MHz;
      rst             => global_rst;
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