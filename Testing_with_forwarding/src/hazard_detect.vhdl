library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_detect is
  generic( N: integer := 32 );
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

        flush          : out std_logic;
        stall          : out std_logic
  );   -- Data value output

end hazard_detect;

architecture structural of hazard_detect is

begin

    flush <= '1' when jump
            else '1' when jumpIns
            else '1' when branch
            else '0';

    stall <= '1' when mem_to_reg_EX && rs_addr = mem_to_reg_EX
            else  '1' when mem_to_reg_EX && rt_addr = mem_to_reg_EX
            else  '1' when mem_to_reg_MEM && rs_addr = wb_addr_MEM
            else  '1' when mem_to_reg_MEM && rt_addr = wb_addr_MEM
            else '0';

end structural;
