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

entity decoder_N is
  generic ( N: integer := 5 );
  port(i_A        : in std_logic_vector( N -1 downto 0);
       o_E        : in std_logic;
       o_Q        : out std_logic_vector( 2**N - 1 downto 0));

end decoder_N;

architecture dataflow of decoder_N is

begin

  G_NBit_Decoder: for i in 0 to 2**N-1 generate

	o_Q(i) <= '0' when o_E = '0' 
			else '1' when i = to_integer(unsigned(i_A)) 
			else '0';
    
  end generate G_NBit_Decoder;


  
  
end dataflow;
