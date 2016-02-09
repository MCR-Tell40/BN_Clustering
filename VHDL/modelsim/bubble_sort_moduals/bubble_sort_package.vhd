-- Bubble Sort Function for deciding if a switch is needed
-- Author Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Detector_Constant_Declaration.all; 

-- Define Package
PACKAGE bubble_sort_package IS 

	-- type def for array of std logic vectors
	TYPE dataTrain IS ARRAY(OVERFLOW_SIZE downto 0) OF std_logic_vector(31 downto 0);

END bubble_sort_package;

PACKAGE BODY bubble_sort_package IS

END bubble_sort_package;