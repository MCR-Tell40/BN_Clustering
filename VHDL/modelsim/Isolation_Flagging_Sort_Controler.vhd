-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.Isolation_Flagging_Package.all;
USE work.Detector_Constant_Declaration.all;


ENTITY Isolation_Flagging_Sort_Controller IS
  port(
    
    global_rst			    : IN    std_logic;
 	  global_clk_160MHz	  : IN    std_logic;
    router_data_in		  : IN 	  dataTrain;
    sorted_data_out     : OUT 	dataTrain;
    process_complete    : INOUT   std_logic
  );
END Isolation_Flagging_Sort_Controller;

ARCHITECTURE a OF Isolation_Flagging_Sort_Controller IS
    
	-- ##### Components ##### --

  COMPONENT Isolation_Flagging_Sort_Unit IS
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

BEGIN
  
  BubbleSortInst1 : Isolation_Flagging_Sort_Unit
    PORT MAP (
      rst             => Control_RST,
      dataIn          => Control_BubbleSort,
      parity          => Control_Parity,
      clk             => Clock_BubbleSort,
      dataOut         => BubbleSort_Control
    );

  --Control_Parity <= '0';

  ------------------------------------------------------------------
  ---------------------- Control Process ---------------------------

  RST_Control       <= global_rst;  
  Router_Control    <= router_data_in;
  Clock_BubbleSort  <= global_clk_160MHz;
  sorted_data_out   <= Control_DataOut;
  Control_RST       <= RST_Control;

  PROCESS(global_clk_160MHz, global_rst)
    VARIABLE Comparison_count : integer;
  BEGIN


    IF (RST_Control = '1') THEN 
      Control_DataOut   <= reset_patten_train;
      Control_BubbleSort <= reset_patten_train;
      process_complete  <= '1';
      Control_Parity <= '1';
      Comparison_count := 0;

    ELSIF rising_edge(global_clk_160MHz) THEN     

      IF Comparison_count = OVERFLOW_SIZE THEN
        process_complete <= '1';
        Comparison_count := 0;
        Control_DataOut <= BubbleSort_Control;
        Control_BubbleSort <= Router_Control;
      ELSE
        process_complete <= '0';
        Comparison_count := Comparison_count + 1;
        Control_BubbleSort <= BubbleSort_Control;
      END IF;

      Control_Parity <= NOT Control_Parity;

    END IF;
    
  END PROCESS;

END a;