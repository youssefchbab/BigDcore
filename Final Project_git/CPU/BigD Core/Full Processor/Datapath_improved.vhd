Library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_std.all;
--  Some modifications are done to support The Whole system design 
--    inspired from page-456.
entity Datapath_improved is
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
        PC: out std_logic_vector(31 downto 0)
        --Funct3, Funct7 and Opcode are removed from original
        
    );
end Datapath_improved;

architecture arch of Datapath_improved is
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
		 Zero: out std_logic;
		 Alu_LSB: out std_logic_vector(1 downto 0));--Zero flag
    end component;
    component Bit_Manipulation_Store is-- Bit_Manipulation_Load
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
    component Reg is
        generic(N: integer := 32);
        port (
            clk,Reset: in std_logic;
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
    Signal Pc_Signal, Write_Back: std_logic_vector(31 downto 0) ;--Pc_Signal holds the PC current value
    Signal Reg_file_R1, Reg_file_R2: std_logic_vector(31 downto 0) ;
    Signal Alu_inA, Alu_inB: std_logic_vector(31 downto 0) ;--Alu Operators
    Signal Alu_Result: std_logic_vector(31 downto 0) ;--Alu Final Result
    Signal MemoryRead: std_logic_vector(31 downto 0) ;--Modified Data to be stored in register as a bit, a half or a word
    Signal ExtendedImm: std_logic_vector(31 downto 0) ;--holds the Extended Immediated value
    Signal Target_addr: std_logic_vector(31 downto 0) ;--Hold the target address (BTA or JTA)
    Signal Pc_plus_4, Pc_Next: std_logic_vector(31 downto 0) ;
    Signal Alu_Lsb_Signal: std_logic_vector(1 downto 0);
Begin
    Register_File: Reg_File port map (
        instruction(19 downto 15),
        instruction(24 downto 20),
        instruction(11 downto 7),
        clk,Reset,
        Reg_file_WE,
        Write_Back,
        Reg_file_R1,
        Reg_file_R2);
    Arithmetic_Logic_Unit: ALU port map(
        Alu_inA,
        Alu_inB,
        Alu_cntr,
        Alu_Result,
        Zero, 
        Alu_Lsb_Signal);
    Address_Bits_Shift: Adderss_Shift port map(
        Alu_Result,
        DataAdr); 
    Bit_Manipulation_unit: Bit_Manipulation_Store port map(
        ReadData, 
        Reg_file_R2,
        Word_Half_Byte_sel,
        Alu_Result(1 downto 0),
        WriteData);
    Memory_Sign_Extension: Mem_SIgnExt port map (
        ReadData,
        Alu_Lsb_Signal,
        MemExt_cntr,
        MemoryRead);
    WriteBack_Mux: Mux3 port map(
        PC_plus_4,
        MemoryRead,
        Alu_Result,
        Write_back_cntr,
        Write_Back);
    Immediate_Extension: ImmExt port map(
        instruction,
        ImmExt_cntr,
        ExtendedImm);
    Targer_Address: Adder port map(
        Pc_Signal,
        ExtendedImm,
        Target_addr);
    PC_Plus_Four: Adder port map(
        Pc_Signal,
        Four,
        PC_plus_4);
    Pc_Selection: Mux3 port map(
        Alu_Result,
        Pc_plus_4,
        Target_addr,
        Pc_select,
        Pc_Next);
    Pc_Register: Reg port map(
        clk,Reset,
        Pc_Next,
        Pc_Signal);
    
    Alu_input_A_Mux: Mux3 port map(
        Reg_file_R1,
        Pc_Signal,
        Zero_value,
        Alu_Input_for_auipc_and_lui,
        Alu_inA);
    Alu_input_B_Mux: Mux2 port map(
        ExtendedImm,
        Reg_file_R2,
        Alu_input,
        Alu_inB);
    PC<= Pc_Signal;
    Alu_LSB<= Alu_Lsb_Signal(0);
end arch ; -- arch