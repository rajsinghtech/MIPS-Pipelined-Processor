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

entity RegisterFile is
  generic ( NUM_SELECT: integer := 5; WORD_SIZE : integer := 32);
  port(	i_D	: in std_logic_vector( WORD_SIZE - 1 downto 0);
	i_WE	: in std_logic;
	i_CLK	: in std_logic;
	i_RST	: in std_logic;
	i_WA	: in std_logic_vector( NUM_SELECT - 1 downto 0);
	i_RA0	: in std_logic_vector( NUM_SELECT - 1 downto 0);
	i_RA1	: in std_logic_vector( NUM_SELECT - 1 downto 0);
       	o_D0	: out std_logic_vector( WORD_SIZE - 1 downto 0);
	o_D1	: out std_logic_vector( WORD_SIZE - 1 downto 0));

end RegisterFile;

architecture dataflow of RegisterFile is

  component dffg_N
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
       	 i_D          : in std_logic_vector( WORD_SIZE - 1 downto 0);     -- Data value input
       	 o_Q          : out std_logic_vector( WORD_SIZE - 1 downto 0));   -- Data value output
  end component;

  component decoder_N
	  port(i_A        : in std_logic_vector( NUM_SELECT -1 downto 0);
	       o_E	  : in std_logic;
	       o_Q        : out std_logic_vector( 2**NUM_SELECT - 1 downto 0));
  end component;

  component NBitMux
  generic ( NUM_SELECT: integer);
	  port(	i_A	: in DATA_FIELD( ((2**NUM_SELECT) - 1) downto 0);
		i_S	: in std_logic_vector( NUM_SELECT - 1 downto 0);
	       	o_Q	: out std_logic_vector( WORD_SIZE - 1 downto 0));
  end component;

  signal w_Sel : std_logic_vector( 2**NUM_SELECT - 1 downto 0) := (others => '0');
  signal r_Sel : DATA_FIELD( 2**NUM_SELECT -1 downto 0);

begin


  WRITE_DEC: decoder_N 
  port map(i_A => i_WA, 
           o_E => i_WE,
           o_Q  => w_Sel);

  G_NBit_REG: for i in 0 to 2**NUM_SELECT - 1 generate
    REG: dffg_N port map( i_CLK => i_CLK,
	       		  i_RST => i_RST,
	       		  i_WE => w_Sel(i),
	       		  i_D => i_D,
	       		  o_Q => r_Sel(i));
  end generate G_NBit_REG;

  R0: NBitMux 
  generic map( NUM_SELECT => NUM_SELECT)
  port map(i_A => r_Sel, 
           i_S => i_RA0,
           o_Q  => o_D0);

  R1: NBitMux 
  generic map( NUM_SELECT => NUM_SELECT)
  port map(i_A => r_Sel, 
           i_S => i_RA1,
           o_Q  => o_D1);


end dataflow;
