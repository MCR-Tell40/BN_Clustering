-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.bubble_sort_package.all;
USE work.Detector_Constant_Declaration.all;


ENTITY bubbleSortController IS
  port(
    
    global_rst			    : IN    std_logic;
 	  global_clk_160MHz	  : IN    std_logic;
    router_data_in		  : IN 	  dataTrain;
    train_size          : IN    std_logic_vector(7 downto 0);
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

  COMPONENT counter IS
    PORT(
    clk   :   IN std_logic;
    rst   :   IN std_logic;
    en    :   IN std_logic;
    count :   OUT std_logic_vector(7 downto 0)
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

  -- ##### counter ##### --
  SIGNAL counter_enable        : std_logic;
  SIGNAL counter_value         : std_logic_vector(7 downto 0);
  SIGNAL counter_reset         : std_logic;
  SIGNAL counter_reset_global  : std_logic;

BEGIN
  
  BubbleSortInst1 : BubbleSort
    PORT MAP (
      rst             => Control_RST,
      dataIn          => Control_BubbleSort,
      parity          => Control_Parity,
      clk             => Clock_BubbleSort,
      dataOut         => BubbleSort_Control
    );

  counterInst1 : counter
    PORT MAP (
      clk   => Clock_BubbleSort,
      rst   => counter_reset_global,
      en    => counter_enable,
      count => counter_value
      );

  ------------------------------------------------------------------
  ---------------------- Control Process ---------------------------

  -- sorter
  RST_Control       <= global_rst;  
  Router_Control    <= router_data_in;
  Clock_BubbleSort  <= global_clk_160MHz;
  sorted_data_out   <= Control_DataOut;
  Control_RST       <= RST_Control;


  --counter
  counter_enable <= '1';

  counter_reset_global <= counter_reset OR Control_RST;

  PROCESS(global_clk_160MHz, global_rst)
    --VARIABLE BubbleSortEven_SwitchMade  : std_logic;
    --VARIABLE BubbleSortOdd_SwitchMade   : std_logic;
    --VARIABLE Comparison_count : integer;
  BEGIN

    IF (RST_Control = '1') THEN 
      Control_DataOut   <= reset_patten_train;
      Control_BubbleSort <= reset_patten_train;
      process_complete  <= '1';
      Control_Parity <= '1';

    ELSIF rising_edge(global_clk_160MHz) THEN     

      IF (counter_value = train_size - 1) THEN
        process_complete <= '1';
        counter_reset <= '1';
        Control_DataOut <= BubbleSort_Control;
        Control_BubbleSort <= Router_Control;
      ELSE
        process_complete <= '0';
        counter_reset <= '0';
        Control_BubbleSort <= BubbleSort_Control;
      END IF;

      Control_Parity <= NOT Control_Parity;

    END IF;
    
  END PROCESS;

END a;