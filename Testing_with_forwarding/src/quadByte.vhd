library IEEE;
use IEEE.std_logic_1164.all;

entity quadByte is
	generic ( N : integer := 32 );
	port ( i_A: in std_logic_vector( 7 downto 0 );
		   o_F: out std_logic_vector( N - 1 downto 0 ));
end quadByte;

architecture dataflow of quadByte is
begin

  o_F(7 downto 0) <= i_A;
  o_F(15 downto 8) <= i_A;
  o_F(23 downto 16) <= i_A;
  o_F(31 downto 24) <= i_A;


end dataflow;
