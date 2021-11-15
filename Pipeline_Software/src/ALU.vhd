library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.Data_Types.all;

entity ALU is
  generic( N: integer := 32; NUM_SELECT: integer := 4);
  port(i_A : in std_logic_vector(N-1 downto 0);
       i_B : in std_logic_vector(N-1 downto 0);
	   i_Shamt : in std_logic_vector(4 downto 0);
	   i_qByte : in std_logic_vector(7 downto 0);
	   i_ALUOP : in std_logic_vector(5 downto 0);
	   o_Zero : out std_logic;
	   ovfl : out std_logic;
	   o_S : out std_logic_vector(N-1 downto 0));

end ALU;

architecture structure of ALU is

	component Add_Sub is
	  generic( N: integer := N );
	  port(i_A : in std_logic_vector(N-1 downto 0);
		   i_B : in std_logic_vector(N-1 downto 0);
		   nAdd_Sub : in std_logic;
		   ovfl : out std_logic;
		   o_S : out std_logic_vector(N-1 downto 0));

	end component;
	
	component invg_N is
	  generic( N: integer := N );
	  port(i_A          : in std_logic_vector( N - 1 downto 0);
		   o_F          : out std_logic_vector( N - 1 downto 0));

	end component;

	component and_C is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;

	  component or_C is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;

	  component nor_C is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;

	  component xor_C is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;
	  component nor_N is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 o_S          : out std_logic);
  
	  end component;

	  component quadByte is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;
	

	component NBitMux is
	  generic( NUM_SELECT: integer := NUM_SELECT );
	  port(i_A          : in DATA_FIELD( ((2**NUM_SELECT) - 1) downto 0);
		   i_S         : in std_logic_vector(NUM_SELECT-1 downto 0);
		   o_Q          : out std_logic_vector(N-1 downto 0));

	end component;	

	component barrel_shifter is
		port(i_src          : in std_logic_vector(N-1 downto 0);
			 i_shift_type   : in std_logic_vector(1 downto 0);
			 i_shamt		: in std_logic_vector(4 downto 0);
			 o_shift_out    : out std_logic_vector(N-1 downto 0));

	end component;	

	signal datafield: DATA_FIELD(15 downto 0);
	signal luisignal: std_logic_vector(N-1 downto 0) := (others =>'0');


begin	
	nor1: nor_N
		generic map ( N => N ) 
		port map( i_A => datafield(0),
				  o_S => o_Zero);

	adder0: Add_Sub
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  nAdd_Sub => i_ALUOP(5),
				  o_S => datafield(0),
				  ovfl => ovfl);

	and0: and_C
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => datafield(1));

	or0: or_C
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => datafield(2));

	nor0: nor_C
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => datafield(3));

	xor0: xor_C
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => datafield(4));

	barrel: barrel_shifter
			port map( i_src  => i_B,
				  	  i_shift_type => i_ALUOP(5 downto 4),
				  	  i_shamt => i_Shamt,
				  	  o_shift_out  => datafield(5));

	quad0: quadByte
		port map( i_A => i_qByte,
				  o_F => datafield(6));

	-- LUI
	luisignal(31 downto 16) <= i_B(15 downto 0);
	luisignal(15 downto 0) <= (others => '0');
	datafield(7) <= luisignal;
	
	datafield(8) <= x"0000000" & "000" & datafield(0)(31);
	
	
						
	mainmux: NBitMux
	generic map (NUM_SELECT => NUM_SELECT ) 
	port map( i_S  => i_ALUOP( NUM_SELECT - 1 downto 0),
			  i_A => datafield,
			  o_Q  => o_S);

  
end structure;
