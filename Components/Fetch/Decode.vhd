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
      o_memToReg : out std_logic;
      o_ALUOP : out std_logic_vector(OP_CODE_SIZE - 1 downto 0);
      o_ALUSrc : out std_logic;
      o_jumpIns : out std_logic;
      o_regWrite : out std_logic;
      o_ext_type: out std_logic;
      o_shamt : out std_logic_vector( MAX_SHIFT - 1 downto 0);
      o_link : out std_logic;
      o_bne : out std_logic
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

  signal op_code : std_logic_vector(OP_CODE_SIZE - 1 downto 0);
  signal func_code : std_logic_vector(FUNC_CODE_SIZE - 1 downto 0);
  signal op_and_func_code : std_logic_vector(11 downto 0);

  begin

  op_code <= i_instruction(31 downto 26);
  func_code <= i_instruction(5 downto 0);
  o_shamt <= i_instruction(10 downto 6);
  op_and_func_code(11 downto 6) <= i_instruction(31 downto 26);
  op_and_func_code(5 downto 0 ) <= i_instruction(5 downto 0);

  o_jump <= '1' when op_code = DECODE_OP(jc)
                else '1' when op_code = DECODE_OP(jalc)
                else '0';

  o_branch <= '1' when op_code = DECODE_OP(beqc)
                else '1' when op_code = DECODE_OP(bnec)
                else '0';

  o_memToReg <= '1' when op_code = DECODE_OP(lwc)
                else '0';

  with op_and_func_code select o_ALUOP <=
    DECODE_ALU_ENCODING(op_add) when DECODE_OP(r_type) & DECODE_FUNC(addc),
    DECODE_ALU_ENCODING(op_add) when DECODE_OP(r_type) & DECODE_FUNC(addic),
    DECODE_ALU_ENCODING(op_add) when DECODE_OP(r_type) & DECODE_FUNC(addiuc),
    DECODE_ALU_ENCODING(op_add) when DECODE_OP(r_type) & DECODE_FUNC(adduc),
    DECODE_ALU_ENCODING(op_sub) when DECODE_OP(r_type) & DECODE_FUNC(subc),
    DECODE_ALU_ENCODING(op_sub) when DECODE_OP(r_type) & DECODE_FUNC(subuc),
    DECODE_ALU_ENCODING(op_and) when DECODE_OP(r_type) & DECODE_FUNC(andc),
    DECODE_ALU_ENCODING(op_and) when DECODE_OP(r_type) & DECODE_FUNC(andic),
    DECODE_ALU_ENCODING(op_or) when DECODE_OP(r_type) & DECODE_FUNC(orc),
    DECODE_ALU_ENCODING(op_or) when DECODE_OP(r_type) & DECODE_FUNC(oric),
    DECODE_ALU_ENCODING(op_nor) when DECODE_OP(r_type) & DECODE_FUNC(norc),
    DECODE_ALU_ENCODING(op_xor) when DECODE_OP(r_type) & DECODE_FUNC(xorc),
    DECODE_ALU_ENCODING(op_xor) when DECODE_OP(r_type) & DECODE_FUNC(xori),
    DECODE_ALU_ENCODING(op_slt) when DECODE_OP(r_type) & DECODE_FUNC(sltc),
    DECODE_ALU_ENCODING(op_slt) when DECODE_OP(r_type) & DECODE_FUNC(sltic),
    DECODE_ALU_ENCODING(op_sll) when DECODE_OP(r_type) & DECODE_FUNC(sllc),
    DECODE_ALU_ENCODING(op_srl) when DECODE_OP(r_type) & DECODE_FUNC(srlc),
    DECODE_ALU_ENCODING(op_sra) when DECODE_OP(r_type) & DECODE_FUNC(srac),
    DECODE_ALU_ENCODING(op_quad) when DECODE_OP(r_type) & DECODE_FUNC(quadc),
    "000000" when others;

    o_ALUSrc <= '1';
  -- o_ALUSrc <= '1' when (op_code = DECODE_OP(r_type) ) and ( func_code = DECODE_FUNC(addic) )
  --               else '1' when ( op_code = DECODE_OP(r_type) ) and ( func_code = DECODE_FUNC(addiuc) )
  --               else '1' when ( op_code = DECODE_OP(r_type) ) and ( func_code = DECODE_FUNC() and (ic) )
  --               else '1' when ( op_code = DECODE_OP(r_type) ) and ( func_code = DECODE_FUNC(luic) )
  --               else '1' when ( op_code = DECODE_OP(r_type) ) and ( func_code = DECODE_FUNC(xori) )
  --               else '1' when ( op_code = DECODE_OP(r_type) ) and ( func_code = DECODE_FUNC(oric) )
  --               else '1' when ( op_code = DECODE_OP(r_type) ) and ( func_code = DECODE_FUNC(sltic) )
  --               else '0';

  o_jumpIns <= '1'; --when DECODE_OP(r_type) and (func_code = DECODE_FUNC(jrc))
                --else '0';

  o_regWrite <= '1'; -- when DECODE_OP(r_type) and !(func_code = DECODE_FUNC(jrc))
                  --else '0';

  o_link <= '1' when op_code = DECODE_OP(jalc)
              else '0';

end structure;
