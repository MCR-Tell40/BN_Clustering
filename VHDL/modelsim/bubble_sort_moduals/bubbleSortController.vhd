-- Bubble Sort Top
-- Even/Odd defined by parity of LSB
-- Author Ben Jeffrey, Nicholas Mead
-- Date Created 19/11/2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- type def for array of std logic vectors
TYPE dataTrain IS array (99 downto 0) OF std_logic_vector(29 downto 0);

entity bubbleSortController is
  port(
    
    global_rst			    : IN    std_logic;
 	  global_clk_160MHz	  : IN    std_logic;
    router_data_in		  : IN 	  dataTrain;

    sorted_data_out     : OUT 	dataTrain
  );
end bubbleSortController;

architecture a of bubbleSortController is
    
	-- ##### Components ##### --

  COMPONENT BubbleSort IS
 		PORT(
  		clk				: in 	std_logic;
  		rst 			: in 	std_logic;	

  		dataIn          : in 	dataTrain;
   		beginSortValid	: in 	std_logic; -- not convinsed this is needed

   		dataOut   		  : out dataTrain;
   		switchMadeValid : out std_logic
  	);
	END COMPONENT;

	-- ##### Data Busses ##### --

	SIGNAL Router_Control          	  : dataTrain;
	SIGNAL BubbleSortEven_Control     : dataTrain;
	SIGNAL BubbleSortOdd_Control	    : dataTrain;
  SIGNAL RST_Control                : std_logic; 

  SIGNAL Control_DataOut            : dataTrain;
  SIGNAL Control_BubbleSortEven     : dataTrain;
  SIGNAL Control_BubbleSortOdd      : dataTrain;
  SIGNAL Control_RST                : std_logic;

  SIGNAL Clock_Componants           : std_logic;

	-- ##### Validation Signals ##### --

	SIGNAL BubbleSortEven_SwitchMade 	: std_logic;
	SIGNAL BubbleSortOdd_SwitchMade 	: std_logic;

	-- ##### Clock and Reset ##### --

  SIGNAL Control_RST                : std_logic;
  SIGNAL RST_Control                : std_logic;

  SIGNAL Clock_Componants           : std_logic;

  -- ##### Data Tracking ##### --

  Variable sorting_even             : std_logic;
  Variable sorting_odd              : std_logic;	

  -- ##### Reset Constants ##### --

  constant reset_patten_spp   : std_logic_vector(29 down to 0) := (others => '0');
  constant reset_patten_train : dataTrain := (others => reset_patten_spp);

BEGIN
  
  BubbleSortOdd : BubbleSort(odd)
    PORT MAP (
      clk             => Clock_Componants;
      rst             => Control_RST;

      dataIn          => Control_BubbleSortOdd;

      dataOut         => BubbleSortOdd_Control;
      switchMadeValid => BubbleSortOdd_SwitchMade;
    );

  BubbleSortOdd : BubbleSort(odd)
    PORT MAP (
      clk             => Clock_Componants;
      rst             => Control_RST;

      dataIn          => Control_BubbleSortEven;

      dataOut         => BubbleSortEven_Control;
      switchMadeValid => BubbleSortEven_SwitchMade;
    );

  PROCESS(global_clk_160MHz, global_rst)
  BEGIN

    Clock_Componants  <= global_clk_160MHz;
    RST_Control       <= global_rst;	

    Router_Control    <= router_data_in;

    If (RST_Control = '1') THEN 
      
      Control_RST     <= RST_Control;
      Control_DataOut <= reset_patten_train;

      sorting_odd     <= '0';
      sorting_even    <= '0';

    ELSIF rising_edge(csi_Clock_160MHz) THEN     
      
      IF sorting_even = '0' AND sorting_odd '0' THEN --start sorting
        Control_BubbleSortEven <= Router_Control;
        sorting_even <= '1';
      
      ELSIF -------------------- UP TO HERE ------------------------

      END IF;

    END IF;
    
  END PROCESS;

END a;