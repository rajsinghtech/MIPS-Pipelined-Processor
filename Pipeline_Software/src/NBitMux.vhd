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

use work.Data_Types.all;

entity NBitMux is
  generic ( NUM_SELECT: integer := 3; WORD_SIZE : integer := 32);
  port(	i_A	: in DATA_FIELD( ((2**NUM_SELECT) - 1) downto 0);
	      i_S	: in std_logic_vector( NUM_SELECT - 1 downto 0);
       	o_Q	: out std_logic_vector( WORD_SIZE - 1 downto 0));

end NBitMux;

architecture dataflow of NBitMux is

begin

  o_Q <= i_A(to_integer(unsigned(i_S)));

end dataflow;
