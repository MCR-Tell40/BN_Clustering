-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sort_function.all;


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
  		rst 			: in 	std_logic;	
  		dataIn          : in 	dataTrain;
      parity          : in  std_logic;
   		dataOut   		  : out dataTrain
  	);
	END COMPONENT;

	-- ##### Data Busses ##### --

	SIGNAL Router_Control          	  : dataTrain;
	SIGNAL BubbleSort_Control	        : dataTrain;

  SIGNAL Control_DataOut            : dataTrain;
  SIGNAL Control_BubbleSort         : dataTrain;

	-- ##### Validation Signals ##### --

  SIGNAL Control_Parity               : std_logic;

	-- ##### Clock and Reset ##### --

  SIGNAL Control_RST                : std_logic;
  SIGNAL RST_Control                : std_logic;

  -- ##### Reset Constants ##### --

  constant reset_patten_spp   : std_logic_vector(29 downto 0) := (others => '0');
  constant reset_patten_train : dataTrain := (others => reset_patten_spp);

BEGIN
  
  BubbleSortInst1 : BubbleSort
    PORT MAP (
      rst             => Control_RST,
      dataIn          => Control_BubbleSort,
      parity          => Control_Parity,
      dataOut         => BubbleSort_Control
    );

  Control_Parity <= '0';

  PROCESS(global_clk_160MHz, global_rst)
    VARIABLE BubbleSortEven_SwitchMade  : std_logic;
    VARIABLE BubbleSortOdd_SwitchMade   : std_logic;
  BEGIN
    RST_Control       <= global_rst;	
    Router_Control    <= router_data_in;

    If (RST_Control = '1') THEN 
      Control_RST     <= RST_Control;
      Control_DataOut <= reset_patten_train;


    ELSIF rising_edge(global_clk_160MHz) THEN     
      if BubbleSort_Control = Control_BubbleSort AND Control_Parity = '1' THEN
        BubbleSortOdd_SwitchMade :='0';
      elsif  BubbleSort_Control = Control_BubbleSort AND Control_Parity = '0' THEN
        BubbleSortEven_SwitchMade := '0';
      else
        BubbleSortEven_SwitchMade :='1';
        BubbleSortOdd_SwitchMade :='1';
      end if;

      IF BubbleSortEven_SwitchMade = '1' OR BubbleSortOdd_SwitchMade = '1' THEN 
        Control_BubbleSort <= BubbleSort_Control;
        Control_Parity <= NOT Control_Parity;
      ELSE
        Control_DataOut <= BubbleSort_Control;
      END IF; 

    END IF;
    
  END PROCESS;

END a;