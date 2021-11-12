library IEEE;
use IEEE.std_logic_1164.all;

entity Add_Sub is
  generic( N: integer := 32 );
  port(i_A : in std_logic_vector(N-1 downto 0);
       i_B : in std_logic_vector(N-1 downto 0);
	   nAdd_Sub : in std_logic;
	   ovfl : out std_logic;
	   o_S : out std_logic_vector(N-1 downto 0));

end Add_Sub;

architecture structure of Add_Sub is

	component Ripple_Adder is
	  generic( N: integer := N );
	  port(i_A : in std_logic_vector(N-1 downto 0);
		   i_B : in std_logic_vector(N-1 downto 0);
		   o_S : out std_logic_vector(N-1 downto 0);
		   ovfl : out std_logic);

	end component;
	
	component invg_N is
	  generic( N: integer := N );
	  port(i_A          : in std_logic_vector( N - 1 downto 0);
		   o_F          : out std_logic_vector( N - 1 downto 0));

	end component;
	

	component mux2t1_N is
	  generic( N: integer := N );
	  port(i_S          : in std_logic;
		   i_D0         : in std_logic_vector(N-1 downto 0);
		   i_D1         : in std_logic_vector(N-1 downto 0);
		   o_O          : out std_logic_vector(N-1 downto 0));

	end component;	

      component andg2 is
        port (i_A          : in std_logic;
              i_B          : in std_logic;
              o_F          : out std_logic);
  
      end component;

	signal inv_B: std_logic_vector(N-1 downto 0);
	signal mux_B: std_logic_vector(N-1 downto 0);
	signal two_comp_B: std_logic_vector(N-1 downto 0);
	signal ripple_out: std_logic_vector(N-1 downto 0);
	signal inv_out: std_logic_vector(N-1 downto 0);
	signal add_ovfl: std_logic;
	signal invert_out: std_logic;


begin
	
-- Layer 0	
	
	inv0: invg_N
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_A => i_B,
				  o_F => inv_B);

	two_comp : Ripple_Adder
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_A => x"00000001",
				  i_B => inv_B,
				  o_S => two_comp_B,
				  ovfl => open);

-- Layer 1

	mux0: mux2t1_N
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_S => nAdd_Sub,
				  i_D0 => i_B,
				  i_D1 => two_comp_B,
				  o_O => mux_B);

-- Layer 2

	adder: Ripple_Adder
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_A => i_A,
				  i_B => mux_B,
				  o_S => o_S,
				  ovfl => add_ovfl);
  
end structure;
