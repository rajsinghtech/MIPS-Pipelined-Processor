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

        signal rs_sel : std_logic_vector( 1 downto 0 );
        signal rt_sel : std_logic_vector( 1 downto 0 );

begin

        rs_sel <= "10" when rs_addr = wb_wb_addr
            else "01" when rs_addr = wb_mem_addr
            else "11" when rs_addr = wb_ex_addr
            else "00";

        rt_sel <= "10" when rt_addr = wb_wb_addr
            else "01" when rt_addr = wb_mem_addr
            else "11" when rt_addr = wb_ex_addr
            else "00";

        rs_select <= rs_sel when reg_write_mem
                     rs_sel when reg_write_ex
                     rs_sel when reg_write_wb
                     else "00";

        rt_select <= rt_sel when reg_write_mem
                     rt_sel when reg_write_ex
                     rt_sel when reg_write_wb
                     else "00";                     
end structural;
