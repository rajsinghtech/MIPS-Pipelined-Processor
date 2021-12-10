library IEEE;
use IEEE.std_logic_1164.all;

entity nor_N is
  generic( N: integer := 32 );
  port(i_A : in std_logic_vector(N-1 downto 0);
	   o_S : out std_logic);

end nor_N;

architecture structure of nor_N is

	component invg is
		port(i_A          : in std_logic;
			 o_F          : out std_logic);
	end component;

    component org2 is
		port(i_A          : in std_logic;
             i_B          : in std_logic;
			 o_F          : out std_logic);
	end component;
	
	signal carry: std_logic_vector(N-1 downto 0);

begin

	org1: org2 port map(i_A => '0',
					   i_B => i_A(0),
					   o_F => carry(0));

	G_NBit_NOR: for i in 1 to N-1 generate
		org2C: org2 port map(i_A => carry(i-1),
						    i_B => i_A(i),
						    o_F => carry(i));
	end generate G_NBit_NOR;

	inv1: invg port map(i_A => carry(N-1),
					   o_F => o_S);
  
end structure;
