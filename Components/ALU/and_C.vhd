library IEEE;
use IEEE.std_logic_1164.all;

entity and_C is
	generic ( N : integer := 32 );
	port ( i_A: in std_logic_vector( N -1 downto 0 );
		   i_B: in std_logic_vector( N -1 downto 0 );
		   o_F: out std_logic_vector( N - 1 downto 0 ) );
end and_C;		   

architecture structure of and_C is

	component andg2 is
		port(i_A          : in std_logic;
			 i_B          : in std_logic;
			 o_F          : out std_logic);
	end component;
	
	begin
	
	G_AND: for i in 0 to N-1 generate
	
		ANDG0: andg2 port MAP (i_A => i_A(i), i_B => i_B(i), o_F => o_F(i));
	
	end generate G_AND;

end structure;