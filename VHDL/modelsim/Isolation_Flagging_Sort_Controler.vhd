-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.Isolation_Flagging_Package.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Detector_Constant_Declaration.all;


ENTITY Isolation_Flagging_Sort_Controller IS
  port(
    
    global_rst			    : IN    std_logic;
 	  global_clk_160MHz	  : IN    std_logic;
    router_data_in		  : IN 	  dataTrain;
    train_size          : IN    std_logic_vector(7 downto 0);
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

  COMPONENT counter_8bit IS
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

  -- ##### counter_8bit ##### --
  SIGNAL counter_8bit_enable        : std_logic;
  SIGNAL counter_8bit_value         : std_logic_vector(7 downto 0);
  SIGNAL counter_8bit_reset         : std_logic;
  SIGNAL counter_8bit_reset_global  : std_logic;

BEGIN
  
  Sort_Unit : Isolation_Flagging_Sort_Unit
    PORT MAP (
      rst             => Control_RST,
      dataIn          => Control_BubbleSort,
      parity          => Control_Parity,
      clk             => Clock_BubbleSort,
      dataOut         => BubbleSort_Control
    );

  itteration_counter : counter_8bit
    PORT MAP (
      clk   => Clock_BubbleSort,
      rst   => counter_8bit_reset_global,
      en    => counter_8bit_enable,
      count => counter_8bit_value
      );

  ------------------------------------------------------------------
  ---------------------- Control Process ---------------------------

  -- sorter
  RST_Control       <= global_rst;  
  Router_Control    <= router_data_in;
  Clock_BubbleSort  <= global_clk_160MHz;
  sorted_data_out   <= Control_DataOut;
  Control_RST       <= RST_Control;


  --counter_8bit
  counter_8bit_enable <= '1';
  counter_8bit_reset_global <= counter_8bit_reset OR Control_RST;



  PROCESS(global_clk_160MHz, global_rst)
  BEGIN

    IF (RST_Control = '1') THEN 
      Control_DataOut   <= reset_patten_train;
      Control_BubbleSort <= reset_patten_train;
      process_complete  <= '1';
      Control_Parity <= '1';

    ELSIF rising_edge(global_clk_160MHz) THEN     

      IF (counter_8bit_value = train_size - 1) THEN
        process_complete <= '1';
        counter_8bit_reset <= '1';
        Control_DataOut <= BubbleSort_Control;
        Control_BubbleSort <= Router_Control;
      ELSE
        process_complete <= '0';
        counter_8bit_reset <= '0';
        Control_BubbleSort <= BubbleSort_Control;
      END IF;

      Control_Parity <= NOT Control_Parity;

    END IF;
    
  END PROCESS;

END a;
