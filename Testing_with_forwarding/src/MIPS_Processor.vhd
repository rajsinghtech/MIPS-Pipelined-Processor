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
    signal s_NextInstAddr : std_logic_vector(N-1 downto 0) := x"00400000"; -- TODO: use this signal as your intended final instruction memory address input.
    signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

    -- Required halt signal -- for simulation
    signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

    -- Required overflow signal -- for overflow exception detection
    signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated
      

    -- Fetch signals

    signal next_ins_F              : std_logic_vector(N-1 downto 0);
    signal jal_return_F            : std_logic_vector(N-1 downto 0);
    signal raw_ins_F               : std_logic_vector(N-1 downto 0);

    signal fetch_stage_reg         : std_logic_vector( 95 downto 0);

    -- Decode Signals
    
    signal next_ins_D              : std_logic_vector(N-1 downto 0);
    signal jal_return_D            : std_logic_vector(N-1 downto 0);
    signal raw_ins_D               : std_logic_vector(N-1 downto 0);
    signal control_sigs_D          : std_logic_vector(30 downto 0);


    signal rs_D              : std_logic_vector(N-1 downto 0);
    signal rt_D              : std_logic_vector(N-1 downto 0);

    signal decode_stage_reg         : std_logic_vector( 190 downto 0);

  -- Execute signals

  signal next_ins_EX             : std_logic_vector(N-1 downto 0);
  signal jal_return_EX           : std_logic_vector(N-1 downto 0);
  signal raw_ins_EX              : std_logic_vector(N-1 downto 0);
  signal control_sigs_EX         : std_logic_vector(30 downto 0);
  signal alu_out_EX              : std_logic_vector(N-1 downto 0);
  signal wb_data_EX               : std_logic_vector(N-1 downto 0);

  signal rs_EX              : std_logic_vector(N-1 downto 0);
  signal rt_EX              : std_logic_vector(N-1 downto 0);
  signal sign_ext_imm       : std_logic_vector(N-1 downto 0);

  signal alu_select_a       : std_logic_vector(1 downto 0);
  signal alu_select_b       : std_logic_vector(1 downto 0);

  signal alu_a              : std_logic_vector(N-1 downto 0);
  signal alu_b              : std_logic_vector(N-1 downto 0);

  signal branch_immediate   : std_logic_vector(N-1 downto 0);
  signal branch_addr        : std_logic_vector(N-1 downto 0);
  signal branch_result_addr : std_logic_vector(N-1 downto 0);
  signal jump_calc_addr     : std_logic_vector(N-1 downto 0);
  signal jump_result_addr   : std_logic_vector(N-1 downto 0);
  signal final_addr         : std_logic_vector(N-1 downto 0);
  
  signal wb_addr_EX       : std_logic_vector(4 downto 0);
  signal final_wb_addr_EX : std_logic_vector(4 downto 0);

  signal ALU_zero           : std_logic;
  signal ALU_not_zero       : std_logic;
  signal branch_pass        : std_logic;
  signal take_branch        : std_logic;

  signal execute_stage_reg         : std_logic_vector( 72 downto 0);


  -- Memory Signals

  signal next_ins_MEM             : std_logic_vector(N-1 downto 0);
  signal alu_out_MEM             : std_logic_vector(N-1 downto 0);
  signal mem_out_MEM             : std_logic_vector(N-1 downto 0);
  signal wb_data_MEM             : std_logic_vector(N-1 downto 0);
  signal wb_addr_MEM                  : std_logic_vector(4 downto 0);


  signal mem_write_MEM            : std_logic;
  signal mem_to_reg_MEM         : std_logic;
  signal halt_MEM      : std_logic;
  signal reg_write_MEM      : std_logic;

  -- Write Back signals

  signal mem_stage_reg         : std_logic_vector( 38 downto 0);

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

        component dffg_N
        generic( N : integer );
        port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
              i_D          : in std_logic_vector( N - 1 downto 0);     -- Data value input
              o_Q          : out std_logic_vector( N - 1 downto 0));   -- Data value output
      end component;

      component dffg_N_with_reset
        generic( N: integer );
        port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             reset_value  : in std_logic_vector( N - 1 downto 0);
             i_D          : in std_logic_vector( N - 1 downto 0);     -- Data value input
             o_Q          : out std_logic_vector( N - 1 downto 0));   -- Data value output
      
      end component;

      component mux4t1_N
        generic( N: integer );
        port(i_S          : in std_logic_vector( 1 downto 0);
             i_D0         : in std_logic_vector( N-1 downto 0 );
             i_D1         : in std_logic_vector( N-1 downto 0 );
             i_D2         : in std_logic_vector( N-1 downto 0 );
             i_D3         : in std_logic_vector( N-1 downto 0 );
             o_O          : out std_logic_vector( N-1 downto 0 ));
      
      end component;

      component forwarding_unit
        generic( N: integer := 32 );
        port(
              ALUSource   : in std_logic;
              wb_mem_addr : in std_logic_vector(4 downto 0);
              wb_wb_addr  : in std_logic_vector(4 downto 0);
              rs_addr     : in std_logic_vector(4 downto 0);
              rt_addr     : in std_logic_vector(4 downto 0);
              wb_mem_data : in std_logic_vector(N-1 downto 0);
              wb_wb_data : in std_logic_vector(N-1 downto 0);
      
              rs_select   : out std_logic_vector( 1 downto 0);
              rt_select   : out std_logic_vector( 1 downto 0)
        );   -- Data value output
      
      end component;
      

begin

-- Fetch stage


  PC: dffg_N_with_reset
  generic map(N => 32)
  port map(
    i_CLK => iCLK,
    i_RST => iRST,
    i_WE => '1',
    reset_value => x"00400000",
    i_D => s_NextInstAddr,
    o_Q => s_IMemAddr
  );

  next_ins: Ripple_Adder
  port map(i_A    => s_IMemAddr,
           i_B    => x"00000004",
           o_S    => next_ins_F,
           ovfl => open);

  return_addr: Ripple_Adder
  port map(i_A    => s_IMemAddr,
          i_B    => x"00000004",
          o_S    => jal_return_F,
          ovfl => open);   
          
  raw_ins_F <= s_Inst;


  IMem: mem
  generic map(ADDR_WIDTH => 10,
              DATA_WIDTH => N)
  port map(clk  => iCLK,
           addr => s_IMemAddr(11 downto 2),
           data => iInstExt,
           we   => iInstLd,
           q    => s_Inst);


  -- IF/ID Stage registers

  -- 31 downto 0 = next_ins_F
  -- 63 downto 32 = jal_return_F
  -- 95 downto 64 = raw_ins_F

  IF_ID_Reg: dffg_N
  generic map(N => 96)
  port map(
    i_CLK => iCLK,
    i_RST => iRST,
    i_WE => '1',
    i_D(31 downto 0) => raw_ins_F,
    i_D(63 downto 32) => jal_return_F,
    i_D(95 downto 64) => next_ins_F,
    o_Q => fetch_stage_reg
  );

-- Decode Stage

next_ins_D <= fetch_stage_reg(95 downto 64);
jal_return_D <= fetch_stage_reg(63 downto 32);
raw_ins_D <= fetch_stage_reg(31 downto 0);




  DecodeLogic: decode_logic 
  port MAP (i_instruction => raw_ins_D,
          o_jump => control_sigs_D(0),
          o_branch => control_sigs_D(1),
          o_memToReg => control_sigs_D(2),
          o_ALUOP => control_sigs_D(8 downto 3),
          o_ALUSrc => control_sigs_D(9),
          o_jumpIns => control_sigs_D(10),
          o_regWrite => control_sigs_D(11),
          o_q_byte => control_sigs_D(19 downto 12),
          o_shamt => control_sigs_D(24 downto 20),
          reg_dst => control_sigs_D(25),
          o_mem_write => control_sigs_D(26),
          o_link => control_sigs_D(27),
          o_ext_type => control_sigs_D(28),
          o_bne => control_sigs_D(29),
          o_halt => control_sigs_D(30));


    RegFile: RegisterFile 
        generic map ( NUM_SELECT => 5)
        port map(i_D => s_RegWrData, 
                i_WE => s_RegWr,
                i_CLK => iCLK,
                i_RST => iRST,
                i_WA => s_RegWrAddr,
                i_RA0 => raw_ins_D(25 downto 21),
                i_RA1 => raw_ins_D(20 downto 16),
                o_D0 => rs_D,
                o_D1 => rt_D);


-- Decode - Execute state registers


    ID_EX_Reg: dffg_N
    generic map(N => 191)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE => '1',
      i_D(31 downto 0) => raw_ins_D,
      i_D(63 downto 32) => jal_return_D,
      i_D(95 downto 64) => next_ins_D,
      i_D(126 downto 96) => control_sigs_D,
      i_D(158 downto 127) => rs_D,
      i_D(190 downto 159) => rt_D,
      o_Q => decode_stage_reg
    );

-- Execute Stage

raw_ins_EX <= decode_stage_reg(31 downto 0);
jal_return_EX <= decode_stage_reg(63 downto 32);
next_ins_EX <= decode_stage_reg(95 downto 64);
control_sigs_EX <= decode_stage_reg(126 downto 96);

rs_EX <= decode_stage_reg(158 downto 127);
rt_EX <= decode_stage_reg(190 downto 159);

wb_addr_select: mux2t1_N
generic map ( N => 5 ) 
port map( i_S => control_sigs_EX(25),
              i_D0 => raw_ins_EX(15 downto 11),
              i_D1 => raw_ins_EX(20 downto 16),
              o_O => wb_addr_EX);

link_select: mux2t1_N
generic map ( N => 5 ) 
port map( i_S => control_sigs_EX(27),
              i_D0 => wb_addr_EX,
              i_D1 => "11111",
              o_O => final_wb_addr_EX);

-- arithmetic operations --------------------------------------

sign_extend: extender 
port MAP (i_A => raw_ins_EX( 15 downto 0),
          type_select => control_sigs_EX(28), -- sign extend signal
          o_Q => sign_ext_imm);

forwarding_logic: forwarding_unit
    port map(
      ALUSource   => control_sigs_EX(9),
      wb_mem_addr => wb_addr_MEM,
      wb_wb_addr  => s_RegWrAddr,
      rs_addr     => raw_ins_EX(25 downto 21),
      rt_addr     => raw_ins_EX(20 downto 16),

      rs_select   => alu_select_a,
      rt_select   => alu_select_b

alu_a_select: mux4t1_N
port map( i_S => alu_select_a,
              i_D0 => rs_EX,
              i_D1 => wb_data_MEM,
              i_D2 => s_RegWrData,
              i_D3 => open,
              o_O => alu_a);

alu_b_select: mux4t1_N
port map( i_S => alu_select_b,
              i_D0 => rt_EX,
              i_D1 => sign_ext_imm,
              i_D2 => wb_data_MEM,
              i_D3 => s_RegWrData,
              o_O => alu_b_select);


AluLogic: ALU 
port MAP (i_A => alu_a,
          i_B => alu_b,
          i_Shamt => raw_ins_EX(10 downto 6),
          i_ALUOP => control_sigs_EX(8 downto 3),
          i_qByte => control_sigs_EX(19 downto 12),
          o_Zero => ALU_zero,
          ovfl => s_Ovfl,
          o_S => alu_out_EX);


INVG0: invg port MAP (i_A => ALU_zero, 
                      o_F => ALU_not_zero);


jal_wb_select: mux2t1_N
generic map ( N => 32 ) 
port map( i_S => control_sigs_EX(27),
              i_D0 => alu_out_EX,
              i_D1 => jal_return_EX,
              o_O => wb_data_EX);

-- address calculation --------------------------------------

-- Branch calculation

  branch_immediate <= sign_ext_imm(29 downto 0) & "00";

  rippleadder: Ripple_Adder
  port map(i_A    => next_ins_F,
          i_B    => branch_immediate,
          o_S    => branch_addr,
          ovfl => open);


-- Branch pass ?

  branch_type_mux: mux2t1
  port map( i_S => control_sigs_EX(29), -- bne signal
                i_D0 => ALU_zero,
                i_D1 => ALU_not_zero,
                o_O => branch_pass);


  ANDG0: andg2 port MAP (i_A => control_sigs_EX(1), -- branch signal
          i_B => branch_pass, 
          o_F => take_branch);


-- address select muxes

  branch_select: mux2t1_N
  generic map ( N => 32 ) 
  port map( i_S => take_branch,
                i_D0 => next_ins_F,
                i_D1 => branch_addr,
                o_O => branch_result_addr);


  jump_calc_addr <= next_ins_EX(31 downto 28) & raw_ins_EX(25 downto 0) & "00";

  jump_select: mux2t1_N
  generic map ( N => 32 ) 
  port map( i_S => control_sigs_EX(0), -- jump signal
                i_D0 => branch_result_addr,
                i_D1 => jump_calc_addr,
                o_O => jump_result_addr);

  jr_select: mux2t1_N
  generic map ( N => 32 ) 
  port map( i_S => control_sigs_EX(10), -- jr signal
                i_D0 => jump_result_addr,
                i_D1 => rs_EX,
                o_O => final_addr);

  s_NextInstAddr <= final_addr;

-- Execute state registers


  EX_MEM_Reg: dffg_N
  generic map(N => 73)
  port map(
    i_CLK => iCLK,
    i_RST => iRST,
    i_WE => '1',
    i_D(31 downto 0) => wb_data_EX,        -- alu out
    i_D(63 downto 32) => rt_EX,            -- jump address
    i_D(68 downto 64) => final_wb_addr_EX, -- mem write data
    i_D(69) => control_sigs_EX(26),        -- mem write sig
    i_D(70) => control_sigs_EX(2),         -- mem to reg sig
    i_D(71) => control_sigs_EX(30),        -- halt sig
    i_D(72) => control_sigs_EX(11),        -- reg write sig
    o_Q => execute_stage_reg
  );

-- Memory stage

mem_write_MEM <=  execute_stage_reg(69);
mem_to_reg_MEM <= execute_stage_reg(70);
halt_MEM <=       execute_stage_reg(71);
reg_write_MEM <=  execute_stage_reg(72);

wb_addr_MEM <= execute_stage_reg(68 downto 64);


s_DMemWr <= mem_write_MEM;
s_DMemAddr <= execute_stage_reg(31 downto 0);
s_DMemData <= execute_stage_reg(63 downto 32);

  DMem: mem
  generic map(ADDR_WIDTH => 10,
              DATA_WIDTH => N)
  port map(clk  => iCLK,
           addr => s_DMemAddr(11 downto 2),
           data => s_DMemData,
           we   => s_DMemWr,
           q    => s_DMemOut);  

  mem_wb_data_select: mux2t1_N
  generic map ( N => 32 ) 
  port map( i_S => mem_to_reg_MEM, -- jump signal
                i_D0 => execute_stage_reg(31 downto 0),
                i_D1 => s_DMemOut,
                o_O => wb_data_MEM);    

-- Memory state registers


MEM_WB_Reg: dffg_N
generic map(N => 39)
port map(
  i_CLK => iCLK,
  i_RST => iRST,
  i_WE => '1',
  i_D(31 downto 0) => wb_data_MEM,        -- write back data
  i_D(36 downto 32) => wb_addr_MEM,  -- write back address
  i_D(37) => halt_MEM,                    -- halt
  i_D(38) => reg_write_MEM,               -- reg_write
  o_Q => mem_stage_reg
);


-- Write back stage

s_RegWr <= mem_stage_reg(38);
s_RegWrAddr <= mem_stage_reg(36 downto 32);
s_RegWrData <= mem_stage_reg(31 downto 0);
s_Halt <= mem_stage_reg(37);

end structure;
