Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
-- PLR: PipeLine Register
-- PLR1: PipeLine Register in Fetch cycle
-- PLR2: PipeLine Register in Decode cycle
-- PLR3: PipeLine Register in Excute cycle
-- PLR4: PipeLine Register in Memory cycle
-- PLR5: PipeLine Register in Writeback cycle

entity P_Datapath is
    port (
        Clk,Reset: in std_logic;
        Alu_Input_for_auipc_and_lui: in std_logic_vector(1 downto 0) ;
        Alu_cntr: in std_logic_vector(3 downto 0) ;
        Alu_input: in std_logic;
        ImmExt_cntr: in std_logic_vector(2 downto 0) ;
        MemExt_cntr: in std_logic_vector(2 downto 0) ;
        Pc_clr: in std_logic; --Later to be replaced by Reset
        Pc_select: in std_logic_vector(1 downto 0) ;
        Reg_file_WE: in std_logic;
        Word_Half_Byte_sel: in std_logic_vector(1 downto 0) ;
        Write_back_cntr: in std_logic_vector(1 downto 0) ;
        ReadData: in std_logic_vector(31 downto 0) ;
        Instruction: in std_logic_vector(31 downto 0);
        Alu_LSB: out std_logic;
        Zero: out std_logic;--Siganl indicating the result is 0
        DataAdr: out std_logic_vector(31 downto 0) ;
        WriteData: out std_logic_vector(31 downto 0) ;
        PC: out std_logic_vector(31 downto 0);
        Funct7: out std_logic_vector(6 downto 0) ;-- From decode Cycle
        Opcode: out std_logic_vector(6 downto 0) ;-- From decode Cycle
        Funct3: out std_logic_vector(2 downto 0) ;-- From decode Cycle
        --Hazard Unit related Signals
        StallF, StallD: in std_logic;
        FlushE, FlushD: in std_logic;
        ForwardA, ForwardB: in std_logic_vector(1 downto 0);
        Rs1D, Rs2D: out std_logic_vector(4 downto 0);
        Rs1E, Rs2E: out std_logic_vector(4 downto 0);
        RdE, RdM, RdW: out std_logic_vector(4 downto 0)
    );
end entity;

architecture arch of P_Datapath is
    --Component Declaration
    component Adder is
        generic(N: integer:= 32);
        port(
            a,b: in std_logic_vector(N-1 downto 0);
            y: out std_logic_vector(N-1 downto 0)
        );
    end component;
    component Adderss_Shift is
        port(
            Address_in: in std_logic_vector(31 downto 0);
            Address_out: out std_logic_vector(31 downto 0)
        );
    end component;
    component ALU is
        generic(Alu_bits: integer:= 32);
	    port(A,B: in std_logic_vector(Alu_bits-1 downto 0);
		 Alu_cntr: in std_logic_vector(3 downto 0);
		 Alu_out: out std_logic_vector(Alu_bits-1 downto 0);
		 Zero: out std_logic
        );--Zero flag
    end component;
    component Bit_Manipulation_Store is 
        port(
            Mem_Data: in std_logic_vector(31 downto 0);
            Reg_Data: in std_logic_vector(31 downto 0);
            Sel_Mode: in std_logic_vector(1 downto 0);
            Sel_data: in std_logic_vector(1 downto 0);
            Data_out: out std_logic_vector(31 downto 0)
        );
    end component;
    component ImmExt is
        port(
            inst: in std_logic_vector(31 downto 0) ;
            ImmCntr: in std_logic_vector(2 downto 0);
            Imm_Extended: out std_logic_vector(31 downto 0)
        );
    end component;
    component RegEn is
        generic(N: integer := 32);
        port (
            clk,Reset: in std_logic;
            stall, Flush: in std_logic;
            En: in std_logic;
            NoN: in std_logic_vector(N-1 downto 0) ;
            D: in std_logic_vector(N-1 downto 0) ;
            Q: out std_logic_vector(N-1 downto 0)

        ) ;
    end component;
    component RegEn_5bit is
        generic(N: integer := 5);
        port (
            clk,Reset: in std_logic;
            En, Flush: in std_logic;
            NoN: in std_logic_vector(N-1 downto 0) ;
            D: in std_logic_vector(N-1 downto 0) ;
            Q: out std_logic_vector(N-1 downto 0)

        ) ;
    end component;
    component Mem_SignExt is
        port(Mem_in: in std_logic_vector(31 downto 0);
	 	 Alu_Lsb: in std_logic_vector(1 downto 0);
		 Sel: in std_logic_vector(2 downto 0);
		 To_Reg: out std_logic_vector(31 downto 0)
         );
    end component;
    component Mux2 is
        generic(N: integer:= 32);
        port(
            a,b: in std_logic_vector(N-1 downto 0);
            sel: in std_logic;
            y: out std_logic_vector(N-1 downto 0)
        );
    end component;
    component Mux3 is
        generic(N: integer:= 32);
	    port(
            a,b,c: in std_logic_vector(N-1 downto 0);
            sel: in std_logic_vector(1 downto 0);
            y: out std_logic_vector(N-1 downto 0)
        );
    end component;
    component Mux4 is
        generic(N: integer:= 32);
	    port(
            a,b,c,d: in std_logic_vector(N-1 downto 0);
            sel: in std_logic_vector(1 downto 0);
            y: out std_logic_vector(N-1 downto 0)
        );
    end component;
    component Reg_File is
        port (
            a1,a2,a3: in std_logic_vector(4 downto 0);
            clk,reset,we: in std_logic;
            W: in std_logic_vector(31 downto 0);
            R1,R2: out std_logic_vector(31 downto 0)
        );
    end component;

    --Constant Declaration
    Constant One: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(1, 32));
    Constant Four: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4, 32));
    Constant Zero_value: std_logic_vector(31 downto 0):= std_logic_vector(to_unsigned(0, 32)) ;
    --Signal Declaration
    Signal Pc_Next, Pc_Signal, Pc_Plus_4: std_logic_vector (31 downto 0);
    Signal instruction_PLR2: std_logic_vector (31 downto 0);
    Signal Write_Back, Reg_file_R1, Reg_file_R2: std_logic_vector (31 downto 0);
    Signal Imm_Extended, Imm_Extended_PLR3: std_logic_vector (31 downto 0);
    Signal Reg_file_R1_PLR3, Reg_file_R2_PLR3: std_logic_vector (31 downto 0);
    Signal Alu_input_A, Alu_input_B: std_logic_vector(31 downto 0);
    Signal Target_addr, Alu_result, Alu_result_PLR5: std_logic_vector(31 downto 0);
    Signal Pc_Plus_4_PLR2, Pc_Plus_4_PLR3, Pc_Plus_4_PLR4, Pc_Plus_4_PLR5: std_logic_vector(31 downto 0);
    Signal Extend_Mem, PC_Signal_PLR2, Pc_Signal_PLR3: std_logic_vector(31 downto 0);
    Signal Alu_result_PLR4, ReadData_PLR5: std_logic_vector(31 downto 0);
    Signal Reg_A3_PLR3, Reg_A3_PLR4, Reg_A3_PLR5: std_logic_vector(4 downto 0);
    Signal ForwarededA, ForwarededB, ForwarededB_PLR4: std_logic_vector(31 downto 0);
    Signal Rs1DS, Rs2DS: std_logic_vector(4 downto 0);
    Signal RdDS, RdES, RdMS: std_logic_vector(4 downto 0);

Begin

    --Fetch Cycle Components
    Pc_Register: RegEn port map(
        clk,Pc_clr,
        StallF,'0',
        '0',
        (others=>'0'),
        Pc_Next,
        Pc_Signal
    );
    instruction_PLR: RegEn port map(
        clk, reset,
        StallD,FlushD,
        '0',
        x"00000033",
        instruction,
        instruction_PLR2
    );
    Pc_Selection: Mux3 port map(
        Alu_Result,
        Pc_plus_4,
        Target_addr,
        Pc_select,
        Pc_Next
    );
    Pc_Plus_Four: Adder port map(
        Four,
        Pc_Signal,
        Pc_Plus_4
    );
    PC_PLR: RegEn port map(
        clk, reset,
        StallD,FlushD,
        '0',
        (others=>'0'),
        PC_Signal,
        PC_Signal_PLR2
    );
    Pc_Plus_Four_PLR: RegEn port map(
        clk, reset,
        StallD,FlushD,
        '0',
        (others=>'0'),
        Pc_Plus_4,
        Pc_Plus_4_PLR2
    );
    
    --Decode Cycle Components
    Register_File: Reg_File port map(
        instruction_PLR2(19 downto 15),
        instruction_PLR2(24 downto 20),
        Reg_A3_PLR5,
        clk,Reset,
        Reg_file_WE,
        Write_Back,
        Reg_file_R1,
        Reg_file_R2
    );
    Immediate_Extension: ImmExt port map(
        instruction_PLR2,
        ImmExt_cntr,
        Imm_Extended
    );
    Imm_Extended_PLR: RegEn port map(
        clk,reset,
        '0',FlushE,
        '0',
        (others=>'0'),
        Imm_Extended,
        Imm_Extended_PLR3
    );
    Reg3_Address_PLR: RegEn_5bit port map( 
        clk, reset,
        '0', FlushE,
        (others=>'0'),
        instruction_PLR2(11 downto 7),
        Reg_A3_PLR3
    );
    Reg_file_Register1_PLR3: RegEn port map(
        clk, reset,
        '0',FlushE,
        '0',
        (others=>'0'),
        Reg_file_R1,
        Reg_file_R1_PLR3
    );
    Reg_file_Register2_PLR3: RegEn port map(
        clk, reset,
        '0',FlushE,
        '0',
        (others=>'0'),
        Reg_file_R2,
        Reg_file_R2_PLR3
    );
    Pc_PLR_Seocnd: RegEn port map(
        clk, reset,
        '0',FlushE,
        '0',
        (others=>'0'),
        Pc_Signal_PLR2,
        Pc_Signal_PLR3
    );
    Pc_Plus_Four_PLR_Second: RegEn port map(
        clk, reset,
        '0',FlushE,
        '0',
        (others=>'0'),
        Pc_Plus_4_PLR2,
        Pc_Plus_4_PLR3
    );
    Opcode<= instruction_PLR2(6 downto 0);
    Funct7<= instruction_PLR2(31 downto 25);
    Funct3<= instruction_PLR2(14 downto 12);
    Rs1DS<= instruction_PLR2(19 downto 15);
    Rs2DS<= instruction_PLR2(24 downto 20);
    RdDS<= instruction_PLR2(11 downto 7);
    Rs1D_PLR: RegEn_5bit port map(
        clk, reset,
        '0', FlushE,
        (others=>'0'),
        Rs1DS,
        Rs1E
    );
    Rs2D_PLR: RegEn_5bit port map(
        clk, reset,
        '0', FlushE,
        (others=>'0'),
        Rs2DS,
        Rs2E
    );
    Rs1D<= Rs1DS;
    Rs2D<= Rs2DS;

    --Execute Cycle Components
    ALU_in_A: Mux3 port map(
        ForwarededA,
        Pc_Signal_PLR3,
        Zero_value,
        Alu_Input_for_auipc_and_lui,
        Alu_input_A
    );
    ALU_in_B: Mux2 port map(
        Imm_Extended_PLR3,
        ForwarededB,
        Alu_input,
        Alu_input_B
    );
    Alu_Unit: ALU port map(
        ALU_input_A,
        ALU_input_B,
        Alu_cntr,
        Alu_result,
        Zero
    );
    Target_Address: Adder port map(
        Pc_Signal_PLR3,
        Imm_Extended_PLR3,
        Target_addr
    );
    Alu_result_PLR: RegEn port map(
        clk, reset,
        '0','0',
        '0',
        (others=>'0'),
        Alu_result,
        Alu_result_PLR4
    );
    Reg3_Address_PLR_second: RegEn_5bit port map(
        clk, reset,
        '0', '0',
        (others=>'0'),
        Reg_A3_PLR3,
        Reg_A3_PLR4
    );
    Pc_Plus_Four_PLR_Third: RegEn port map(
        clk, reset,
        '0','0', '0',
        (others=>'0'),
        Pc_Plus_4_PLR3,
        Pc_Plus_4_PLR4
    );
    ForwardingA: Mux3 port map(
        Reg_file_R1_PLR3,
        Write_Back,
        Alu_result_PLR4,
        ForwardA,
        ForwarededA
    );
    ForwardingB: Mux3 port map(
        Reg_file_R2_PLR3,
        Write_Back,
        Alu_result_PLR4,
        ForwardB,
        ForwarededB
    );
    ForwaredB_PLR: RegEn port map(
        clk, reset,
        '0','0', '0',
        (others=>'0'),
        ForwarededB,
        ForwarededB_PLR4
    );
    RdE<= Reg_A3_PLR3;
    --Memory Access Cycle Components
    Bit_Manipulation: Bit_Manipulation_Store port map(
        ReadData,
        ForwarededB_PLR4,
        Word_Half_Byte_sel,
        Alu_result_PLR4(1 downto 0),
        WriteData
    );
    Addr_Shift: Adderss_Shift port map(
        Alu_result_PLR4,
        DataAdr
    );
    Alu_result_PLR_second: RegEn port map(
        clk, reset,
        '0','0','0',
        (others=>'0'),
        Alu_result_PLR4,
        Alu_result_PLR5
    );
    Reg3_Address_PLR_Third: RegEn_5bit port map(
        clk, reset,
        '0', '0',
        (others=>'0'),
        Reg_A3_PLR4,
        Reg_A3_PLR5
    );
    Read_Data_PLR: RegEn port map(
        clk, reset,
        '0','0','0',
        (others=>'0'),
        ReadData,
        ReadData_PLR5
    );
    Pc_Plus_Four_PLR_Fourth: RegEn port map(
        clk, reset,
        '0','0','0',
        (others=>'0'),
        Pc_Plus_4_PLR4,
        Pc_Plus_4_PLR5
    );
    RdM <= Reg_A3_PLR4;
    --Writeback Cycle Components
    WriteBack: Mux3 port map(
        Pc_Plus_4_PLR5,
        Extend_Mem,
        Alu_result_PLR5,
        Write_back_cntr,
        Write_Back
    );
    Memory_Extension: Mem_SignExt port map(
        ReadData_PLR5,
        Alu_result_PLR5(1 downto 0), --AlU LSB
        MemExt_cntr,
        Extend_Mem
    );
    RdW<= Reg_A3_PLR5;
    --Signal Assigning
    PC<= Pc_Signal;
    Alu_LSB<= Alu_result(0);
end arch;