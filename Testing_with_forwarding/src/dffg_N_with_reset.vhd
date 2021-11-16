library IEEE;
use IEEE.std_logic_1164.all;

entity dffg_N_with_reset is
  generic( N: integer := 32 );
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       reset_value  : in std_logic_vector( N - 1 downto 0);
       i_D          : in std_logic_vector( N - 1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector( N - 1 downto 0));   -- Data value output

end dffg_N_with_reset;

architecture structural of dffg_N_with_reset is

  component dffg is
	  port(i_CLK        : in std_logic;     -- Clock input
	       i_RST        : in std_logic;     -- Reset input
	       i_WE         : in std_logic;     -- Write enable input
	       i_D          : in std_logic;     -- Data value input
	       o_Q          : out std_logic);   -- Data value output
  end component;

    signal reg_input : std_logic_vector(N - 1 downto 0);

begin

  reg_input <= i_D when i_RST = '0'
            else reset_value;



  G_NBit_REG: for i in 0 to N-1 generate
    REG: dffg port map( i_CLK => i_CLK,
	       		i_RST => '0',
	       		i_WE => i_WE,
	       		i_D => reg_input(i),
	       		o_Q => o_Q(i));
  end generate G_NBit_REG;

end structural;
