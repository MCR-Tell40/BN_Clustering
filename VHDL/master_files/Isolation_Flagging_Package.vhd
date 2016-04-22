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
	TYPE dataTrain 		IS ARRAY(OVERFLOW_SIZE downto 0) OF std_logic_vector(31 downto 0);
	TYPE dataTrain_rd 	IS ARRAY(7 downto 0) OF std_logic_vector(sppram_rd_datasize-1 downto 0);
	TYPE dataTrain_wr 	IS ARRAY(7 downto 0) OF std_logic_vector((32*16)-1 downto 0);
	

	CONSTANT reset_patten_spp    : std_logic_vector(23 downto 0) := (others => '0');
	CONSTANT reset_patten_train  : dataTrain := (others => reset_patten_spp);
	
END Isolation_Flagging_Package;
