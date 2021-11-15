-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity fetch_logic is
  generic( IMMEDIATE_LEN: integer := 16; ADDR_LEN: integer := 32; WORD_SIZE: integer := 32);
  port (
    i_instr : in std_logic_vector( WORD_SIZE - 1 downto 0 );
    i_addr: in std_logic_vector( ADDR_LEN - 1 downto 0 );
    i_clk : in std_logic;
    i_rst : in std_logic;
    jmp_imm : in std_logic_vector( 25 downto 0);
    branch_pass : in std_logic;
    jump : in std_logic;
    jmp_ins : in std_logic;
    next_addr : out std_logic_vector( WORD_SIZE - 1 downto 0 )
  );
end fetch_logic;

architecture structure of fetch_logic is

  component Ripple_Adder is
    port(i_A : in std_logic_vector(WORD_SIZE - 1 downto 0);
	     i_B : in std_logic_vector(WORD_SIZE - 1 downto 0);
	     o_S : out std_logic_vector(WORD_SIZE - 1 downto 0));
  end component;

  component mux2t1_N is
    generic(N : integer := 32);
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(WORD_SIZE - 1 downto 0);
         i_D1         : in std_logic_vector(WORD_SIZE - 1 downto 0);
         o_O          : out std_logic_vector(WORD_SIZE - 1 downto 0));
  end component;

  component dffg_N
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
       	 i_D          : in std_logic_vector( WORD_SIZE - 1 downto 0);     -- Data value input
       	 o_Q          : out std_logic_vector( WORD_SIZE - 1 downto 0));   -- Data value output
  end component;

  signal instruction_offset : std_logic_vector( WORD_SIZE - 1 downto 0);  
  signal program_counter : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal next_address : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal next_instruction : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal jump_address : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal branch_address : std_logic_vector( WORD_SIZE - 1 downto 0);
  signal branch_immediate : std_logic_vector( WORD_SIZE - 1 downto 0);
  
  
  signal branch_or_register : std_logic_vector( WORD_SIZE - 1 downto 0);
  signal branch_jump : std_logic_vector( WORD_SIZE - 1 downto 0);
  
  signal ins_after_reset : std_logic_vector( WORD_SIZE - 1 downto 0);
  
begin
  
  branch_immediate <= i_instr(29 downto 0) & "00";
  
    ins_after_reset <= x"00400000" when i_rst = '1'
        else next_address when i_clk = '0'
        else ins_after_reset;
  
  
  PC: dffg_N
  port map(
    i_CLK => i_clk,
    i_RST => '0',
    i_WE => '1',
    i_D => ins_after_reset,
    o_Q => program_counter
  );
  
  next_addr <= program_counter;
  

  program_plus_four: Ripple_Adder
  port map(
            i_A    => x"00000004",
		    i_B    => program_counter,
            o_S    => next_instruction);


  branch_address_calc: Ripple_Adder
  port map(
            i_A    => next_instruction,
		    i_B    => branch_immediate,
            o_S    => branch_address);
		   
	jump_address( 31 downto 28) <= program_counter( 31 downto 28);
	jump_address( 27 downto 2) <= jmp_imm;
	jump_address( 1 downto 0) <= "00";
	

  Branch_Reg: mux2t1_N
  port map(
            i_S     => branch_pass,
            i_D0    => next_instruction,
            i_D1    => branch_address,
            o_O     => branch_or_register);

  branch_jump_calc: mux2t1_N
  port map(
            i_S     => jump,
            i_D0    => branch_or_register,
            i_D1    => jump_address,
            o_O     => branch_jump);

  next_address_calc: mux2t1_N
  port map(
            i_S     => jmp_ins,
            i_D0    => branch_jump,
            i_D1    => i_addr,
            o_O     => next_address);

end structure;
