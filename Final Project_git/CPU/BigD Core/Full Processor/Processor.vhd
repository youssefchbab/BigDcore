Library ieee;
use ieee.std_logic_1164.all;

entity Processor is
  port (
        clk,Reset: in std_logic;
        Instruction: in std_logic_vector(31 downto 0) ;
        ReadData: in std_logic_vector(31 downto 0) ;
        MemWrite: out std_logic;
        Pc: out std_logic_vector(31 downto 0) ;
        DataAdr: out std_logic_vector(31 downto 0) ;
        WriteData: out std_logic_vector(31 downto 0)
    ) ;
end Processor;

architecture arch of Processor is
    component Datapath_improved is   
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
    end component;
    component Control_Unit is  
        port(
            Alu_LSB,Zero: in std_logic;
            Funct7: in std_logic_vector(6 downto 0) ;
            Opcode: in std_logic_vector(6 downto 0) ;
            Funct3: in std_logic_vector(2 downto 0) ;
            Alu_control: out std_logic_vector(3 downto 0) ;
            ImmExt: out std_logic_vector(2 downto 0);
            Word_Half_Byte: out std_logic_vector(1 downto 0);
            RegWrite: out std_logic;
            MemWrite: out std_logic;
            Mem_Ext_cntr: out std_logic_vector(2 downto 0);
            Write_Back_cntr: out std_logic_vector(1 downto 0);
            Pc_clr: out std_logic;
            Pc_select: out std_logic_vector(1 downto 0);
            Alu_input: out std_logic;
            Alu_input_for_auipc_and_lui: out std_logic_vector(1 downto 0)
        );
    end component;
    --Signal Declaration
    Signal Alu_Input_for_auipc_and_lui_Signal: std_logic_vector(1 downto 0) ;
    Signal Alu_cntr_Signal: std_logic_vector(3 downto 0) ;
    Signal Alu_input_Signal: std_logic ;
    Signal ImmExt_cntr_Signal: std_logic_vector(2 downto 0) ;
    Signal MemExt_cntr_Signal: std_logic_vector(2 downto 0) ; 
    Signal Pc_clr_Signal: std_logic ;
    Signal Pc_select_Signal: std_logic_vector(1 downto 0) ;
    Signal Reg_file_WE_Signal: std_logic ;
    Signal Word_Half_Byte_sel_Signal: std_logic_vector(1 downto 0) ;
    Signal Write_back_cntr_Signal: std_logic_vector(1 downto 0) ;
    Signal Alu_LSB_Signal: std_logic;
    Signal Zero_Signal: std_logic;
Begin
    Datapath_unit: Datapath_improved port map(
        Clk,Reset,
        Alu_Input_for_auipc_and_lui_Signal,
        Alu_cntr_Signal,
        Alu_input_Signal,
        ImmExt_cntr_Signal,
        MemExt_cntr_Signal,
        Pc_clr_Signal,
        Pc_select_Signal,
        Reg_file_WE_Signal,
        Word_Half_Byte_sel_Signal,
        Write_back_cntr_Signal,
        ReadData,
        Instruction,
        Alu_LSB_Signal,
        Zero_Signal,
        DataAdr,
        WriteData,
        PC);
    Controlling_unit: Control_Unit port map(
        Alu_LSB_Signal,
        Zero_Signal,
        instruction(31 downto 25),
        instruction(6 downto 0),
        instruction(14 downto 12),
        Alu_cntr_Signal,
        ImmExt_cntr_Signal,
        Word_Half_Byte_sel_Signal,
        Reg_file_WE_Signal,
        MemWrite,
        MemExt_cntr_Signal,
        Write_back_cntr_Signal,
        Pc_clr_Signal,
        Pc_select_Signal,
        Alu_input_Signal,
        Alu_Input_for_auipc_and_lui_Signal);

end arch ; -- arch