-- Bubble Sort Even Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sort_function.all;

ENTITY BubbleSort IS
	

  PORT(

   	rst 			: in 	std_logic;	

   	dataIn      	: in 	dataTrain;
   	parity 			: in 	std_logic; -- high if odd

  	dataOut   		: out 	dataTrain
  );

 end BubbleSort;

-----------------------------------------------------------------------
--------------------------- Even Architecture -------------------------

architecture a of BubbleSort is
	-- reset patterns
	constant reset_patten_spp 	: std_logic_vector(29 downto 0) := (others => '0');
	constant reset_patten_train : dataTrain := (others => reset_patten_spp);

		
begin

	process(parity)
		VARIABLE mod_value : integer; 
	begin
		if parity'event then
			if parity = '1' then
				mod_value := 1;
			elsif parity = '0' then
				mod_value := 0;
			end if;
			-- itterate over data train
			for i in 0 to 98 loop
				-- check even
				if (i mod 2 = mod_value) then
					-- check if switch is required
					if (makeSwitch(dataIn(i),dataIn(i+1)) = '1') then
						-- make switch
						dataOut(i) 		<= dataIn(i+1);
						dataOut(i+1) 	<= dataIn(i);
					else
						-- dont make switch
						dataOut(i) 		<= dataIn(i);
						dataOut(i+1) 	<= dataIn(i+1); 
					end if;
				end if;
			end loop;
		end if;
	end process;
end a;