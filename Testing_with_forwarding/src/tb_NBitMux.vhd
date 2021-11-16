-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered flip-flop with parallel access and reset.
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

entity tb_NBitMux is
  generic(NUM_SELECT: integer := 5; WORD_SIZE : integer := 32; gCLK_HPER   : time := 10 ns);
end tb_NBitMux;

architecture behavior of tb_NBitMux is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component NBitMux
	  port(	i_A	: in DATA_FIELD( ((2**NUM_SELECT) - 1) downto 0);
		i_S	: in std_logic_vector( NUM_SELECT - 1 downto 0);
	       	o_Q	: out std_logic_vector( WORD_SIZE - 1 downto 0));
  end component;

  -- Temporary signals to connect to the dff component.
  signal i_A  : DATA_FIELD( ((2**NUM_SELECT) - 1) downto 0) := ( 0 => x"00000001",
								   1 => x"00000002",
								   2 => x"00000003",
								   3 => x"00000004",
								   4 => x"00000005",
								   5 => x"00000006",
								   6 => x"00000007",
								   7 => x"00000008",
								   8 => x"00000009",
								   9 => x"00000010",
								   10 => x"00000011",
								   11 => x"00000012",
								   12 => x"00000013",
								   13 => x"00000014",
								   14 => x"00000015",
								   15 => x"00000016",
								   16 => x"00000017",
								   others => x"FFFFFFFF");

  signal i_S  : std_logic_vector( NUM_SELECT - 1 downto 0) := (others => '0');
  signal o_Q  : std_logic_vector( WORD_SIZE - 1 downto 0);

begin

  DUT: NBitMux 
  port map(i_A => i_A, 
           i_S => i_S,
           o_Q  => o_Q);
  P_CLK: process
  begin
    wait for gCLK_HPER;
    i_S <= std_logic_vector(unsigned(i_S) + 1);
  end process;
  
end behavior;
