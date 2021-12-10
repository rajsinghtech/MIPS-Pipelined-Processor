library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use IEEE.numeric_std.all;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_ALU is
	generic (gClk_per: time:= 10ns; N : integer := 32);
end tb_ALU;

architecture mixed of tb_ALU is

    component ALU is
        port(i_A : in std_logic_vector(N-1 downto 0);
        i_B : in std_logic_vector(N-1 downto 0);
        i_Shamt : in std_logic_vector(4 downto 0);
        i_ALUOP : in std_logic_vector(5 downto 0);
        o_Zero : out std_logic;
        o_S : out std_logic_vector(N-1 downto 0));
	end component;

    signal i_B: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"000000ff");
	signal i_A: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"0000f000");
	signal i_Shamt: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"0000f000");
	signal i_ALUOP: std_logic_vector( N - 1 downto 0 ) :=  to_stdlogicvector(x"0000f000");
    signal o_Zero: std_logic;
    signal o_S: std_logic_vector( N -1 downto 0 );

begin
    addersubtractor0: ALU
    port map (i_A => i_A, i_B => i_B, nAdd_Sub => nAdd_Sub, o_S => o_S);

    tcase0: process
        begin
            i_B <= std_logic_vector(shift_left(unsigned(i_B), 4)) ;
            wait for gClk_per;
    end process;

    tcase1: process
        begin
            i_A <= std_logic_vector(shift_right(unsigned(i_A), 4));
            wait for gClk_per;
    end process;

    tcase3: process
        begin
            nAdd_Sub <= '0';
            wait for gClk_per / 2;
            nAdd_Sub <= '1';
            wait for gClk_per / 2;
    end process;
    
end mixed;	