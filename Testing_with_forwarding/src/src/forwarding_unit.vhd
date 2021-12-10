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

        signal rs_wb_sig : std_logic_vector( 1 downto 0);
        signal rt_wb_sig : std_logic_vector( 1 downto 0);

        signal rs_mem_sig : std_logic_vector( 1 downto 0);
        signal rt_mem_sig : std_logic_vector( 1 downto 0);
        
        signal rs_ex_sig : std_logic_vector( 1 downto 0);
        signal rt_ex_sig : std_logic_vector( 1 downto 0);

begin

        rs_wb_sig <= "10" when  reg_write_wb = '1'
                else "00";
        
        rt_wb_sig <= "10" when  reg_write_wb = '1'
                else "00";

        rs_mem_sig <= "01" when reg_write_mem = '1'
                else "00";

        rt_mem_sig <= "01" when reg_write_mem = '1'
                else "00";
        
        rs_ex_sig <= "11" when reg_write_ex = '1'
                else "00";

        rt_ex_sig <= "11" when reg_write_ex = '1'
                else "00";
        
                


        rs_select <= rs_ex_sig when rs_addr = wb_ex_addr 
            else rs_mem_sig when rs_addr = wb_mem_addr
            else rs_wb_sig when rs_addr = wb_wb_addr
            else "00";

        rt_select <= rt_ex_sig when rt_addr = wb_ex_addr 
            else rt_mem_sig when rt_addr = wb_mem_addr
            else rt_wb_sig when rt_addr = wb_wb_addr
            else "00";

end structural;
