library IEEE;
use IEEE.std_logic_1164.all;

entity Add_Sub is
  generic( N: integer := 32 );
  port(i_A : in std_logic_vector(N-1 downto 0);
       i_B : in std_logic_vector(N-1 downto 0);
	   nAdd_Sub : in std_logic;
	   o_S : out std_logic_vector(N-1 downto 0));

end Add_Sub;

architecture structure of Add_Sub is

	component Ripple_Adder is
	  generic( N: integer := N );
	  port(i_A : in std_logic_vector(N-1 downto 0);
		   i_B : in std_logic_vector(N-1 downto 0);
		   o_S : out std_logic_vector(N-1 downto 0));

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

	signal inv_A: std_logic_vector(N-1 downto 0);
	signal mux_A: std_logic_vector(N-1 downto 0);
	signal ripple_out: std_logic_vector(N-1 downto 0);
	signal inv_out: std_logic_vector(N-1 downto 0);


begin
	
-- Layer 0	
	
	inv0: invg_N
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_A => i_A,
				  o_F => inv_A);

-- Layer 1

	mux0: mux2t1_N
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_S => nAdd_Sub,
				  i_D0 => i_A,
				  i_D1 => inv_A,
				  o_O => mux_A);

-- Layer 2

	adder: Ripple_Adder
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_A => mux_A,
				  i_B => i_B,
				  o_S => ripple_out);
-- Layer 3

	inv1: invg_N
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_A => ripple_out,
				  o_F => inv_out);

-- Layer 4

	mux1: mux2t1_N
		generic map ( N => N ) -- Default is 32, but doing this for sanity
		port map( i_S  => nAdd_Sub,
				  i_D0 => ripple_out,
				  i_D1 => inv_out,
				  o_O  => o_S);
  
end structure;
