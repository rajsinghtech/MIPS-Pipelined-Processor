library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use IEEE.numeric_std.all;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_and_C is
	generic (gClk_per: time:= 10ns; N : integer := 32);
end tb_and_C;

architecture mixed of tb_and_C is

    component and_C is
		port (i_A: in std_logic_vector( N -1 downto 0 ); 
        i_B: in std_logic_vector( N -1 downto 0 );
        o_F: out std_logic_vector( N - 1 downto 0 ));
	end component;

    signal i_A: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"0000ffff");
	signal i_B: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"ffff0000");
    signal o_F: std_logic_vector( N -1 downto 0 );

begin
    and0: and_C
    port map (i_A => i_A, i_B => i_B,  o_F => o_F);

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