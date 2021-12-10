-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is
  port(i_S          : in std_logic;
       i_D0         : in std_logic;
       i_D1         : in std_logic;
       o_O          : out std_logic);

end mux2t1;

architecture structural of mux2t1 is
  
  component invg is

	  port(i_A          : in std_logic;
		   o_F          : out std_logic);

  end component;
  
  component org2 is

    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);

  end component;  

  component andg2 is

    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);

  end component;
  
  -- Intermediate signals
  
  signal a0_d0: std_logic;
  signal a1_d1: std_logic;
  signal inv_s: std_logic;

begin

	-- Layer 0

	inv0: invg
		port map( i_A => i_S,
				  o_F => inv_s );

	-- Layer 1

	and0: andg2
		port map( i_A => i_D0,
				  i_B => inv_s,
				  o_F => a0_d0);
	and1: andg2
		port map( i_A => i_D1,
				  i_B => i_S,
				  o_F => a1_d1);

	-- Layer 2
	
	or0: org2
		port map( i_A => a0_d0,
				  i_B => a1_d1,
				  o_F => o_O);
		
  
end structural;
