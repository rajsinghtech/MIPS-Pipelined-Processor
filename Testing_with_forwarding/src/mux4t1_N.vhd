-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux4t1_N is
  generic( N: integer );
  port(i_S          : in std_logic_vector( 1 downto 0);
       i_D0         : in std_logic_vector( N-1 downto 0 );
       i_D1         : in std_logic_vector( N-1 downto 0 );
       i_D2         : in std_logic_vector( N-1 downto 0 );
       i_D3         : in std_logic_vector( N-1 downto 0 );
       o_O          : out std_logic_vector( N-1 downto 0 ));

end mux4t1_N;

architecture structural of mux4t1_N is

begin

  with i_S select o_O <=
    i_D0 when "00",
    i_D1 when "01",
    i_D2 when "10",
    i_D3 when "11",
    '0' when others;

end structural;
