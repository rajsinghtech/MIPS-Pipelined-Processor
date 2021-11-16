library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.Data_Types.all;

entity decode_logic is
  generic(WORD_SIZE : integer := 32; MAX_SHIFT : integer := 5; OP_CODE_SIZE : integer := 6; FUNC_CODE_SIZE : integer := 6);
  port (
      i_instruction : in std_logic_vector( WORD_SIZE - 1 downto 0 );
      o_jump : out std_logic;
      o_branch : out std_logic;
      o_memToReg : out std_logic; --
      o_ALUOP : out std_logic_vector(OP_CODE_SIZE - 1 downto 0); --
      o_ALUSrc : out std_logic; --
      o_jumpIns : out std_logic;
      o_regWrite : out std_logic; --
      o_ext_type: out std_logic;
      reg_dst : out std_logic; --
      o_shamt : out std_logic_vector( MAX_SHIFT - 1 downto 0);
      o_q_byte : out std_logic_vector( 7 downto 0);
      o_mem_write : out std_logic; --
      o_link : out std_logic;
      o_bne : out std_logic;
      o_halt : out std_logic := '0'
    );
end decode_logic;

  -- Instruction format
  -- (31 downto 26) = opcode
  -- (25 downto 21) = rs
  -- (20 downto 16) = rt
  -- (15 downto 11) = rd
  -- (10 downto 6) = shamt
  -- (5 downto 0) = func

  -- (31 downto 26) = opcode
  -- (25 downto 21) = rs
  -- (20 downto 16) = rt
  -- (15 downto 0) = immediate

  -- (31 downto 26) = opcode
  -- (25 downto 0) = jump address

architecture structure of decode_logic is

  signal op_code : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000000";
  signal func_code : std_logic_vector(FUNC_CODE_SIZE - 1 downto 0);
  signal op_and_func_code : std_logic_vector(11 downto 0);
  signal halt_sig : std_logic := '0';

  begin

  op_code <= i_instruction(WORD_SIZE - 1 downto WORD_SIZE - OP_CODE_SIZE);
  func_code <= i_instruction(5 downto 0);
  o_shamt <= i_instruction(10 downto 6);
  op_and_func_code(11 downto 6) <= i_instruction(31 downto 26);
  op_and_func_code(5 downto 0 ) <= i_instruction(5 downto 0);
  
  o_q_byte <= i_instruction( 23 downto 16 );
  
  o_halt <= '1' when op_code = DECODE_OP(halt)
                else '0'; 

  o_jump <= '1' when op_code = DECODE_OP(jc)
                else '1' when op_code = DECODE_OP(jalc)
                else '0';

  o_branch <= '1' when op_code = DECODE_OP(beqc)
                else '1' when op_code = DECODE_OP(bnec)
                else '0';

  o_memToReg <= '1' when op_code = DECODE_OP(lwc)
                else '0';

  o_ext_type <= '1' when (op_and_func_code or "000000111111") = (DECODE_OP(beqc) & "111111")
          else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(addic) & "111111")
          else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(addiuc) & "111111")
          else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(bnec) & "111111")
          else '0' when (op_and_func_code or "000000111111") = (DECODE_OP(andic) & "111111")
          else '0' when (op_and_func_code or "000000111111") = (DECODE_OP(oric) & "111111")
          else '0' when (op_and_func_code or "000000111111") = (DECODE_OP(xori) & "111111")
          else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(sltic) & "111111")
          else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(sltiuc) & "111111")
          else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(lwc) & "111111")
          else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(swc) & "111111")
          else '0';

  o_ALUOP <= DECODE_ALU_ENCODING(op_add) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(addc))
          else DECODE_ALU_ENCODING(op_add) when (op_and_func_code or "000000111111") = (DECODE_OP(addic) & "111111")
          else DECODE_ALU_ENCODING(op_add) when (op_and_func_code or "000000111111") = (DECODE_OP(addiuc) & "111111")
          else DECODE_ALU_ENCODING(op_sub) when (op_and_func_code or "000000111111") = (DECODE_OP(beqc) & "111111")
          else DECODE_ALU_ENCODING(op_sub) when (op_and_func_code or "000000111111") = (DECODE_OP(bnec) & "111111")          
          else DECODE_ALU_ENCODING(op_add) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(adduc))
          else DECODE_ALU_ENCODING(op_sub) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(subc))
          else DECODE_ALU_ENCODING(op_sub) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(subuc))
          else DECODE_ALU_ENCODING(op_and) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(andc))
          else DECODE_ALU_ENCODING(op_and) when (op_and_func_code or "000000111111") = (DECODE_OP(andic) & "111111")
          else DECODE_ALU_ENCODING(op_or) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(orc))
          else DECODE_ALU_ENCODING(op_or) when (op_and_func_code or "000000111111") = (DECODE_OP(oric) & "111111")
          else DECODE_ALU_ENCODING(op_nor) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(norc))
          else DECODE_ALU_ENCODING(op_xor) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(xorc))
          else DECODE_ALU_ENCODING(op_xor) when (op_and_func_code or "000000111111") = (DECODE_OP(xori) & "111111")
          else DECODE_ALU_ENCODING(op_slt) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(sltc))
          else DECODE_ALU_ENCODING(op_slt) when (op_and_func_code or "000000111111") = (DECODE_OP(sltic) & "111111")
          else DECODE_ALU_ENCODING(op_slt) when (op_and_func_code or "000000111111") = (DECODE_OP(sltiuc) & "111111")
          else DECODE_ALU_ENCODING(op_sll) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(sllc))
          else DECODE_ALU_ENCODING(op_srl) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(srlc))
          else DECODE_ALU_ENCODING(op_sra) when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(srac))
          else DECODE_ALU_ENCODING(op_quad) when op_and_func_code = (DECODE_OP(quadc) & DECODE_FUNC(quadc))
          else DECODE_ALU_ENCODING(op_lui) when (op_and_func_code or "000000111111") = (DECODE_OP(luic) & "111111") 
          else DECODE_ALU_ENCODING(op_add) when (op_and_func_code or "000000111111") = (DECODE_OP(swc) & "111111") 
          else DECODE_ALU_ENCODING(op_add) when (op_and_func_code or "000000111111") = (DECODE_OP(lwc) & "111111") 
          else "111111";

   o_ALUSrc <= '1' when op_code = DECODE_OP(addic)
                   else '1' when op_code = DECODE_OP(addiuc)
                   else '1' when op_code = DECODE_OP(andic)
                   else '1' when op_code = DECODE_OP(oric)
                   else '1' when op_code = DECODE_OP(xori)
                   else '1' when op_code = DECODE_OP(luic)
                   else '1' when op_code = DECODE_OP(swc)
                   else '1' when op_code = DECODE_OP(lwc)
                   else '1' when op_code = DECODE_OP(sltic)
                   else '1' when op_code = DECODE_OP(sltiuc)
                   else '0';
    
   reg_dst <= '1' when op_code = DECODE_OP(addic)
               else '1' when op_code = DECODE_OP(addiuc)
               else '1' when op_code = DECODE_OP(andic)
               else '1' when op_code = DECODE_OP(oric)
               else '1' when op_code = DECODE_OP(xori)
               else '1' when op_code = DECODE_OP(luic)
               else '1' when op_code = DECODE_OP(lwc) 
               else '1' when op_code = DECODE_OP(sltic)    
               else '1' when op_code = DECODE_OP(sltiuc)               
               else '0';
    
    o_mem_write <= '1' when op_code = DECODE_OP(swc)
                    else '0';


  o_jumpIns <= '1' when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(jrc))
                else '0';



   o_regWrite <= '1' when (op_and_func_code or "000000111111") = (DECODE_OP(addic) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(addiuc) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(andic) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(oric) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(xori) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(jalc) & "111111")
                    else '0' when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(jrc))
                    else '0' when op_and_func_code = (DECODE_OP(r_type) & DECODE_FUNC(syscall))
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(r_type) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(luic) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(lwc) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(sltic) & "111111")
                    else '1' when (op_and_func_code or "000000111111") = (DECODE_OP(sltiuc) & "111111")
                    else '1' when op_and_func_code = (DECODE_OP(quadc) & DECODE_FUNC(quadc))
                    else '0';
    
  o_link <= '1' when op_code = DECODE_OP(jalc)
              else '0';
              
  o_bne <= '1' when op_code = DECODE_OP(bnec)
                else '0';

end structure;
