-- Bubble Sort Odd Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sort_function.all;

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
	-- reset patterns
	constant reset_patten_spp 	: std_logic_vector(29 down to 0) := (others => '0');
	constant reset_patten_train : dataTrain := (others => reset_patten_spp);
begin
	--
	process(clk, rst)
	begin
		if rst = '1' then
			-- Clear output
			dataOut <= reset_patten_train;
		
		elsif rising_edge(clk) then 
			-- itterate over data train
			for i in (1 to 97) loop
				-- check even
				if (i mod 2 = '1') then
					-- check if switch is required
					if (makeSwitch(dataIn(i),dataIn(i+1)) = '1') then
						-- make switch
						dataOut(i) 		<= dataIn(i+1);
						dataOut(i+1) 	<= dataIn(i);
						switchMadeValid <= '1';

					else
						-- dont make switch
						dataOut(i) 		<= dataIn(i);
						dataOut(i+1) 	<= dataIn(i+1); 
					end if;
				end if;
			end loop;
		end if;
	end process;

	-- reset the switchMadeValid signal
	-- called once top level has read the switchMadeValid signal or on rst 
	process (switchMadeReset, rst)
	begin
		if rising_edge(switchMadeReset) OR rst = '1' then
			switchMadeValid <= '0'
		end if;
	end process;
end a;
