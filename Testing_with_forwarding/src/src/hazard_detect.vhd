library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_detect is
  port(
        rt_addr : in std_logic_vector(4 downto 0);
        rs_addr  : in std_logic_vector(4 downto 0);

        wb_addr_MEM : in std_logic_vector(4 downto 0);
        wb_addr_EX  : in std_logic_vector(4 downto 0);

        mem_to_reg_MEM : in std_logic;
        mem_to_reg_EX  : in std_logic;

        jump            : in std_logic;
        jumpIns         : in std_logic;
        branch          : in std_logic;
        
        i_clk           : in std_logic;

        flush          : out std_logic;
        stall          : out std_logic
  );   -- Data value output
  
  signal flush_s : std_logic;
  signal flush_o : std_logic;

end hazard_detect;

architecture structural of hazard_detect is

        signal raw_dep_EX   : std_logic;
        signal raw_dep_MEM  : std_logic;

begin

     flush_s <= '1' when jump = '1'
            else '1' when jumpIns = '1'
            else '1' when branch = '1'
            else '0';
     
     flush_o <= flush_s when i_clk = '1'
            else flush_o;
            
     flush <= flush_o;

    raw_dep_EX <= '1' when rs_addr = wb_addr_EX
        else  '1' when rt_addr = wb_addr_EX
        else '0';

    raw_dep_MEM <= '1' when rs_addr = wb_addr_MEM
        else  '1' when rt_addr = wb_addr_MEM
        else '0';

    stall <= (raw_dep_EX and mem_to_reg_EX) or (raw_dep_MEM and mem_to_reg_MEM);
    
    

end structural;
