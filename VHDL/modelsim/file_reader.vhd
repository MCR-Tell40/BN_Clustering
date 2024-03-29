-- Name: read_in.vh
-- Author: Nicholas Mead, Ben Jeffrey
-- Modified Date: 031215 
-- Entity name: reader
-- Description: Reads in 100 SPPs from a timesync file. No controlling for BCID

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all;
USE work.bubble_sort_package.all;
USE work.Detector_Constant_Declaration.all;

entity file_reader is
  
  port(
    clk  : in  std_logic;
    rst  : in  std_logic;
    --valid_out : out std_logic;
    out_train : out  datatrain
    );
end file_reader ;


architecture r of file_reader is

  function str_to_stdvec(inp: string) return std_logic_vector is
    variable temp: std_logic_vector(inp'range) := (others => 'X');
  begin
    for i in inp'range loop
      if (inp(i) = '1') then
        temp(i) := '1';
      elsif (inp(i) = '0') then
        temp(i) := '0';
      end if;
    end loop;
    return temp;
  end function str_to_stdvec;

  function stdvec_to_str(inp: std_logic_vector) return string is
    variable temp: string(inp'left+1 downto 1) := (others => 'X');
  begin
    for i in inp'reverse_range loop
      if (inp(i) = '1') then
        temp(i+1) := '1';
      elsif (inp(i) = '0') then
        temp(i+1) := '0';
      end if;
    end loop;
    return temp;
  end function stdvec_to_str;


begin
  process (clk)
    
    file file_pointer : text;
    variable line_content : string(1 to 32);
    variable line_num : line;
    variable j : integer := 0;
    variable char : character:='0'; 
    variable bin : std_logic_vector(31 downto 0);
    constant reset_spp : std_logic_vector(31 downto 0) := (others => '0');
    variable file_read : integer := 0; 
    
  begin

    if rst = '1' then
      out_train <= reset_patten_train;
    elsif rising_edge(clk) AND file_read = 0 then	
      --file_open(file_pointer,"./spp_sample.txt",READ_MODE);
      file_open(file_pointer,"./spp_sample_simple.txt",READ_MODE);
      file_read := 1;
      if (not endfile(file_pointer)) then  
        for i in 0 to OVERFLOW_SIZE loop
          readline (file_pointer,line_num);
          read (line_num,line_content);
        	report "line_content =" & line_content;
          bin := str_to_stdvec(line_content);
        	--report "bin" & stdvec_to_str(bin) & "    --->   " & stdvec_to_str(bin(29 downto 0));
          out_train(i) <= bin ;
          --valid_out <= '1';
        end loop;
      end if;      
    end if;
  end process ; 
END r ;



