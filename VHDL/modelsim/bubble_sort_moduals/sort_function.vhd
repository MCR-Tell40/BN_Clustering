-- Bubble Sort Function for deciding if a switch is needed
-- Author Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define Package
PACKAGE sort_function IS 

  	-- type def for array of std logic vectors
		TYPE dataTrain IS ARRAY(99 downto 0) OF std_logic_vector(29 downto 0);

	-- For sorted data B > A, Returns '1' if switch is required
	FUNCTION makeSwitch(sppA, sppB : std_logic_vector(29 downto 0)) RETURN std_logic;

END sort_function;


PACKAGE BODY sort_function IS
	
	-- For sorted data B > A, Returns '1' if switch is required
	FUNCTION makeSwitch(sppA, sppB : std_logic_vector(29 downto 0)) RETURN std_logic IS
		VARIABLE equal: 	std_logic_vector(15 downto 8) := (others => '0');
		CONSTANT full: 	std_logic_vector(15 downto 8) := (others => '1');
	BEGIN
		FOR i IN  15 downto 8 LOOP

			IF		(sppA(i) = '1' AND sppB(i) = '0') THEN RETURN '1';
			ELSIF	(sppA(i) = '0' AND sppB(i) = '1') THEN RETURN '0';
			ELSE	equal(i) := '1';
			END IF;

		END LOOP;

		IF (equal = full) THEN RETURN '0';
		END IF;

	END makeSwitch;		

END sort_function;