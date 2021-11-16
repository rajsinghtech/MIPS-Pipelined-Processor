library IEEE;
use IEEE.std_logic_1164.all;

entity fAdder is

  port(i_C : in std_logic;
       i_A : in std_logic;
       i_B : in std_logic;
	   o_S : out std_logic;
       o_C : out std_logic);

end fAdder;

architecture structure of fAdder is

	component xorg2 is
	  port(i_A          : in std_logic;
		   i_B          : in std_logic;
		   o_F          : out std_logic);	
	end component;
	
	component andg2 is
	  port(i_A          : in std_logic;
		   i_B          : in std_logic;
		   o_F          : out std_logic);	
	end component;	

	component org2 is
	  port(i_A          : in std_logic;
		   i_B          : in std_logic;
		   o_F          : out std_logic);	
	end component;

	signal sum_ab: std_logic;
	signal carry_ab: std_logic;
	signal carry_abc: std_logic;


begin
	
-- Layer 0	
	
	xor0: xorg2
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => sum_ab);

	and0: andg2
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => carry_ab);

-- Layer 1

	xor1: xorg2
		port map( i_A => sum_ab,
				  i_B => i_C,
				  o_F => o_S);

	and1: andg2
		port map( i_A => sum_ab,
				  i_B => i_C,
				  o_F => carry_abc);

-- Layer 2

	or0: org2
		port map( i_A => carry_ab,
				  i_B => carry_abc,
				  o_F => o_C);
  
end structure;
