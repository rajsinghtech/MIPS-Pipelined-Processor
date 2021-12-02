library IEEE;
use IEEE.std_logic_1164.all;

entity forwarding_unit is
  generic( N: integer := 32 );
  port(
        wb_mem_addr : in std_logic_vector(4 downto 0);
        wb_wb_addr  : in std_logic_vector(4 downto 0);
        wb_ex_addr : in std_logic_vector(4 downto 0);

        reg_write_mem : in std_logic;
        reg_write_ex : in std_logic;
        reg_write_wb : in std_logic;

        rs_addr     : in std_logic_vector(4 downto 0);
        rt_addr     : in std_logic_vector(4 downto 0);

        rs_select   : out std_logic_vector( 1 downto 0);
        rt_select   : out std_logic_vector( 1 downto 0)
  );   -- Data value output

end forwarding_unit;

architecture structural of forwarding_unit is

begin

  rs_select <= "10" when (rs_addr = wb_wb_addr) & reg_write_wb
            else "01" when (rs_addr = wb_mem_addr) & reg_write_mem
            else "11" when (rs_addr = wb_ex_addr) & reg_write_ex
            else "00";

   rt_select <= "10" when (rt_addr = wb_wb_addr) & reg_write_wb
            else "01" when (rt_addr = wb_mem_addr) & reg_write_mem
            else "11" when (rt_addr = wb_ex_addr) & reg_write_ex
            else "00";

end structural;
