Library ieee;
use ieee.std_logic_1164.all;
--Includes the Datapath and the control unit (The memory is set as a perapheral)
entity P_Processor_Hazard is
  port (
    clk, reset: in std_logic;
    instruction: in std_logic_vector (31 downto 0);
    ReadData: in std_logic_vector (31 downto 0);
    MemWrite: out std_logic;
    Pc: out std_logic_vector(31 downto 0) ;
    DataAdr: out std_logic_vector(31 downto 0) ;
    WriteData: out std_logic_vector(31 downto 0)
  ) ;
end P_Processor_Hazard;

architecture arch of P_Processor_Hazard is
  component P_Control_Unit is
    port(
      clk, reset: in std_logic;
      Zero, Alu_LSB: in std_logic;
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
      Alu_input_for_auipc_and_lui: out std_logic_vector(1 downto 0);
      Reg_WriteM: out std_logic;--Used by hazard unit
      Write_backE: out std_logic;--Used by hazard unit
      FlushE: in std_logic
    );
  end component;
  component P_Datapath is
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
  end component;
  component Hazard_Unit is
    port(
      RsD1, RsD2: in std_logic_vector(4 downto 0);
      RsE1, RsE2: in std_logic_vector(4 downto 0);
      RdE,RdM,RdW: in std_logic_vector(4 downto 0);
      RegWriteM, RegWriteW: in std_logic;
      Writeback_cntr: in std_logic; --The Lsb is enough
      Pc_Select: in std_logic;--MSB
      ForwardA, ForwardB: out std_logic_vector(1 downto 0);
      StallF, StallD: out std_logic;
      FlushE, FlushD: out std_logic
    );
  end component; 
  Signal Alu_LSB, Zero: std_logic ;
  Signal Alu_control: std_logic_vector(3 downto 0) ;
  Signal ImmExt, Mem_Ext_cntr: std_logic_vector(2 downto 0) ;
  Signal Word_Half_Byte, Write_Back_cntr: std_logic_vector(1 downto 0) ;
  Signal Pc_select, Alu_input_for_auipc_and_lui: std_logic_vector(1 downto 0) ;
  Signal RegWrite, Pc_clr, Alu_input: std_logic;
  Signal Reg_WriteM, Write_backE, FlushE, FlushD: std_logic;
  Signal StallF, StallD: std_logic;
  Signal ForwardA, ForwardB: std_logic_vector(1 downto 0) ;
  Signal Rs1D, Rs2D, Rs1E, Rs2E: std_logic_vector(4 downto 0) ;
  Signal RdE, RdM, RdW: std_logic_vector(4 downto 0) ;
  Signal Funct7, Opcode: std_logic_vector(6 downto 0);
  Signal Funct3: std_logic_vector(2 downto 0) ;
begin

  Datapath: P_Datapath port map(
    clk, reset,
    Alu_input_for_auipc_and_lui,
    Alu_control,
    Alu_input,
    ImmExt,
    Mem_Ext_cntr,
    Pc_clr,
    Pc_select,
    RegWrite,
    Word_Half_Byte,
    Write_Back_cntr,
    ReadData,
    Instruction,
    Alu_LSB,
    Zero,
    DataAdr,
    WriteData,
    PC,
    Funct7,
    Opcode,
    Funct3,
    StallF, StallD,
    FlushE, FlushD,
    ForwardA, ForwardB,
    Rs1D, Rs2D,
    Rs1E, Rs2E,
    RdE, RdM, RdW
  );
  ControlUnit: P_Control_Unit port map(
    clk, reset,
    Alu_LSB, Zero,
    Funct7,
    Opcode,
    Funct3,
    Alu_control,
    ImmExt,
    Word_Half_Byte,
    RegWrite,
    MemWrite,
    Mem_Ext_cntr,
    Write_Back_cntr,
    Pc_clr,
    Pc_select,
    Alu_input,
    Alu_input_for_auipc_and_lui,
    Reg_WriteM,
    Write_backE, FlushE
  );
  HazardUnit: Hazard_Unit port map(
    Rs1D, Rs2D, Rs1E, Rs2E,
    RdE, RdM, RdW,
    Reg_WriteM, RegWrite,
    Write_backE,
    Pc_Select(1),
    ForwardA, ForwardB,
    StallF, StallD,
    FlushE
  );
end arch ; -- arch