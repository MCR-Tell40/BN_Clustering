-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

use work.sort_function.all;


ENTITY bubbleSortController IS
  port(
    
    global_rst			    : IN    std_logic;
 	  global_clk_160MHz	  : IN    std_logic;
    router_data_in		  : IN 	  dataTrain;
    sorted_data_out     : OUT 	dataTrain;
    process_complete    : INOUT   std_logic
  );
END bubbleSortController;

ARCHITECTURE a OF bubbleSortController IS
    
	-- ##### Components ##### --
  COMPONENT BubbleSort IS
 		PORT(
  		rst 			 : in 	std_logic;	
  		dataIn     : in 	dataTrain;
      parity     : in   std_logic;
      clk        : in   std_logic;
   		dataOut    : out  dataTrain
  	);
	END COMPONENT;

	-- ##### Data Busses ##### --
	SIGNAL Router_Control        : dataTrain;
	SIGNAL BubbleSort_Control	   : dataTrain;

  SIGNAL Control_DataOut       : dataTrain;
  SIGNAL Control_BubbleSort    : dataTrain;

	-- ##### Validation Signals ##### --
  SIGNAL Control_Parity        : std_logic;

	-- ##### Clock and Reset ##### --
  SIGNAL Control_RST           : std_logic;
  SIGNAL RST_Control           : std_logic;
  SIGNAL Clock_BubbleSort      : std_logic;

  -- ##### Reset Constants ##### --
  CONSTANT reset_patten_spp    : std_logic_vector(29 downto 0) := (others => '0');
  CONSTANT reset_patten_train  : dataTrain := (others => reset_patten_spp);

BEGIN
  
  BubbleSortInst1 : BubbleSort
    PORT MAP (
      rst             => Control_RST,
      dataIn          => Control_BubbleSort,
      parity          => Control_Parity,
      clk             => Clock_BubbleSort,
      dataOut         => BubbleSort_Control
    );

  Control_Parity <= '0';

  PROCESS(global_clk_160MHz, global_rst)
    VARIABLE BubbleSortEven_SwitchMade  : std_logic;
    VARIABLE BubbleSortOdd_SwitchMade   : std_logic;
  BEGIN
    RST_Control       <= global_rst;	
    Router_Control    <= router_data_in;
    Clock_BubbleSort  <= global_clk_160MHz;
    sorted_data_out   <= Control_DataOut;

    IF (RST_Control = '1') THEN 
      Control_RST       <= RST_Control;
      Control_DataOut   <= reset_patten_train;
      process_complete  <= '0';

    ELSIF rising_edge(global_clk_160MHz) THEN     

      IF process_complete = '1' THEN
        process_complete <= '0';
      END IF;

      IF BubbleSort_Control = Control_BubbleSort AND Control_Parity = '1' THEN
        BubbleSortOdd_SwitchMade :='0';
      ELSIF  BubbleSort_Control = Control_BubbleSort AND Control_Parity = '0' THEN
        BubbleSortEven_SwitchMade := '0';
      ELSE
        BubbleSortEven_SwitchMade :='1';
        BubbleSortOdd_SwitchMade :='1';
      END IF;

      IF BubbleSortEven_SwitchMade = '1' OR BubbleSortOdd_SwitchMade = '1' THEN 
        Control_BubbleSort <= BubbleSort_Control;
        Control_Parity <= NOT Control_Parity;
      ELSE
        Control_DataOut <= BubbleSort_Control;
        process_complete <= '1';
        Control_BubbleSort <= Router_Control;

      END IF; 

    END IF;
    
  END PROCESS;

END a;