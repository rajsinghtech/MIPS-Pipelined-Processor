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
    component MIPS_Processor

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

    end  component;

    --signals
   signal sCLK, reset, si_WE       : std_logic := '0';
   signal s_AlU_out               : std_logic_vector(31 downto 0);
   signal s_iInstLd               : std_logic := '1';
   signal s_InstAddr               : std_logic_vector(31 downto 0);
   signal iInstExt               : std_logic_vector(31 downto 0);
   
    --begin

BEGIN

    DUT_Pipeline: MIPS_Processor port map(i_CLK => sCLK,
                                          iInstLd => s_iInstLd,
                                          iInstAddr => s_InstAddr,
                                          iInstExt => iInstExt,
                                          oALUOut => s_AlU_out);

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
       
        WAIT FOR gCLK_HPER * 2;
        ----------------------------------------------------------------------

        end process;

END tb_arch_proj2_hardware_regs; -- tb_arch_proj2_hardware_regs