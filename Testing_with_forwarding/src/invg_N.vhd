library IEEE;
use IEEE.std_logic_1164.all;

entity invg_N is
  generic( N: integer := 32 );
  port(i_A          : in std_logic_vector( N - 1 downto 0);
       o_F          : out std_logic_vector( N - 1 downto 0));

end invg_N;

architecture structural of invg_N is

  component invg is
	port(i_A          : in std_logic;
         o_F          : out std_logic);
  end component;

begin

  G_NBit_INVG: for i in 0 to N-1 generate
    INVI: invg port map(
              i_A => i_A(i),
              o_F => o_F(i));
  end generate G_NBit_INVG;

end structural;
