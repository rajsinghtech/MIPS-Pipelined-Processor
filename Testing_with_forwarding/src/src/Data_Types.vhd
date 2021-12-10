-- Quartus Prime VHDL Template
-- Single-port RAM with single read/write address

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Data_Types is

	type DATA_FIELD is array(integer range <>) of std_logic_vector(31 downto 0);
	type shift_layers is array(5 downto 0, 31 downto 0) of std_logic;
	
	type ALU_ENCODING is ( op_add, op_sub, op_and, op_or, op_nor, op_xor, op_sll, op_srl, op_sra, op_quad, op_lui, op_slt);
	type OP_CODE is ( r_type, addic, addiuc, andic, xori, oric, luic, lwc, swc, beqc, bnec, sltic, sltiuc, jc, jalc, halt, quadc);
	type FUNC_CODE is ( addc, adduc, andc, norc, xorc, orc, sllc, srlc, sltc, srac,subc, subuc, jrc, quadc, syscall);
	

	type ALUENCODING_ARRAY is array(ALU_ENCODING) of std_logic_vector(5 downto 0);
	type OPCODE_ARRAY is array(OP_CODE) of std_logic_vector(5 downto 0);
	type FUNCCODE_ARRAY is array(FUNC_CODE) of std_logic_vector(5 downto 0);
	
	constant DECODE_ALU_ENCODING : ALUENCODING_ARRAY;
	constant DECODE_OP : OPCODE_ARRAY;
	constant DECODE_FUNC : FUNCCODE_ARRAY;

end package Data_Types;

package body Data_Types is

	constant DECODE_OP : OPCODE_ARRAY := (  r_type => "000000",
											addic => "001000", 
											addiuc => "001001",	
										    andic => "001100", 
											luic => "001111", 
											xori => "001110", 
											oric => "001101",
											lwc => "100011",
											swc => "101011", 
											beqc => "000100", 
											bnec => "000101", 
											sltic => "001010",
											sltiuc => "001011",
											jc => "000010", 
											jalc => "000011",
											halt => "010100",
											quadc => "011111" );

	constant DECODE_ALU_ENCODING : ALUENCODING_ARRAY := (  
	                                        op_add => "000000",
											op_sub => "100000",
											op_and => "000001", 
											op_or  => "000010",
											op_nor => "000011", 
											op_xor => "000100", 
											op_sll => "010101", 
											op_srl => "100101", 
											op_sra => "110101", 
											op_quad => "000110", 
											op_lui => "000111",
											op_slt => "101000");

	constant DECODE_FUNC : FUNCCODE_ARRAY := (  
												addc => "100000", 
												adduc => "100001", 
												andc => "100100", 
												norc => "100111", 
												xorc => "100110", 
												orc => "100101",  
												sltc => "101010",  
												sllc => "000000", 
												srlc => "000010", 
												srac => "000011",
												subc => "100010", 
												subuc => "100011", 
												jrc => "001000", 
												quadc => "010010",
												syscall => "001100"
	 );
											

end package body Data_Types;
