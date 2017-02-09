LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE Detector_Constant_Declaration IS

  -------------- Incoming FE data ----------------------------------------------------------------------------------------
  constant data_format_type    : std_logic_vector(2 downto 0) := "001";
  -- Select the data format expected :		
  -- 001 for variable header length with dynamic data structure
  -- 010 for fixed header length with dynamic data structure
  -- 100 for fixed header length with fixed data structure
  -- 101 for UT data structure (BXID + NoData + IsTrunc + NZS + Parity + Length + Data)
  
  constant simulation_fe_data_origin    : std_logic_vector (1 downto 0):= "01"; 
  -- Select the type of injection of data :
  -- 00 nothing
  -- 01 data from the generic data generator
  -- 10 data from the txt file
  -- 11 data from the sub-detector data generator

  -- FE specific configuration parameters
  -- 
  constant channel_size                 : INTEGER := 4; 
  constant number_of_channel            : INTEGER := 500;
  constant FE_word_size                 : INTEGER := (channel_size*number_of_channel);
  constant GBT_word_size                : INTEGER := 124;
  constant GBT_header_size              : INTEGER := 4;
  constant FE_bclk_bits                 : INTEGER := 12;
  constant FE_size_bits                 : INTEGER := 7;
  constant use_data_length_field 	      : INTEGER range 0 to 1 := 1;  -- 0 no data_length, 1 data_length
  constant FE_extra_bits                : INTEGER := 1;
  constant FE_header_size               : INTEGER := FE_bclk_bits+FE_extra_bits+(FE_size_bits*use_data_length_field);

  constant FE_interface_fifo_depth      : std_logic_vector(7 downto 0) := X"A0"; 
  
  constant occupancy_01                 : real := 3.0;
  constant occupancy_02                 : real := 2.5;
  constant occupancy_03                 : real := 2.0;
  constant occupancy_04                 : real := 1.5;
  constant occupancy_05                 : real := 1.0;
  constant occupancy_06                 : real := 0.5;
  
  constant NZS_data_length	      : INTEGER := channel_size*number_of_channel;

  constant FE_BXID_offset               : unsigned(11 downto 0) := X"000";
  constant SOL40_TO_FE_TFC_CMD_offset   : unsigned(11 downto 0) := X"D48";

  constant Synch_Pattern_Frame_size     : INTEGER := 10;
  constant SYNCH_PATTERN_frame          : std_logic_vector(9 downto 0) := "1011010011";

  constant active_fiber 		      : std_logic_vector(47 downto 0) := x"000000000007";
  
  -- TFC to FE specific configurations parameters
  --
  constant FE_reset_wait                : std_logic_vector(15 downto 0) := X"00FA"; -- 250 clock cycles
  -- number of clock cycles to wait after one FE RESET command
  
  constant NZS_enb              : std_logic                     := '1';
  -- enable/disable NZS trigger
  constant NZS_consecutive_enb  : std_logic                     := '0';
  -- number of consecutive NZS triggers
  constant NZS_TAE_wait_clkcycle: std_logic_vector(31 downto 0) := X"00000010";
  -- number of clock cycles to wait after one or more consecutive NZS triggers

  -- CALIBRATION TRIGGERS
  --
  constant CALIBTRG_A_period    : std_logic_vector(15 downto 0) := X"0001";
  -- periodicity as a number of orbits (1 = every orbit etc.)
  constant CALIBTRG_A_bxid      : std_logic_vector(15 downto 0) := X"0C0F";
  -- BXID on which calibration trigger will trigger
  constant CALIBTRG_A_enb       : std_logic                     := '1';
  -- enable/disable calibration trigger

  constant CALIBTRG_B_period    : std_logic_vector(15 downto 0) := X"0001";
  constant CALIBTRG_B_bxid      : std_logic_vector(15 downto 0) := X"04AF";
  constant CALIBTRG_B_enb       : std_logic                     := '0';
  constant CALIBTRG_C_period    : std_logic_vector(15 downto 0) := X"0001";
  constant CALIBTRG_C_bxid      : std_logic_vector(15 downto 0) := X"09DF";
  constant CALIBTRG_C_enb       : std_logic                     := '0';
  constant CALIBTRG_D_period    : std_logic_vector(15 downto 0) := X"0001";
  constant CALIBTRG_D_bxid      : std_logic_vector(15 downto 0) := X"020F";
  constant CALIBTRG_D_enb       : std_logic                     := '0';
  -- same as Calib A
  
  -- SPECIAL ENABLES
  constant SNAPSHOT_enb         : std_logic                     := '1';
  -- enable SNAPSHOT command
  constant SNAPSHOT_interval    : std_logic_vector(15 downto 0) := X"37B0";
  -- number of clock cycles between two SNAPSHOT commands
  constant SYNCH_enb            : std_logic                     := '1';
  -- enable SYNCH command
  constant SYNCH_length         : std_logic_vector(15 downto 0) := X"000A";
  -- number of consecutive SYNCH triggers (in clock cycles)
  constant SYNCH_wait           : std_logic_vector(15 downto 0) := X"0002";
  -- number of consecutive clock cycles to wait after one or more SYNCH commands
  constant BX_VETO_enb          : std_logic                     := '1';
  -- enable BX_VETO command (ignore if not used in FE)
  constant HEADER_ONLY_enb      : std_logic                     := '1';
  -- enable HEADER_ONLY command (ignore if not used in FE)

  -- Introduce voluntary BXID bugs 
  -- NOTE 1: if both skip and swap are enabled, skip has priority
  -- NOTE 2: if skip_interval and swap_interval have the same value, skip has priority
  constant skip_BXID                    : std_logic_vector(5 downto 0)    := "000000";
  constant skip_BXID_interval           : std_logic_vector(15 downto 0)   := X"0545";
  constant swap_BXID                    : std_logic_vector(5 downto 0)    := "000000";
  constant swap_BXID_interval           : std_logic_vector(15 downto 0)   := X"0641";
  constant skip_BXID_jump               : std_logic_vector(11 downto 0)   := X"00C";

  -- Event Isolation Flagging
  -- Note: If used to make a std_logic_vector, use (CONSTANT - 1 downto 0)
  CONSTANT MAX_FLAG_SIZE        : INTEGER := 128;
  CONSTANT IF_WORD_SIZE         : INTEGER := 24; 
  CONSTANT RAM_ADDR_SIZE        : INTEGER := 9;
  CONSTANT DATA_PROCESSOR_COUNT : INTEGER := 16;

  CONSTANT RD_WORD_SIZE         : INTEGER := 384;
  CONSTANT RD_SPP_SIZE          : INTEGER := 24;
  CONSTANT RD_SPP_PER_BCID      : INTEGER := 512;
  CONSTANT RD_RAM_ADDR_SIZE     : INTEGER := 128; -- Don't know what value this actually takes

  CONSTANT WR_WORD_SIZE         : INTEGER := 512;
  CONSTANT WR_SPP_SIZE          : INTEGER := 32;
  CONSTANT WR_SPP_PER_BCID      : INTEGER := 512;
  CONSTANT WR_RAM_ADDR_SIZE     : INTEGER := 128; -- Don't know what value goes here

  CONSTANT COUNT_RAM_WORD_SIZE  : INTEGER := 9;

  CONSTANT DATA_SIZE_MAX_BIT    : INTEGER := 8;
  CONSTANT BUFFER_LIFETIME      : INTEGER := 2048;
  
  CONSTANT MAX_ADDR : INTEGER := 128; -- UNSURE OF 


END Detector_Constant_Declaration;

