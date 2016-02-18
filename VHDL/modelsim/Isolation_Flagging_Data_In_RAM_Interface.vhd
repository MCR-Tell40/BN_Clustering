---------------------------------------------------
-- Isolation Flagging Data In RAM Interface      --
-- Author: Nicholas Mead                         --
-- Created: 16/02/2016                           --
---------------------------------------------------

-- IEEE Library
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- LHCb VELO Constants
USE work.Detector_Constant_Declaration.all;
USE work.Isolation_Flagging_Package.all;

-- Entity
ENTITY Isolation_Flagging_Data_In_RAM_Interface IS
	
	GENERIC(
		adr_width 			: 	INTEGER := 6;
		word_length 		: 	INTEGER := 32;
		read_buffer_size	:	INTEGER	:= 8 -- no. of words

	);

	PORT(
		clk, rst 	: IN std_logic;
		--read_in_buffer 	: IN ARRAY(0 to read_buffer_size-1) OF std_logic_vector(word_length-1 downto 0);

		read_adr 	: OUT std_logic_vector(adr_width-1 downto 0);
		read_en		: OUT std_logic

	);
END ENTITY;

-- Architecture
ARCHITECTURE arch OF Isolation_Flagging_Data_In_RAM_Interface IS

BEGIN

END arch;