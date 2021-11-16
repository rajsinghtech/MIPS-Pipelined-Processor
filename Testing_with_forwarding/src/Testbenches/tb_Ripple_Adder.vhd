library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use IEEE.numeric_std.all;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_Ripple_Adder is
	generic (gClk_per: time:= 10ns; N : integer := 32);
end tb_Ripple_Adder;

architecture mixed of tb_Ripple_Adder is

	component Ripple_Adder is
		port (i_A: in std_logic_vector; i_B: in std_logic_vector; o_S: out std_logic_vector);
	end component;

	signal i_A: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"0000ffff");
	signal i_B: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"ffff0000");
	signal o_S: std_logic_vector( N -1 downto 0 );

begin

	ripplecarry0: Ripple_Adder
		port map (i_A => i_A, i_B => i_B, o_S => o_S);

	tcase0: process
		begin
			i_A <= std_logic_vector(shift_left(unsigned(i_A), 4)) ;
			wait for gClk_per;
	end process;

	tcase1: process
		begin
			i_B <= std_logic_vector(shift_right(unsigned(i_B), 4));
			wait for gClk_per;
	end process;

end mixed;	