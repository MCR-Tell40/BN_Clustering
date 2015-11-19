-- Bubble Sort Function for deciding if a switch is needed
-- Author Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define Package
PACKAGE sort_function IS 
	
	FUNCTION makeSwitch(sppA, sppB : std_logic_vector(29 downto 0)) RETURN std_logic;

END sort_function;

PACKAGE BODY sort_function IS

	FUNCTION makeSwitch(sppA, sppB : std_logic_vector(29 downto 0)) RETURN std_logic IS
	BEGIN
		FOR i IN ( 15 downto 8) loop

			IF 		(sppA(i) = '1' AND sppB(i) = '1') THEN RETURN '0';
			ELSIF	(sppA(i) = '1' AND sppB(i) = '0') THEN RETURN '0';
			ELSE	(sppA(i) = '0' AND sppB(i) = '1') THEN RETURN '1';
			END IF;
			
		END loop;
	END makeSwitch;

END sort_function;