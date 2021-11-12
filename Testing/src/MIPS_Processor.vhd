library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.Data_Types.all;

entity MIPS_Processor is
  generic(
          N : integer := 32; 
          WORD_SIZE : integer := 32; 
          OP_CODE_SIZE : integer := 6; 
          MAX_SHIFT : integer := 5; 
          SOURCE_LEN: integer := 16;
          TARGET_LEN: integer := 32;
          IMMEDIATE_LEN: integer := 16);

  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;

  architecture structure of MIPS_Processor is

    -- Required data memory signals
    signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
    signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
    signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
    signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
  
    -- Required register file signals 
    signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
    signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
    signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

    -- Required instruction memory signals
    signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
    signal s_NextInstAddr : std_logic_vector(N-1 downto 0) := x"0003FFF8"; -- TODO: use this signal as your intended final instruction memory address input.
    signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

    -- Required halt signal -- for simulation
    signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

    -- Required overflow signal -- for overflow exception detection
    signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated
      
    signal rs              : std_logic_vector(N-1 downto 0);
    signal rt              : std_logic_vector(N-1 downto 0);
    signal wb_data         : std_logic_vector(N-1 downto 0);
    signal wb_addr         : std_logic_vector(4 downto 0);
    signal shamt         : std_logic_vector(4 downto 0);
    signal return_addr     : std_logic_vector(N-1 downto 0);
    signal alu_b           : std_logic_vector(N-1 downto 0);
    signal sign_extend_imm : std_logic_vector(N-1 downto 0);
    signal alu_op          : std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    signal q_byte_imm      : std_logic_vector(7 downto 0);
    signal halt         : std_logic;  --Becuase for some reason halt is always initialized to 1, even when explicitely set
    
    
    signal branch         : std_logic;
    signal jump           : std_logic;
    signal jmpIns         : std_logic;
    signal mem_to_reg     : std_logic;
    signal reg_dst        : std_logic;
    signal link           : std_logic;
    signal alu_src        : std_logic;
    signal ALU_zero       : std_logic;
    signal ALU_not_zero   : std_logic;
    signal branch_pass    : std_logic;
    signal ext_type       : std_logic;
    signal take_branch    : std_logic;
    signal bne            : std_logic;
    
    signal  dont_care : std_logic;
    signal  dont_care1 : std_logic;

    component ALU is
        port(i_A : in std_logic_vector(WORD_SIZE - 1 downto 0);
            i_B : in std_logic_vector(WORD_SIZE - 1 downto 0);
            i_Shamt : in std_logic_vector(4 downto 0);
            i_ALUOP : in std_logic_vector(5 downto 0);
            i_qByte : in std_logic_vector(7 downto 0);
            o_Zero : out std_logic;
            ovfl : out std_logic;
            o_S : out std_logic_vector(WORD_SIZE - 1 downto 0));
  
      end component;

      component fetch_logic is
        port (
          i_instr : in std_logic_vector( WORD_SIZE - 1 downto 0 );
          i_addr: in std_logic_vector( WORD_SIZE - 1 downto 0 );
          i_clk : in std_logic;
          i_rst : in std_logic;
          jmp_imm : in std_logic_vector( 25 downto 0);
          branch_pass : in std_logic;
          jump : in std_logic;
          jmp_ins : in std_logic;
          next_addr : out std_logic_vector( WORD_SIZE - 1 downto 0 )
        );

      end component;

      component decode_logic is
        port (i_instruction : in std_logic_vector( WORD_SIZE - 1 downto 0 );
            o_jump : out std_logic;
            o_branch : out std_logic;
            o_memToReg : out std_logic;
            o_ALUOP : out std_logic_vector(OP_CODE_SIZE - 1 downto 0);
            o_ALUSrc : out std_logic;
            o_jumpIns : out std_logic;
            o_regWrite : out std_logic;
            o_ext_type: out std_logic;
            o_q_byte : out std_logic_vector( 7 downto 0);
            o_mem_write : out std_logic;
            reg_dst : out std_logic;
            o_shamt : out std_logic_vector( MAX_SHIFT - 1 downto 0);
            o_link : out std_logic;
            o_bne : out std_logic;
            o_halt : out std_logic);
        
      end component;

      component RegisterFile is
        generic( NUM_SELECT: integer);
        port (i_D	: in std_logic_vector( WORD_SIZE - 1 downto 0);
            i_WE	: in std_logic;
            i_CLK	: in std_logic;
            i_RST	: in std_logic;
            i_WA	: in std_logic_vector( NUM_SELECT - 1 downto 0);
            i_RA0	: in std_logic_vector( NUM_SELECT - 1 downto 0);
            i_RA1	: in std_logic_vector( NUM_SELECT - 1 downto 0);
            o_D0	: out std_logic_vector( WORD_SIZE - 1 downto 0);
            o_D1	: out std_logic_vector( WORD_SIZE - 1 downto 0));
      end component;

      component Ripple_Adder is
        port(i_A : in std_logic_vector(WORD_SIZE - 1 downto 0);
             i_B : in std_logic_vector(WORD_SIZE - 1 downto 0);
             o_S : out std_logic_vector(WORD_SIZE - 1 downto 0);
             ovfl : out std_logic);
      end component;

      component extender is
        port (i_A        : in std_logic_vector( SOURCE_LEN -1 downto 0);
            type_select        : in std_logic;
            o_Q        : out std_logic_vector(TARGET_LEN - 1 downto 0));
      end component;

      component mux2t1_N is
        generic( N: integer);
        port(i_S          : in std_logic;
            i_D0         : in std_logic_vector(N - 1 downto 0);
            i_D1         : in std_logic_vector(N - 1 downto 0);
            o_O          : out std_logic_vector(N - 1 downto 0));
      end component;

      component mux2t1 is
        port(i_S          : in std_logic;
             i_D0         : in std_logic;
             i_D1         : in std_logic;
             o_O          : out std_logic);
      end component;

      component invg is
        port (i_A          : in std_logic;
              o_F          : out std_logic);
  
      end component;

      component andg2 is
        port (i_A          : in std_logic;
              i_B          : in std_logic;
              o_F          : out std_logic);
  
      end component;

      component mem is
        generic(ADDR_WIDTH : integer;
                DATA_WIDTH : integer);
        port(
              clk          : in std_logic;
              addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
              data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
              we           : in std_logic := '1';
              q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
        end component;


begin

  FetchLogic: fetch_logic 
  port MAP (i_instr => sign_extend_imm,
            i_addr => rs,
            i_rst => iRST,
            i_clk => iCLK,
            jmp_imm => s_Inst(25 downto 0),
            branch_pass => take_branch,
            jump => jump,
            jmp_ins => jmpIns,
            next_addr => s_NextInstAddr);
            
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);
    
    s_DMemData <= rt;

    wb_select_mux: mux2t1_N
    generic map ( N => 5 ) 
		port map( i_S => reg_dst,
                  i_D0 => s_Inst(15 downto 11),
                  i_D1 => s_Inst(20 downto 16),
                  o_O => wb_addr);
    
    link_select_mux: mux2t1_N
    generic map ( N => 5 ) 
		port map( i_S => link,
                  i_D0 => wb_addr,
                  i_D1 => "1" & x"F",
                  o_O => s_RegWrAddr);
    
    s_RegWrData_mux: mux2t1_N
		generic map ( N => WORD_SIZE ) 
		port map( i_S => link,
                  i_D0 => wb_data,
                  i_D1 => return_addr,
                  o_O => s_RegWrData);

    wb_data_mux: mux2t1_N
		generic map ( N => WORD_SIZE ) 
		port map( i_S => mem_to_reg,
                  i_D0 => s_DMemAddr,
                  i_D1 => s_DMemOut,
                  o_O => wb_data);

    
    immediate_select_mux: mux2t1_N
		generic map ( N => WORD_SIZE ) 
		port map( i_S => alu_src,
                  i_D0 => rt,
                  i_D1 => sign_extend_imm,
                  o_O => alu_b);

    branch_type_mux: mux2t1
		port map( i_S => bne,
                  i_D0 => ALU_zero,
                  i_D1 => ALU_not_zero,
                  o_O => branch_pass);
    
    rippleadder: Ripple_Adder
        port map(i_A    => s_IMemAddr,
		      	     i_B    => x"00000004",
                 o_S    => return_addr,
                 ovfl => dont_care);
    
    RegFile: RegisterFile 
        generic map ( NUM_SELECT => 5)
        port map(i_D => s_RegWrData, 
                i_WE => s_RegWr,
                i_CLK => iCLK,
                i_RST => iRST,
                i_WA => s_RegWrAddr,
                i_RA0 => s_Inst(25 downto 21),
                i_RA1 => s_Inst(20 downto 16),
                o_D0 => rs,
                o_D1 => rt);

    INVG0: invg port MAP (i_A => ALU_zero, 
                          o_F => ALU_not_zero);

    ANDG0: andg2 port MAP (i_A => branch, 
                           i_B => branch_pass, 
                           o_F => take_branch);
                                      
    DecodeLogic: decode_logic 
        port MAP (i_instruction => s_Inst,
                  o_jump => jump,
                  o_branch => branch,
                  o_memToReg => mem_to_reg,
                  o_ALUOP => alu_op,
                  o_ALUSrc => alu_src,
                  o_jumpIns => jmpIns,
                  o_regWrite => s_RegWr,
                  o_q_byte => q_byte_imm,
                  o_shamt => shamt,
                  reg_dst => reg_dst,
                  o_mem_write => s_DMemWr,
                  o_link => link,
                  o_ext_type => ext_type,
                  o_bne => bne,
                  o_halt => s_Halt);

    AluLogic: ALU 
        port MAP (i_A => rs,
                  i_B => alu_b,
                  i_Shamt => shamt,
                  i_ALUOP => alu_op,
                  i_qByte => q_byte_imm,
                  o_Zero => ALU_zero,
                  ovfl => s_Ovfl,
                  o_S => s_DMemAddr);

    oALUOut <= s_DMemAddr;
  
    extender1: extender 
        port MAP (i_A => s_Inst( 15 downto 0),
                  type_select => ext_type,
                  o_Q => sign_extend_imm);

    
    
end structure;
