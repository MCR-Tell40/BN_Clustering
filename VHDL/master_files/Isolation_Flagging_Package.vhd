-- Bubble Sort Function for deciding if a switch is needed
-- Author Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Detector_Constant_Declaration.all; 

-- Define Package
PACKAGE Isolation_Flagging_Package IS 

	-- type def for array of std logic vectors
	TYPE dataTrain 		IS ARRAY(MAX_FLAG_SIZE - 1 downto 0) OF std_logic_vector(31 downto 0);
	TYPE dataTrain_rd 	IS ARRAY(7 downto 0) OF std_logic_vector(RD_WORD_SIZE - 1 downto 0);
	TYPE dataTrain_wr 	IS ARRAY(7 downto 0) OF std_logic_vector(WR_WORD_SIZE - 1  downto 0);
	

	CONSTANT reset_pattern_spp    : std_logic_vector(31 downto 0) := (others => '0');
	CONSTANT reset_pattern_train  : dataTrain := (others => reset_pattern_spp);
	
	CONSTANT reset_pattern_wr	  : std_logic_vector(WR_WORD_SIZE - 1 downto 0) := (others => '0');
	CONSTANT reset_pattern_wrtrain: dataTrain_wr := (others => reset_pattern_wr);

END Isolation_Flagging_Package;