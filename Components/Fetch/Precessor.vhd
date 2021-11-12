library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.Data_Types.all;

entity precessor is
    generic( IMMEDIATE_LEN: integer := 16; 
             MAX_SHIFT : integer := 5; 
             NUM_SELECT: integer := 5;
             OP_CODE_SIZE : integer := 6;
             ADDR_LEN: integer := 5; 
             WORD_SIZE: integer := 32;
             SOURCE_LEN: integer := 16;
             TARGET_LEN: integer := 32;
             DATA_WIDTH: integer := 32;
             ADDR_WIDTH: integer := 32);
    
  
  end precessor;

  architecture structure of precessor is
    component ALU is
        port(i_A : in std_logic_vector(WORD_SIZE - 1 downto 0);
            i_B : in std_logic_vector(WORD_SIZE - 1 downto 0);
            i_Shamt : in std_logic_vector(4 downto 0);
            i_ALUOP : in std_logic_vector(5 downto 0);
            o_Zero : out std_logic;
            o_S : out std_logic_vector(WORD_SIZE - 1 downto 0));
  
      end component;

      component fetch_logic is
        port (
          i_imm : in std_logic_vector( IMMEDIATE_LEN - 1 downto 0 );
          i_addr: in std_logic_vector( WORD_SIZE - 1 downto 0 );
          i_clk : in std_logic;
          jmp_imm : in std_logic_vector( 25 downto 0);
          branch_pass : in std_logic;
          jump : in std_logic;
          jmp_ins : in std_logic
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
            o_shamt : out std_logic_vector( MAX_SHIFT - 1 downto 0);
            o_link : out std_logic;
            o_bne : out std_logic);
        
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
             o_S : out std_logic_vector(WORD_SIZE - 1 downto 0));
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

      component mem
      port(
          clk		: in std_logic;
          addr	        : in std_logic_vector( 9 downto 0 );
          data	        : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we		: in std_logic := '1';
          q		: out std_logic_vector((DATA_WIDTH -1) downto 0));
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

      -- Control signals ----------------------------

      signal mem_write: std_logic;
      signal mem_to_reg: std_logic;
      signal reg_dst: std_logic;
      signal jump: std_logic;
      signal branch: std_logic;
      signal alu_op: std_logic_vector(5 downto 0);
      signal jmpIns: std_logic;
      signal reg_write: std_logic;
      signal shamt : std_logic_vector(4 downto 0);
      signal bne: std_logic;
      signal link: std_logic;
      signal alu_src: std_logic;
      signal ext_type: std_logic;
      
      signal clk: std_logic;
      signal rst: std_logic := '0';



      -- Data Signals -------------------------------

      -- Fetch Signals
      signal pc_ins: std_logic_vector(WORD_SIZE - 1 downto 0) := (others =>'0');
      signal cur_ins: std_logic_vector(WORD_SIZE - 1 downto 0);

      -- Execute signals

      signal return_addr: std_logic_vector(WORD_SIZE - 1 downto 0);

      signal wb_addr: std_logic_vector(4 downto 0);
      signal write_addr: std_logic_vector(NUM_SELECT - 1 downto 0);

      signal ALU_zero: std_logic;
      signal ALU_not_zero: std_logic;
      signal branch_pass: std_logic;
      signal take_branch: std_logic;

      signal alu_out: std_logic_vector(WORD_SIZE - 1 downto 0);
      signal rt: std_logic_vector(WORD_SIZE - 1 downto 0);
      signal rs: std_logic_vector(WORD_SIZE - 1 downto 0);
      signal sign_extend_imm : std_logic_vector(WORD_SIZE - 1 downto 0);
      signal alu_b : std_logic_vector(WORD_SIZE - 1 downto 0);
      -- Mem signals

      signal mem_out: std_logic_vector(WORD_SIZE - 1 downto 0);

      -- Write back signals
      signal wb_data: std_logic_vector(WORD_SIZE - 1 downto 0);
      signal write_data: std_logic_vector(WORD_SIZE - 1 downto 0);


begin

    instructionmemory: mem
		port map( addr => pc_ins(9 downto 0),
                  data => (others =>'0'),
                  we => '0',
                  q => cur_ins,
                  clk => clk);

    datamemory: mem 
    port map(data => rt, 
              we => mem_write,
              clk => clk,
              addr => alu_out(9 downto 0),
              q => mem_out);

    wb_mux: mux2t1_N
		generic map ( N => WORD_SIZE ) 
		port map( i_S => mem_to_reg,
                  i_D0 => alu_out,
                  i_D1 => mem_out,
                  o_O => wb_data);

    wb_select_mux: mux2t1_N
    generic map ( N => 5 ) 
		port map( i_S => reg_dst,
                  i_D0 => cur_ins(15 downto 11),
                  i_D1 => cur_ins(20 downto 16),
                  o_O => wb_addr);
    
    link_select_mux: mux2t1_N
    generic map ( N => 5 ) 
		port map( i_S => link,
                  i_D0 => wb_addr,
                  i_D1 => "11111",
                  o_O => write_addr);
    
    write_data_mux: mux2t1_N
		generic map ( N => WORD_SIZE ) 
		port map( i_S => link,
                  i_D0 => wb_data,
                  i_D1 => return_addr,
                  o_O => write_data);
    
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
        port map(i_A    => pc_ins,
		      	     i_B    => x"00000008",
                 o_S    => return_addr);
    
    RegFile: RegisterFile 
        generic map ( NUM_SELECT => 5)
        port map(i_D => write_data, 
                i_WE => reg_write,
                i_CLK => clk,
                i_RST => rst, -- This may need to be 1
                i_WA => write_addr,
                i_RA0 => cur_ins(25 downto 21),
                i_RA1 => cur_ins(20 downto 16),
                o_D0 => rs,
                o_D1 => rt);

    INVG0: invg port MAP (i_A => ALU_zero, 
                          o_F => ALU_not_zero);

    ANDG0: andg2 port MAP (i_A => branch, 
                           i_B => branch_pass, 
                           o_F => take_branch);

    FetchLogic: fetch_logic 
        port MAP (i_imm => cur_ins(15 downto 0),
                  i_addr => rs,
                  i_clk => clk,
                  jmp_imm => cur_ins(25 downto 0),
                  branch_pass => branch,
                  jump => jump,
                  jmp_ins => jmpIns);
                                      
    DecodeLogic: decode_logic 
        port MAP (i_instruction => cur_ins,
                  o_jump => jump,
                  o_branch => branch,
                  o_memToReg => mem_to_reg,
                  o_ALUOP => alu_op,
                  o_ALUSrc => alu_src,
                  o_jumpIns => jmpIns,
                  o_regWrite => reg_write,
                  o_shamt => shamt,
                  o_link => link,
                  o_ext_type => ext_type,
                  o_bne => bne);

    AluLogic: ALU 
        port MAP (i_A => rs,
                  i_B => alu_b,
                  i_Shamt => shamt,
                  i_ALUOP => alu_op,
                  o_Zero => ALU_zero,
                  o_S => alu_out);
  
    extender1: extender 
        port MAP (i_A => cur_ins( 15 downto 0),
                  type_select => ext_type,
                  o_Q => sign_extend_imm);
    
end structure;