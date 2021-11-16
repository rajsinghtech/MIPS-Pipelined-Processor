-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an edge-triggered
-- flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity extender is
  generic ( SOURCE_LEN: integer := 16; TARGET_LEN: integer := 32 );
  port(i_A        : in std_logic_vector( SOURCE_LEN -1 downto 0);
       type_select        : in std_logic;
       o_Q        : out std_logic_vector(TARGET_LEN - 1 downto 0));

end extender;

architecture dataflow of extender is

begin


  o_Q <= std_logic_vector(to_unsigned(to_integer(unsigned(i_A)),TARGET_LEN)) when type_select = '0' else 
	 std_logic_vector(to_signed(to_integer(signed(i_A)),TARGET_LEN)) when type_select = '1';


  
  
end dataflow;
