-- Bubble Sort Even Modual for sorting data
-- Even defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

-- IEEE VHDL standard library:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.sort_function.all;

ENTITY BubbleSort IS
	

  PORT(

<<<<<<< HEAD
    dataIn      		: in 	dataTrain;
    beginSortValid	: in 	std_logic; -- not convinsed this is needed

    dataOut   			: out dataTrain;
    switchMadeValid : out std_logic;
    switchMadeReset : in 	std_logic
    );
end BubbleSort;

-------------------------------------------------------------------------------
---------------------- Even Achitecture ----------------------------------------

architecture even of BubbleSort is
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
			for i in (0 to 98) loop
				-- check even
				if (i mod 2 = '0') then
					-- check if switch is required
					if (makeSwitch(dataIn(i),dataIn(i+1)) = '1') then
						-- make switch
						dataOut(i) 		<= dataIn(i+1);
						dataOut(i+1) 	<= dataIn(i);
						switchMadeValid <= '1';
=======
   	rst 			: in 	std_logic;	

   	dataIn      	: in 	dataTrain;
   	parity 			: in 	std_logic; -- high if odd
   	clk				: in 	std_logic;

  	dataOut   		: out 	dataTrain
  );

-------------------------------------------------------------------------------
---------------------- Odd Achitecture ----------------------------------------

architecture odd of BubbleSort is
=======
ARCHITECTURE a OF BubbleSort IS
>>>>>>> 04b58fd990210acc573b1e7dfa7f87328b6474ac
	-- reset patterns
	constant reset_patten_spp 	: std_logic_vector(29 downto 0) := (others => '0');
	constant reset_patten_train : dataTrain := (others => reset_patten_spp);

		
BEGIN

	PROCESS(parity,clk)
		VARIABLE mod_value : integer; 
	BEGIN
		IF rising_edge(clk) THEN
			IF parity = '1' THEN
				mod_value := 1;
			ELSIF parity = '0' THEN
				mod_value := 0;
			END IF;
		END IF;
		
		-- itterate over data train
		FOR i IN 0 to 98 LOOP
			-- check even
			IF (i mod 2 = mod_value) THEN
				-- check if switch is required
				IF (makeSwitch(dataIn(i),dataIn(i+1)) = '1') THEN
					-- make switch
					dataOut(i) 		<= dataIn(i+1);
					dataOut(i+1) 	<= dataIn(i);
				ELSE
					-- dont make switch
					dataOut(i) 		<= dataIn(i);
					dataOut(i+1) 	<= dataIn(i+1); 
				END IF;
			END IF;
		END LOOP;
	END PROCESS;
END a;