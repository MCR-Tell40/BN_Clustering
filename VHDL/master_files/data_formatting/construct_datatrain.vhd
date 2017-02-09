-- construct_datatrain.vhd
-- Author: Ben Jeffrey 
-- Purpose: Combines input signals to form a datatrain type object. Pads input signals with 0;s

LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

USE work.Detector_Constant_Declaration.all;
USE work.Isolation_Flagging_Package.all;

ENTITY construct_datatrain IS
	PORT(
		data_in : IN datatrain_rd;		-- 8 x 16 24-bit-SPP
		reset 	: IN std_logic;
		data_out: OUT datatrain			-- 128 x 1 32-bit-SPP
		
	);

END construct_datatrain;

architecture a of construct_datatrain is
	-- internal register
	signal inter_reg : datatrain;
begin
	process(reset)
	begin
		if reset = '1' then 
			-- set internal register to zero
			inter_reg <= reset_pattern_train;	
		else 
			-- load the input datatrain into an internal register
			-- need to split up and pad with 0's to make 32 bit SPP
			for i in 0 to 7 loop 
				for j in 0 to 15 loop
					inter_reg(16*i + j) <= "00000000" & data_in(i)(24*(j+1)-1 downto 24*j);
				end loop;
			end loop;
		end if;
		-- offload internal register to output
		data_out <= inter_reg;
	end process;
end architecture ; 

