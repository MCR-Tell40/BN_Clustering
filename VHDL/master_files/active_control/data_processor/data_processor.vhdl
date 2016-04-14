-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- for processes going to implement 4 state process
-- state 0 = waiting for data
-- state 1 = sorting data
-- state 2 = flag data
-- state 3 = ship data out

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.Isolation_Flagging_Package.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Detector_Constant_Declaration.all;


ENTITY Data_Processor IS
  port(
    
    global_rst			    : IN    std_logic;
  global_clk_160MHz	  : IN    std_logic;
    router_data_in		  : IN 	  dataTrain;
    train_size          : IN    std_logic_vector(7 downto 0);
    sorted_data_out     : OUT 	dataTrain;
    process_complete    : INOUT std_logic;
    ctrl_loop_in        : IN    std_logic;
    ctrl_loop_out       : OUT   std_logic
  );
END Data_Processor;

ARCHITECTURE a OF Data_Processor IS
    
	-- ##### Components ##### --

  COMPONENT Sorter IS
    PORT(
      rst           : in   std_logic; 
      dataIn        : in   dataTrain;
      parity        : in   std_logic;
      clk           : in   std_logic;
      dataOut       : out  dataTrain
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

  COMPONENT Flagger IS
    PORT(
      rst       : in  std_logic;  
      clk       : in  std_logic;
      data_in   : in  datatrain;
      data_out  : out datatrain
    );
  END COMPONENT;

	-- ##### Data Busses ##### --
	SIGNAL Router_Control        : dataTrain;
	SIGNAL BubbleSort_Control	   : dataTrain;

  SIGNAL Control_DataOut       : dataTrain;
  SIGNAL Control_BubbleSort    : dataTrain;

  SIGNAL Control_Flagging      : dataTrain;
  SIGNAL Flagging_Control      : dataTrain;

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

  -- state variable --
  SHARED VARIABLE state : integer range 0 to 2;

BEGIN
  
  Sort_Unit : Sorter
    PORT MAP (
      rst            => Control_RST,
      dataIn         => Control_BubbleSort,
      parity         => Control_Parity,
      clk            => Clock_BubbleSort,
      dataOut        => BubbleSort_Control      
      
    );

  itteration_counter : counter_8bit
    PORT MAP (
      clk   => Clock_BubbleSort,
      rst   => counter_8bit_reset_global,
      en    => counter_8bit_enable,
      count => counter_8bit_value
      );

  isol_flagging : Flagger
    PORT MAP (
      rst         => Control_RST,
      clk         => Clock_BubbleSort,
      data_in     => Control_Flagging,
      data_out    => Flagging_Control


      );


  ------------------------------------------------------------------
  ---------------------- Control Process ---------------------------

  -- sorter
  RST_Control         <= global_rst;  
  Router_Control      <= router_data_in;
  Clock_BubbleSort    <= global_clk_160MHz;
  sorted_data_out     <= Control_DataOut;
  Control_RST         <= RST_Control;
 
    
  --counter_8bit
  counter_8bit_enable <= '1';
  counter_8bit_reset_global <= counter_8bit_reset OR Control_RST;



  PROCESS(global_clk_160MHz, global_rst)
  BEGIN

    IF (global_rst = '1') THEN 
      Control_DataOut      <= reset_patten_train;
      Control_BubbleSort   <= reset_patten_train;
      process_complete     <= '1';
      Control_Parity       <= '1';
      ctrl_loop_out        <= '0';
      state                := 0;

    ELSIF rising_edge(global_clk_160MHz) THEN     

      IF state = 0  THEN 
     
        Control_BubbleSort <= Router_Control;
        state := 1;

      ELSIF state = 1 THEN
      
        IF (counter_8bit_value = train_size - 1) THEN
      
          process_complete   <= '1';
          counter_8bit_reset <= '1';
          Control_Flagging   <= BubbleSort_Control;
          state              := 2;
        
        ELSE  
      
          process_complete   <= '0';
          counter_8bit_reset <= '0';
          Control_BubbleSort <= BubbleSort_Control;
      
        END IF;

        Control_Parity       <= NOT Control_Parity;
     
      ELSIF state = 2 THEN
      
        Control_DataOut      <= Flagging_Control;
        ctrl_loop_out        <= ctrl_loop_in;
        state                := 0;
      
      END IF;

    END IF;
  
  END PROCESS;

END a;
