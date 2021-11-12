library IEEE;
use IEEE.std_logic_1164.all;

entity Ripple_Adder is
  generic( N: integer := 32 );
  port(i_A : in std_logic_vector(N-1 downto 0);
       i_B : in std_logic_vector(N-1 downto 0);
	   o_S : out std_logic_vector(N-1 downto 0));

end Ripple_Adder;

architecture structure of Ripple_Adder is

	component fAdder is

	  port(i_C : in std_logic;
		   i_A : in std_logic;
		   i_B : in std_logic;
		   o_S : out std_logic;
		   o_C : out std_logic);

	end component;
	
	signal carry: std_logic_vector(N-1 downto 0);

begin

	ADDR: fAdder port map(i_C => '0',
						    i_A => i_A(0),
						    i_B => i_B(0),
						    o_S => o_S(0),
						    o_C => carry(0));	
	
	G_NBit_ADDER: for i in 1 to N-1 generate
      ADDR: FADDER port map(i_C => carry(i-1),
						    i_A => i_A(i),
						    i_B => i_B(i),
						    o_S => o_S(i),
						    o_C => carry(i));
	end generate G_NBit_ADDER;
  
end structure;
