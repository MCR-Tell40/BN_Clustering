-- Bubble Sort Tops
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- for processes going to implement 4 state process
-- state 0 = waiting for data
-- state 1 = sorting data
-- state 2 = flag data
-- state 3 = ship data out
-- state 4 = wait for data to be read out

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.Isolation_Flagging_Package.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Detector_Constant_Declaration.all;


ENTITY Data_Processor IS
  port(
    
    -- Common control signals
    rst		: IN    std_logic; --rst
    clk	  : IN    std_logic; --clk
    
    -- Data transfer
    data_in        : IN 	dataTrain; --data_in
    data_out       : OUT 	dataTrain; --data_out
    data_size_in   : IN   std_logic_vector(DATA_SIZE_MAX_BIT - 1 downto 0);
    data_size_out  : OUT  std_logic_vector(DATA_SIZE_MAX_BIT - 1 downto 0);


    -- Data processor active flag
    process_ready       : INOUT std_logic;
    process_complete    : INOUT std_logic;

    -- BCID address
    BCID_addr_in        : IN    std_logic_vector(8 downto 0); 
    BCID_addr_out       : OUT   std_logic_vector(8 downto 0)
  );
END Data_Processor;

ARCHITECTURE a OF Data_Processor IS
    
	-- ##### Components ##### --

  COMPONENT Sorter IS
    PORT(
      rst           : in   std_logic; 
      parity        : in   std_logic;
      clk           : in   std_logic;
      data_in       : in   dataTrain;
      data_out      : out  dataTrain

    );
  END COMPONENT;

  COMPONENT counter_8bit IS
    PORT(
    clk   :   IN std_logic;
    rst   :   IN std_logic;
    en    :   IN std_logic;
    count :   OUT std_logic_vector(DATA_SIZE_MAX_BIT - 1 downto 0)
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

  -- Internal Signals
  SIGNAL internal_clk   : std_logic;
  SIGNAL internal_reg   : datatrain;
  SIGNAL internal_size  : std_logic_vector(DATA_SIZE_MAX_BIT-1 downto 0); 

  SHARED VARIABLE state : integer range 0 to 4;

  SIGNAL BCID_addr : std_logic_vector(8 downto 0);

  SIGNAL sorter_rst,      : std_logic;
  SIGNAL sorter_data_in   : datatrain;
  SIGNAL sorter_data_out  : datatrain;
  SIGNAL sorter_parity    : std_logic;
  
  SIGNAL counter_rst    : std_logic;
  SIGNAL counter_en     : std_logic;
  SIGNAL counter_value  : std_logic_vector(DATA_SIZE_MAX_BIT-1 downto 0);

  SIGNAL flagger_rst      : std_logic;     
  SIGNAL flagger_data_in  : datatrain;
  SIGNAL flagger_data_out : datatrain;

BEGIN
  ------------------------------------------------------------------
  ---------------------- Port Mapping ------------------------------ 

  Sorter : Sorter
    PORT MAP (
      clk       => internal_clk,
      rst       => sorter_rst,
      
      dataIn    => sorter_data_in,
      dataOut   => sorter_data_out,      
      
      parity    => sorter_parity

    );

  Counter : counter_8bit
    PORT MAP (
      clk   => internal_clk,
      rst   => counter_rst,

      en    => counter_en,
      count => counter_value
      );

  Flagger : Flagger
    PORT MAP (
      clk         => internal_clk,
      rst         => flagger_rst,
      
      data_in     => flagger_data_in,
      data_out    => flagger_data_out
      );


  ------------------------------------------------------------------
  ---------------------- Control Process ---------------------------

  -- Constant Signal Propergation

  internal_clk <= clk;
  sorter_data_in <= internal_reg;

  PROCESS(clk, rst)
  BEGIN

    IF (rst = '1') THEN

      -- reset componants
      sorter_rst    <= '1';
      flagger_rst   <= '1';
      counter_rst   <= '1';

      -- prep for restart
      process_complete  <= '1';
      counter_en        <= '0';
      state             := 0;

    ELSIF rising_edge(clk) THEN     

      IF state = 0  THEN 

        -- collect data
        internal_reg  <= data_in;
        internal_size <= data_size_in;
        BCID_addr     <= BCID_addr_in;

        IF (process_ready = '0') THEN -- new data was read in
          -- prep for state 1
          counter_rst   <= '1';
          counter_en    <= '0';
          -- move to next state
          state := 1;
        END IF;

      ELSIF state = 1 THEN -- sort data

        -- count time in state      
        counter_rst <= '0';
        counter_en  <= '1';

        -- feedback sorter
        sorter_parity <= NOT sorter_parity;
        internal_reg  <= sorter_data_out;

        IF (counter_value = internal_size) THEN --sort is complete
          -- move to next state
          state := 2;
        END IF;
     
      ELSIF state = 2 THEN
        flagger_data_in <= internal_reg;
        state := 3;

      ELSIF state = 3 THEN
        data_out  <= flagger_data_out;  
        process_complete  <= '1';
        BCID_addr_out     <= BCID_addr;
        data_size_out <= internal_size; -- propogate size across
        state := 4;

      ELSIF state = 4 THEN
        --check if data has been read-out
        IF process_complete = '0' THEN --data has been read
          -- prep for state 0
          process_ready <= '1';
          state := 0;
        END IF;

      END IF;

    END IF;
  
  END PROCESS;

END a;
