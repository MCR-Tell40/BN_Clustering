-- Bubble Sort Even Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- type def for array of std logic vectors
TYPE dataTrain IS array (99 downto 0) OF std_logic_vector(29 downto 0);

ENTITY BubbleSortEven IS
  PORT(
  	clk				: in 	std_logic;
  	rst 			: in 	std_logic;	

    dataIn      	: in 	dataTrain;
    beginSortValid	: in 	std_logic; -- not convinsed this is needed

    dataOut   		: out 	dataTrain;
    switchMadeValid : out 	std_logic;
    switchMadeReset : in 	std_logic
    );
end BubbleSortEven;

architecture a of BubbleSortEven is
  
begin
	process(clk, rst)
	begin
		if rst = '1' then
			-- somthing here to set output to nothing
		elsif rising_edge(clk) then 
			-- itterate over data train
			for i in (0 to 98) loop
				-- check even
				if (i mod 2 = '0') then
				-- check if switch is required



				end if;
			end loop;
		end if;
	end process;
end a;
