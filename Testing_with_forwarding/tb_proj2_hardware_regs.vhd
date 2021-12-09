LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE IEEE.numeric_std.ALL;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_proj2_hardware_regs IS
    GENERIC (
        gClk_per : TIME := 10ns;
        N : INTEGER := 32);
END ENTITY;

ARCHITECTURE tb_arch_proj2_hardware_regs OF tb_proj2_hardware_regs IS

    --components
    COMPONENT dffg_N
        GENERIC (N : INTEGER);
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock input
            i_RST : IN STD_LOGIC; -- Reset input
            i_WE : IN STD_LOGIC; -- Write enable input
            i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Data value input
            o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- Data value output
    END COMPONENT;

    COMPONENT dffg_N_with_reset
        GENERIC (N : INTEGER);
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock input
            i_RST : IN STD_LOGIC; -- Reset input
            i_WE : IN STD_LOGIC; -- Write enable input
            reset_value : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Data value input
            o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- Data value output

    END COMPONENT;

    --signals
    signal sCLK, reset, si_WE       : std_logic := '0';
    signal s_instructionLoad        : std_logic := '1';
    signal s_o_ALUOut               : std_logic_vector(31 downto 0);
    signal s_instructionAddr        : std_logic_vector := x"00400000"


   signal flush : std_logic;
    signal stall : std_logic;
-----------------------------------------------------------------------------------
    signal fetch_stage_reg          : std_logic_vector( 95 downto 0);
    signal decode_stage_reg         : std_logic_vector( 190 downto 0);
    signal execute_stage_reg        : std_logic_vector( 72 downto 0);
    signal mem_stage_reg            : std_logic_vector( 38 downto 0);
-----------------------------------------------------------------------------------



    --begin

BEGIN

    IF_ID_Reg : dffg_N
    GENERIC MAP(N => 96)
    PORT MAP(
        i_CLK => iCLK,
        i_RST => iRST OR flush,
        i_WE => NOT stall,
        i_D(31 DOWNTO 0) => raw_ins_F,
        i_D(63 DOWNTO 32) => jal_return_F,
        i_D(95 DOWNTO 64) => next_ins_F,
        o_Q => fetch_stage_reg
    );
    ID_EX_Reg : dffg_N
    GENERIC MAP(N => 191)
    PORT MAP(
        i_CLK => iCLK,
        i_RST => iRST,
        i_WE => NOT stall,
        i_D(31 DOWNTO 0) => raw_ins_D,
        i_D(63 DOWNTO 32) => jal_return_D,
        i_D(95 DOWNTO 64) => next_ins_D,
        i_D(126 DOWNTO 96) => control_sigs_D,
        i_D(158 DOWNTO 127) => rs_D,
        i_D(190 DOWNTO 159) => rt_D,
        o_Q => decode_stage_reg
    );
    EX_MEM_Reg : dffg_N
    GENERIC MAP(N => 73)
    PORT MAP(
        i_CLK => iCLK,
        i_RST => iRST AND NOT iCLK,
        i_WE => '1',
        i_D(31 DOWNTO 0) => wb_data_EX, -- alu out
        i_D(63 DOWNTO 32) => rt_EX, -- jump address
        i_D(68 DOWNTO 64) => final_wb_addr_EX, -- mem write data
        i_D(69) => control_sigs_EX(26), -- mem write sig
        i_D(70) => control_sigs_EX(2), -- mem to reg sig
        i_D(71) => control_sigs_EX(30), -- halt sig
        i_D(72) => control_sigs_EX(11), -- reg write sig
        o_Q => execute_stage_reg
    );
    MEM_WB_Reg : dffg_N
    GENERIC MAP(N => 39)
    PORT MAP(
        i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1',
        i_D(31 DOWNTO 0) => wb_data_MEM, -- write back data
        i_D(36 DOWNTO 32) => wb_addr_MEM, -- write back address
        i_D(37) => halt_MEM, -- halt
        i_D(38) => reg_write_MEM, -- reg_write
        o_Q => mem_stage_reg
    );

    P_CLK : PROCESS
    BEGIN
        sCLK <= '1'; -- clock starts at 1
        WAIT FOR gCLK_HPER; -- after half a cycle
        sCLK <= '0'; -- clock becomes a 0 (negative edge)
        WAIT FOR gCLK_HPER; -- after half a cycle, process begins evaluation again
    END PROCESS;

    P_RST : PROCESS
    BEGIN
        reset <= '0';
        WAIT FOR gCLK_HPER/2;
        reset <= '1';
        WAIT FOR gCLK_HPER * 2;
        reset <= '0';
        WAIT;
    END PROCESS;

    P_TESTCASES : PROCESS
    BEGIN
        -- reset <= '1';
        -- wait for gCLK_HPER*2;
        -- reset <= '0';

        WAIT FOR gCLK_HPER * 1; -- for waveform clarity, I prefer not to change inputs on clk edges

        --#TODO TODO TODO TODO TODO
        s_rd <= "11001"; -- #Load $A into 25; addi
        s_rs <= "00000";
        si_WE <= '1';
        s_immediate <= x"0000";
        s_ext_control <= '0';
        s_ALU_sc <= '1';
        sn_add_sub <= '0';

        --mem control signals
        s_mem_to_reg <= '1';
        s_mem_write <= '0';
        WAIT FOR gCLK_HPER * 2;
        ----------------------------------------------------------------------

        end process;

END tb_arch_proj2_hardware_regs; -- tb_arch_proj2_hardware_regs