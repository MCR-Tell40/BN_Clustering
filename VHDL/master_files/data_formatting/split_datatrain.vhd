-- split_datatrain.vhd
-- Author: Ben Jeffrey 
-- Purpose: Splits up a datatrain type into 8 32-bit SPP signals

LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

USE work.Detector_Constant_Declaration.all;
USE work.Isolation_Flagging_Package.all;

ENTITY split_datatrain IS
	PORT(
		data_in : IN datatrain;			-- 128 x 1 32-bit-SPP
		reset 	: IN std_logic;
		data_out: OUT datatrain_wr		-- 8 x 16 32-bit-SPP 
	);


END split_datatrain;

architecture a of split_datatrain is
	-- internal register
	signal inter_reg : datatrain_wr;
begin
	process(reset)
	begin

		if reset = '1' then
			inter_reg <= reset_pattern_wrtrain;
		else 
			-- load the input datatrain into an internal register
			-- need to split up into individual SPPs
			for i in 0 to 7 loop 
				for j in 0 to 15 loop
					inter_reg(i)(((j+1)*32)-1 downto 32*j) <= data_in(16*i + j);
				END loop;
			end loop;
		end if;
		-- offload internal register to output
		data_out <= inter_reg;
	end process;
end architecture ; 


